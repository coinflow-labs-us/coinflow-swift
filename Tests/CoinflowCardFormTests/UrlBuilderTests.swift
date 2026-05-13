import XCTest
@testable import CoinflowCardForm

final class UrlBuilderTests: XCTestCase {
    func testDefaultEnvNoThemeOrToken() {
        let url = buildCardFormURL(
            variant: .cardForm,
            merchantId: "merchant_abc",
            env: nil,
            theme: nil,
            token: nil
        )
        XCTAssertEqual(
            url?.absoluteString,
            "https://coinflow.cash/form/v2/card-form?merchantId=merchant_abc&source=ios-sdk"
        )
    }

    func testCvvVariantOnSandbox() {
        let url = buildCardFormURL(
            variant: .cvvForm,
            merchantId: "m1",
            env: .sandbox,
            theme: nil,
            token: nil
        )
        XCTAssertEqual(
            url?.absoluteString,
            "https://sandbox.coinflow.cash/form/v2/cvv-form?merchantId=m1&source=ios-sdk"
        )
    }

    func testIncludesTokenParam() {
        let url = buildCardFormURL(
            variant: .cardNumberForm,
            merchantId: "m1",
            env: nil,
            theme: nil,
            token: "tok_123"
        )
        let str = url?.absoluteString ?? ""
        XCTAssertTrue(str.contains("token=tok_123"))
        XCTAssertTrue(str.contains("merchantId=m1"))
        XCTAssertTrue(str.contains("source=ios-sdk"))
        XCTAssertTrue(str.contains("/form/v2/card-number-form"))
    }

    func testCompressesThemeIntoQuery() {
        let theme = MerchantTheme(primary: "#ff0000", style: .pill)
        let url = buildCardFormURL(
            variant: .cardForm,
            merchantId: "m1",
            env: nil,
            theme: theme,
            token: nil
        )
        let str = url?.absoluteString ?? ""
        XCTAssertTrue(str.contains("theme="))
        XCTAssertFalse(str.contains("primary"))
        XCTAssertFalse(str.contains("ff0000"))
    }
}
