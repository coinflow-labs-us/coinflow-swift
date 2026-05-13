import XCTest
@testable import CoinflowCardForm

final class LZStringTests: XCTestCase {
    func testEmptyStringReturnsEmpty() {
        XCTAssertEqual(LZString.compressToEncodedURIComponent(""), "")
    }

    // Golden fixtures captured from pieroxy/lz-string (npm: lz-string) — the canonical JS
    // implementation that the Coinflow form runs. Our Swift port MUST byte-for-byte match.
    func testMatchesJsRefHelloWorld() {
        XCTAssertEqual(LZString.compressToEncodedURIComponent("hello world"), "BYUwNmD2AEDukCcwBMg")
    }

    func testMatchesJsRefSingleChar() {
        XCTAssertEqual(LZString.compressToEncodedURIComponent("a"), "IZA")
    }

    func testMatchesJsRefRepeatingPattern() {
        XCTAssertEqual(LZString.compressToEncodedURIComponent("ABABABABABAB"), "IIIV7Sg")
    }

    func testMatchesJsRefThemeJson() {
        XCTAssertEqual(
            LZString.compressToEncodedURIComponent("{\"primary\":\"#165DFB\",\"style\":\"rounded\"}"),
            "N4IgDgTglgtghhAniAXCAxARgGwFYAiAYgEIgA0IAzgC6IA2ApqiBAPYCuAdgCYPcgBfIA"
        )
    }

    func testMatchesJsRefTokenResponse() {
        XCTAssertEqual(
            LZString.compressToEncodedURIComponent("{\"token\":\"tok_abc123\"}"),
            "N4IgLg9g1gpgdiAXOaB9AhgIwMYEYBMAzCAL5A"
        )
    }
}
