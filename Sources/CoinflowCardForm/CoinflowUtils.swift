import Foundation

enum CoinflowUtils {
    static func getBaseUrl(env: CoinflowEnv?) -> String {
        guard let env = env else { return "https://coinflow.cash" }
        switch env {
        case .prod:
            return "https://coinflow.cash"
        case .local:
            return "http://localhost:3000"
        default:
            return "https://\(env.rawValue).coinflow.cash"
        }
    }
}
