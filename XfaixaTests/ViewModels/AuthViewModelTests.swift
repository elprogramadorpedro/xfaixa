import Foundation
import Testing
@testable import Xfaixa

@MainActor
struct AuthViewModelTests {

    private let service = MockAuthService()

    private func makeViewModel(mode: AuthViewModel.Mode = .signIn) -> AuthViewModel {
        let viewModel = AuthViewModel(authService: service)
        viewModel.switchMode(to: mode)
        return viewModel
    }

    // MARK: - Sign In

    @Test func signInSucceedsWithValidCredentials() async {
        let viewModel = makeViewModel()
        viewModel.email = "  ana@xfaixa.app "
        viewModel.password = "123456"

        let user = await viewModel.signIn()

        #expect(user == .fixture)
        #expect(service.signInCalls.first?.email == "ana@xfaixa.app")
        #expect(viewModel.isLoading == false)
    }

    @Test func signInDoesNotNagBeforeTheFirstSubmit() {
        let viewModel = makeViewModel()
        viewModel.email = "ana@"

        #expect(viewModel.emailError == nil)
        #expect(viewModel.passwordError == nil)
    }

    @Test func signInValidatesLocallyWithoutCallingTheService() async {
        let viewModel = makeViewModel()
        viewModel.email = "ana@"

        let user = await viewModel.signIn()

        #expect(user == nil)
        #expect(service.signInCalls.isEmpty)
        #expect(viewModel.emailError == "Digite um e-mail válido")
        #expect(viewModel.passwordError == "Informe sua senha")
    }

    @Test func wrongCredentialsAreShownUnderThePassword() async {
        service.signInResult = .failure(.invalidCredentials)
        let viewModel = makeViewModel()
        viewModel.email = "ana@xfaixa.app"
        viewModel.password = "errada"

        let user = await viewModel.signIn()

        #expect(user == nil)
        #expect(viewModel.passwordError == "E-mail ou senha incorretos")
        #expect(viewModel.generalError == nil)
    }

    @Test func networkFailuresAreShownAsAGeneralError() async {
        service.signInResult = .failure(.networkUnavailable)
        let viewModel = makeViewModel()
        viewModel.email = "ana@xfaixa.app"
        viewModel.password = "123456"

        _ = await viewModel.signIn()

        #expect(viewModel.generalError == AuthError.networkUnavailable.message)
        #expect(viewModel.emailError == nil)
    }

    @Test func editingAFieldClearsTheServerError() async {
        service.signInResult = .failure(.invalidCredentials)
        let viewModel = makeViewModel()
        viewModel.email = "ana@xfaixa.app"
        viewModel.password = "errada"
        _ = await viewModel.signIn()

        viewModel.password = "errada2"

        #expect(viewModel.serverError == nil)
        #expect(viewModel.passwordError == nil)
    }

    // MARK: - Sign Up

    @Test func signUpValidatesWhileTyping() {
        let viewModel = makeViewModel(mode: .signUp)
        viewModel.email = "ana@xfaixa"
        viewModel.password = "123"
        viewModel.confirmPassword = "12"

        #expect(viewModel.emailError == "Digite um e-mail válido")
        #expect(viewModel.passwordError == "A senha precisa ter pelo menos 6 caracteres")
        #expect(viewModel.confirmPasswordError == "As senhas não coincidem")
        #expect(viewModel.canSubmitSignUp == false)
    }

    @Test func signUpIsEnabledOnceEveryRulePasses() {
        let viewModel = makeViewModel(mode: .signUp)
        viewModel.email = "ana@xfaixa.app"
        viewModel.password = "123456"
        viewModel.confirmPassword = "123456"

        #expect(viewModel.emailError == nil)
        #expect(viewModel.passwordError == nil)
        #expect(viewModel.confirmPasswordError == nil)
        #expect(viewModel.canSubmitSignUp)
    }

    @Test func signUpSucceedsWithAValidForm() async {
        let viewModel = makeViewModel(mode: .signUp)
        viewModel.email = "ana@xfaixa.app"
        viewModel.password = "123456"
        viewModel.confirmPassword = "123456"

        let user = await viewModel.signUp()

        #expect(user == .fixture)
        #expect(service.signUpCalls.count == 1)
    }

    @Test func invalidSignUpFormNeverReachesTheService() async {
        let viewModel = makeViewModel(mode: .signUp)
        viewModel.email = "ana@xfaixa.app"
        viewModel.password = "123456"
        viewModel.confirmPassword = "654321"

        let user = await viewModel.signUp()

        #expect(user == nil)
        #expect(service.signUpCalls.isEmpty)
    }

    @Test func emailAlreadyInUseIsShownUnderTheEmail() async {
        service.signUpResult = .failure(.emailAlreadyInUse)
        let viewModel = makeViewModel(mode: .signUp)
        viewModel.email = "ana@xfaixa.app"
        viewModel.password = "123456"
        viewModel.confirmPassword = "123456"

        _ = await viewModel.signUp()

        #expect(viewModel.emailError == "Este e-mail já está cadastrado")
    }

    @Test func switchingModeResetsPasswordsAndErrors() async {
        let viewModel = makeViewModel()
        viewModel.email = "ana@"
        viewModel.password = "123"
        _ = await viewModel.signIn()

        viewModel.switchMode(to: .signUp)

        #expect(viewModel.email == "ana@")
        #expect(viewModel.password.isEmpty)
        #expect(viewModel.passwordError == nil)
    }

    // MARK: - Password Reset

    @Test func resetIsPrefilledWithTheEmailAlreadyTyped() {
        let viewModel = makeViewModel()
        viewModel.email = " ana@xfaixa.app "

        viewModel.prepareReset()

        #expect(viewModel.resetEmail == "ana@xfaixa.app")
        #expect(viewModel.resetState == .idle)
    }

    @Test func resetRejectsAnInvalidEmail() async {
        let viewModel = makeViewModel()
        viewModel.resetEmail = "ana"

        await viewModel.sendPasswordReset()

        #expect(viewModel.resetError == "Digite um e-mail válido")
        #expect(service.resetEmails.isEmpty)
    }

    @Test func resetConfirmsWhenTheLinkIsSent() async {
        let viewModel = makeViewModel()
        viewModel.resetEmail = "ana@xfaixa.app"

        await viewModel.sendPasswordReset()

        #expect(viewModel.resetState == .sent)
        #expect(service.resetEmails == ["ana@xfaixa.app"])
    }

    @Test func resetFailureLetsTheUserTryAgain() async {
        service.resetResult = .failure(.tooManyRequests)
        let viewModel = makeViewModel()
        viewModel.resetEmail = "ana@xfaixa.app"

        await viewModel.sendPasswordReset()

        #expect(viewModel.resetState == .idle)
        #expect(viewModel.resetError == AuthError.tooManyRequests.message)
    }
}
