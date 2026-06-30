import XCTest
@testable import CoinflowCardForm

final class TokenizeResponseParserTests: XCTestCase {
    private func assertFailure(_ result: Result<CardFormTokenResponse, CoinflowError>, message: String) {
        switch result {
        case .success:
            XCTFail("expected failure, got success")
        case .failure(let error):
            guard case .tokenizationFailed(let actual) = error else {
                XCTFail("expected tokenizationFailed, got \(error)")
                return
            }
            XCTAssertEqual(actual, message)
        }
    }

    func testParsesStringifiedJsonWithTokenOnly() throws {
        let result = parseTokenizeResponse(["method": "tokenize", "data": "{\"token\":\"tok_abc123\"}"])
        let response = try result.get()
        XCTAssertEqual(response.token, "tok_abc123")
        XCTAssertNil(response.expMonth)
        XCTAssertNil(response.expYear)
    }

    func testParsesStringifiedJsonWithExpiry() throws {
        let result = parseTokenizeResponse([
            "method": "tokenize",
            "data": "{\"token\":\"tok_xyz\",\"expMonth\":\"03\",\"expYear\":\"2030\"}"
        ])
        let response = try result.get()
        XCTAssertEqual(response.token, "tok_xyz")
        XCTAssertEqual(response.expMonth, "03")
        XCTAssertEqual(response.expYear, "2030")
    }

    func testParsesForterToken() throws {
        let result = parseTokenizeResponse([
            "method": "tokenize",
            "data": "{\"token\":\"tok_xyz\",\"forterToken\":\"forter_abc\"}"
        ])
        let response = try result.get()
        XCTAssertEqual(response.token, "tok_xyz")
        XCTAssertEqual(response.forterToken, "forter_abc")
    }

    func testForterTokenAbsentIsNil() throws {
        let result = parseTokenizeResponse(["method": "tokenize", "data": "{\"token\":\"tok_xyz\"}"])
        let response = try result.get()
        XCTAssertNil(response.forterToken)
    }

    func testParsesNestedObjectData() throws {
        let result = parseTokenizeResponse([
            "method": "tokenize",
            "data": ["token": "tok_obj", "expMonth": "11", "expYear": "2029"]
        ])
        let response = try result.get()
        XCTAssertEqual(response.token, "tok_obj")
        XCTAssertEqual(response.expMonth, "11")
    }

    func testErrorPrefixedStringBecomesTokenizationFailed() {
        let result = parseTokenizeResponse(["method": "tokenize", "data": "ERROR Card declined"])
        assertFailure(result, message: "Card declined")
    }

    func testMalformedJsonStringBecomesInvalidResponse() {
        let result = parseTokenizeResponse(["method": "tokenize", "data": "{not-json"])
        assertFailure(result, message: "Invalid response")
    }

    func testMissingDataBecomesInvalidResponse() {
        let result = parseTokenizeResponse(["method": "tokenize"])
        assertFailure(result, message: "Invalid response")
    }

    func testMissingTokenFieldYieldsEmptyToken() throws {
        let result = parseTokenizeResponse(["method": "tokenize", "data": "{\"expMonth\":\"01\"}"])
        let response = try result.get()
        XCTAssertEqual(response.token, "")
        XCTAssertEqual(response.expMonth, "01")
    }
}
