import Foundation

public enum CoinflowEnv: String {
    case prod
    case staging
    case sandbox
    case local
}

public enum CardFormVariant: String {
    case cardForm = "card-form"
    case cardNumberForm = "card-number-form"
    case cvvForm = "cvv-form"
}

public struct MerchantTheme: Encodable {
    public var primary: String?
    public var background: String?
    public var backgroundAccent: String?
    public var backgroundAccent2: String?
    public var textColor: String?
    public var textColorAccent: String?
    public var textColorAction: String?
    public var ctaColor: String?
    public var font: String?
    public var style: MerchantStyle?
    public var fontSize: String?
    public var fontWeight: String?
    public var cardNumberPlaceholder: String?
    public var cvvPlaceholder: String?
    public var expirationPlaceholder: String?
    public var showCardIcon: Bool?

    public init(
        primary: String? = nil,
        background: String? = nil,
        backgroundAccent: String? = nil,
        backgroundAccent2: String? = nil,
        textColor: String? = nil,
        textColorAccent: String? = nil,
        textColorAction: String? = nil,
        ctaColor: String? = nil,
        font: String? = nil,
        style: MerchantStyle? = nil,
        fontSize: String? = nil,
        fontWeight: String? = nil,
        cardNumberPlaceholder: String? = nil,
        cvvPlaceholder: String? = nil,
        expirationPlaceholder: String? = nil,
        showCardIcon: Bool? = nil
    ) {
        self.primary = primary
        self.background = background
        self.backgroundAccent = backgroundAccent
        self.backgroundAccent2 = backgroundAccent2
        self.textColor = textColor
        self.textColorAccent = textColorAccent
        self.textColorAction = textColorAction
        self.ctaColor = ctaColor
        self.font = font
        self.style = style
        self.fontSize = fontSize
        self.fontWeight = fontWeight
        self.cardNumberPlaceholder = cardNumberPlaceholder
        self.cvvPlaceholder = cvvPlaceholder
        self.expirationPlaceholder = expirationPlaceholder
        self.showCardIcon = showCardIcon
    }
}

public enum MerchantStyle: String, Encodable {
    case rounded
    case sharp
    case pill
}

public struct CardFormTokenResponse {
    public let token: String
    public let expMonth: String?
    public let expYear: String?
}
