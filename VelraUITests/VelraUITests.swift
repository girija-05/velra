import XCTest

final class VelraUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func testLoginScreenElements() throws {
        let velraTitle = app.staticTexts["Velra"]
        XCTAssertTrue(velraTitle.waitForExistence(timeout: 5))

        let emailField = app.textFields["your@email.com"]
        XCTAssertTrue(emailField.exists)

        let passwordField = app.secureTextFields["Enter your password"]
        XCTAssertTrue(passwordField.exists)

        let signInButton = app.buttons["Sign In"]
        XCTAssertTrue(signInButton.exists)

        let signUpButton = app.buttons["Sign Up"]
        XCTAssertTrue(signUpButton.exists)
    }

    func testNavigateToRegisterScreen() throws {
        let signUpButton = app.buttons["Sign Up"]
        XCTAssertTrue(signUpButton.waitForExistence(timeout: 5))
        signUpButton.tap()

        let joinVelraText = app.staticTexts["Join Velra"]
        XCTAssertTrue(joinVelraText.waitForExistence(timeout: 5))

        let nameField = app.textFields["John Doe"]
        XCTAssertTrue(nameField.exists)

        let createAccountButton = app.buttons["Create Account"]
        XCTAssertTrue(createAccountButton.exists)
    }

    func testRegisterScreenNavigateBack() throws {
        let signUpButton = app.buttons["Sign Up"]
        XCTAssertTrue(signUpButton.waitForExistence(timeout: 5))
        signUpButton.tap()

        let signInLink = app.buttons["Sign In"]
        XCTAssertTrue(signInLink.waitForExistence(timeout: 5))
        signInLink.tap()

        let velraTitle = app.staticTexts["Velra"]
        XCTAssertTrue(velraTitle.waitForExistence(timeout: 5))
    }

    func testLoginFormValidation() throws {
        let signInButton = app.buttons["Sign In"]
        XCTAssertTrue(signInButton.waitForExistence(timeout: 5))

        let emailField = app.textFields["your@email.com"]
        emailField.tap()
        emailField.typeText("invalid-email")

        let passwordField = app.secureTextFields["Enter your password"]
        passwordField.tap()
        passwordField.typeText("short")

        signInButton.tap()

        let errorAlert = app.alerts["Error"]
        XCTAssertTrue(errorAlert.waitForExistence(timeout: 5))
    }
}
