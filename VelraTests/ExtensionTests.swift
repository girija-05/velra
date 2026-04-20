import XCTest
@testable import Velra

final class ExtensionTests: XCTestCase {

    func testEmailValidation() {
        XCTAssertTrue("user@example.com".isValidEmail)
        XCTAssertTrue("user.name@domain.co".isValidEmail)
        XCTAssertTrue("user+tag@example.com".isValidEmail)

        XCTAssertFalse("".isValidEmail)
        XCTAssertFalse("invalid".isValidEmail)
        XCTAssertFalse("@example.com".isValidEmail)
        XCTAssertFalse("user@".isValidEmail)
        XCTAssertFalse("user@.com".isValidEmail)
    }

    func testPasswordStrength() {
        XCTAssertTrue("password123".isStrongPassword)
        XCTAssertTrue("12345678".isStrongPassword)
        XCTAssertTrue("abcdefgh".isStrongPassword)

        XCTAssertFalse("".isStrongPassword)
        XCTAssertFalse("short".isStrongPassword)
        XCTAssertFalse("1234567".isStrongPassword)
    }

    func testFormattedPrice() {
        let price = 199.99
        let formatted = price.formattedPrice
        XCTAssertTrue(formatted.contains("199.99") || formatted.contains("199,99"))
    }

    func testCentsToDollars() {
        let cents = 5000
        let formatted = cents.formattedCentsToDollars
        XCTAssertTrue(formatted.contains("50.00") || formatted.contains("50,00"))
    }

    func testFormattedDate() {
        let date = Date()
        let formatted = date.formattedDate
        XCTAssertFalse(formatted.isEmpty)
    }

    func testRelativeFormatted() {
        let date = Date()
        let formatted = date.relativeFormatted
        XCTAssertFalse(formatted.isEmpty)
    }
}
