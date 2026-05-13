import XCTest
@testable import CoinflowCardForm

final class CoinflowUtilsTests: XCTestCase {
    func testNilEnvDefaultsToProd() {
        XCTAssertEqual(CoinflowUtils.getBaseUrl(env: nil), "https://coinflow.cash")
    }

    func testProdEnv() {
        XCTAssertEqual(CoinflowUtils.getBaseUrl(env: .prod), "https://coinflow.cash")
    }

    func testSandboxEnv() {
        XCTAssertEqual(CoinflowUtils.getBaseUrl(env: .sandbox), "https://sandbox.coinflow.cash")
    }

    func testLocalEnvUsesLocalhost() {
        XCTAssertEqual(CoinflowUtils.getBaseUrl(env: .local), "http://localhost:3000")
    }
}
