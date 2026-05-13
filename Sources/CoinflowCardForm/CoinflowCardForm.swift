import SwiftUI
import WebKit

#if canImport(UIKit)
public struct CoinflowCardFormView: UIViewRepresentable {
    private let variant: CardFormVariant
    private let merchantId: String
    private let env: CoinflowEnv?
    private let theme: MerchantTheme?
    private let token: String?
    private let coordinator: CardFormCoordinator

    public init(
        variant: CardFormVariant = .cardForm,
        merchantId: String,
        env: CoinflowEnv? = nil,
        theme: MerchantTheme? = nil,
        token: String? = nil,
        coordinator: CardFormCoordinator
    ) {
        self.variant = variant
        self.merchantId = merchantId
        self.env = env
        self.theme = theme
        self.token = token
        self.coordinator = coordinator
    }

    public func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.userContentController.add(context.coordinator, name: "coinflow")

        let js = """
        window.addEventListener('message', function(e) {
            if (e.origin !== window.location.origin) return;
            window.webkit.messageHandlers.coinflow.postMessage(typeof e.data === 'string' ? e.data : JSON.stringify(e.data));
        });
        """
        let script = WKUserScript(source: js, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        config.userContentController.addUserScript(script)

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.scrollView.isScrollEnabled = false
        webView.isOpaque = false
        webView.backgroundColor = .clear

        coordinator.webView = webView

        if let url = buildCardFormURL(variant: variant, merchantId: merchantId, env: env, theme: theme, token: token) {
            coordinator.loadedURL = url
            webView.load(URLRequest(url: url))
        }

        return webView
    }

    public static func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) {
        uiView.configuration.userContentController.removeScriptMessageHandler(forName: "coinflow")
        Task { @MainActor in coordinator.cardFormCoordinator.cleanup() }
    }

    public func updateUIView(_ uiView: WKWebView, context: Context) {
        guard let url = buildCardFormURL(variant: variant, merchantId: merchantId, env: env, theme: theme, token: token) else { return }
        if coordinator.loadedURL != url {
            coordinator.loadedURL = url
            coordinator.isLoaded = false
            uiView.load(URLRequest(url: url))
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(cardFormCoordinator: coordinator)
    }

    public class Coordinator: NSObject, WKScriptMessageHandler {
        let cardFormCoordinator: CardFormCoordinator

        init(cardFormCoordinator: CardFormCoordinator) {
            self.cardFormCoordinator = cardFormCoordinator
        }

        public func userContentController(
            _ userContentController: WKUserContentController,
            didReceive message: WKScriptMessage
        ) {
            guard let body = message.body as? String,
                  let data = body.data(using: .utf8),
                  let parsed = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let method = parsed["method"] as? String else {
                return
            }

            if method == "loaded" {
                DispatchQueue.main.async {
                    self.cardFormCoordinator.isLoaded = true
                }
            }

            if method == "tokenize" {
                handleTokenizeResponse(parsed)
            }
        }

        private func handleTokenizeResponse(_ parsed: [String: Any]) {
            guard let continuation = cardFormCoordinator.tokenizeContinuation else { return }
            cardFormCoordinator.tokenizeContinuation = nil
            switch parseTokenizeResponse(parsed) {
            case .success(let response): continuation.resume(returning: response)
            case .failure(let error): continuation.resume(throwing: error)
            }
        }
    }
}
#endif

internal func buildCardFormURL(
    variant: CardFormVariant,
    merchantId: String,
    env: CoinflowEnv?,
    theme: MerchantTheme?,
    token: String?
) -> URL? {
    let baseUrl = CoinflowUtils.getBaseUrl(env: env)
    guard var components = URLComponents(string: "\(baseUrl)/form/v2/\(variant.rawValue)") else {
        return nil
    }

    var queryItems = [
        URLQueryItem(name: "merchantId", value: merchantId),
        URLQueryItem(name: "source", value: "ios-sdk"),
    ]

    if let theme = theme, let themeData = try? JSONEncoder().encode(theme),
       let themeString = String(data: themeData, encoding: .utf8) {
        queryItems.append(URLQueryItem(
            name: "theme",
            value: LZString.compressToEncodedURIComponent(themeString)
        ))
    }

    if let token = token {
        queryItems.append(URLQueryItem(name: "token", value: token))
    }

    components.queryItems = queryItems
    return components.url
}

internal func parseTokenizeResponse(_ parsed: [String: Any]) -> Result<CardFormTokenResponse, CoinflowError> {
    if let dataString = parsed["data"] as? String {
        if dataString.hasPrefix("ERROR ") {
            return .failure(.tokenizationFailed(String(dataString.dropFirst(6))))
        }
        guard let jsonData = dataString.data(using: .utf8),
              let responseData = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            return .failure(.tokenizationFailed("Invalid response"))
        }
        return .success(buildTokenResponse(responseData))
    }

    if let responseData = parsed["data"] as? [String: Any] {
        return .success(buildTokenResponse(responseData))
    }

    return .failure(.tokenizationFailed("Invalid response"))
}

private func buildTokenResponse(_ data: [String: Any]) -> CardFormTokenResponse {
    CardFormTokenResponse(
        token: data["token"] as? String ?? "",
        expMonth: data["expMonth"] as? String,
        expYear: data["expYear"] as? String
    )
}

public enum CoinflowError: Error, LocalizedError {
    case webViewNotLoaded
    case tokenizationFailed(String)

    public var errorDescription: String? {
        switch self {
        case .webViewNotLoaded:
            return "Card form WebView not loaded"
        case .tokenizationFailed(let message):
            return message
        }
    }
}

@MainActor
public class CardFormCoordinator: ObservableObject {
    @Published public var isLoaded = false
    var webView: WKWebView?
    var loadedURL: URL?
    var tokenizeContinuation: CheckedContinuation<CardFormTokenResponse, Error>?

    public init() {}

    func cleanup() {
        webView = nil
        loadedURL = nil
        isLoaded = false
        if let continuation = tokenizeContinuation {
            tokenizeContinuation = nil
            continuation.resume(throwing: CoinflowError.tokenizationFailed("Card form disposed"))
        }
    }

    public func tokenize() async throws -> CardFormTokenResponse {
        guard let webView = webView else {
            throw CoinflowError.webViewNotLoaded
        }
        guard isLoaded else {
            throw CoinflowError.tokenizationFailed("Card form not yet loaded")
        }
        guard tokenizeContinuation == nil else {
            throw CoinflowError.tokenizationFailed("Tokenize already in progress")
        }

        return try await withCheckedThrowingContinuation { continuation in
            self.tokenizeContinuation = continuation
            webView.evaluateJavaScript("window.postMessage('tokenize', '*')")
        }
    }
}
