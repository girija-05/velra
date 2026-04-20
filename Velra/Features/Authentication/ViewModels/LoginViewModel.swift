import Foundation
import SwiftUI

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false

    private let authService: AuthRepositoryProtocol
    private let coordinator: AuthCoordinator

    init(authService: AuthRepositoryProtocol, coordinator: AuthCoordinator) {
        self.authService = authService
        self.coordinator = coordinator
    }

    var isFormValid: Bool {
        email.isValidEmail && password.isStrongPassword
    }

    func login() async {
        guard isFormValid else {
            showValidationError()
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            _ = try await authService.login(email: email, password: password)
            coordinator.didAuthenticate()
        } catch let error as APIError {
            errorMessage = error.errorDescription
            showError = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }

        isLoading = false
    }

    func navigateToRegister() {
        coordinator.navigate(to: .register)
    }

    private func showValidationError() {
        if !email.isValidEmail {
            errorMessage = "Please enter a valid email address."
        } else if !password.isStrongPassword {
            errorMessage = "Password must be at least 8 characters."
        }
        showError = true
    }
}
