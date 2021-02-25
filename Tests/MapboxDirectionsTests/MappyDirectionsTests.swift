import XCTest
@testable import MapboxDirections

class MappyDirectionsTests: XCTestCase {
    func testDecoding() {
        var errorJSON: [String: Any] = [
            "status": 400,
            "message": "No QID provided (None)"
        ]
        var errorData = try! JSONSerialization.data(withJSONObject: errorJSON, options: [])
        var mappyServerError: MappyServerError?
        XCTAssertNoThrow(mappyServerError = try JSONDecoder().decode(MappyServerError.self, from: errorData))
        XCTAssertNotNil(mappyServerError)
        if let serverError = mappyServerError {
            XCTAssertEqual(serverError.status, 400)
            XCTAssertEqual(serverError.message, errorJSON["message"] as! String)
            XCTAssertEqual(serverError.errorId, "no id")
        }

        errorJSON = ["status": 502,
                     "message": "Could not find GPS initial route",
                     "id": "GPS:find_initial_route"]
        errorData = try! JSONSerialization.data(withJSONObject: errorJSON, options: [])
        XCTAssertNoThrow(mappyServerError = try JSONDecoder().decode(MappyServerError.self, from: errorData))
        XCTAssertNotNil(mappyServerError)
        if let serverError = mappyServerError {
            XCTAssertEqual(serverError.status, 502)
            XCTAssertEqual(serverError.message, errorJSON["message"] as! String)
            XCTAssertEqual(serverError.errorId, errorJSON["id"] as! String)
        }
    }

}
