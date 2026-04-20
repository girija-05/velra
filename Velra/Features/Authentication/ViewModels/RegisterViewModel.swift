import Foundation
import SwiftUI

@MainActor
final class RegisterViewModel: ObservableObject {
    @Published var name = ""
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
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
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && email.isValidEmail
            && password.isStrongPassword
            && password == confirmPassword
    }

    func register() async {
        guard isFormValid else {
            showValidationError()
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            _ = try await authService.register(
                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                email: email,
                password: password
            )
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

    func navigateBack() {
        coordinator.pop()
    }

    private func showValidationError() {
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "Please enter your name."
        } else if !email.isValidEmail {
            errorMessage = "Please enter a valid email address."
        } else if !password.isStrongPassword {
            errorMessage = "Password must be at least 8 characters."
        } else if password != confirmPassword {
            errorMessage = "Passwords do not match."
        }
        showError = true
    }
}
