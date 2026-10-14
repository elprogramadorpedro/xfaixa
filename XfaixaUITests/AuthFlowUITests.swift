import XCTest

final class AuthFlowUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testWrongPasswordShowsAnErrorUnderTheField() throws {
        let app = launchApp()

        signIn(app, email: "demo@xfaixa.app", password: "errada")

        XCTAssertTrue(app.staticTexts["E-mail ou senha incorretos"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testDemoAccountReachesSearch() throws {
        let app = launchApp()

        signIn(app, email: "demo@xfaixa.app", password: "123456")

        XCTAssertTrue(app.staticTexts["O que vamos ouvir hoje?"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.buttons["Bossa Nova"].exists)
    }

    @MainActor
    func testCreateAccountLinkOpensSignUp() throws {
        let app = launchApp()
        let createAccount = app.buttons["Criar conta"]
        XCTAssertTrue(createAccount.waitForExistence(timeout: 8))

        createAccount.tap()

        XCTAssertTrue(app.textFields["E-mail"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.secureTextFields["Confirmar senha"].exists)
    }

    // MARK: - Private Helpers

    @MainActor
    private func launchApp() -> XCUIApplication {
        let app = XCUIApplication()
        // Keeps UI tests deterministic: the app swaps Firebase for its in-memory auth with the demo account.
        app.launchArguments = ["-ui-testing"]
        app.launch()
        return app
    }

    @MainActor
    private func signIn(_ app: XCUIApplication, email: String, password: String) {
        let emailField = app.textFields["E-mail"]
        // The splash runs first, so give it time to hand over to the login screen.
        XCTAssertTrue(emailField.waitForExistence(timeout: 8))
        emailField.tap()
        emailField.typeText(email)

        let passwordField = app.secureTextFields["Senha"]
        passwordField.tap()
        passwordField.typeText(password)

        app.buttons["Entrar"].firstMatch.tap()
    }
}
