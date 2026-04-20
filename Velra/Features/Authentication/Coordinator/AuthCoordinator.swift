import Foundation
import SwiftUI

enum AuthRoute: Hashable {
    case login
    case register
}

@MainActor
final class AuthCoordinator: ObservableObject {
    @Published var path = NavigationPath()
    @Published var isAuthenticated = false

    private let authService: AuthRepositoryProtocol

    init(authService: AuthRepositoryProtocol) {
        self.authService = authService
    }

    func checkAuthStatus() async {
        isAuthenticated = await authService.isAuthenticated()
    }

    func navigate(to route: AuthRoute) {
        path.append(route)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path = NavigationPath()
    }

    func didAuthenticate() {
        isAuthenticated = true
    }

    func didLogout() async {
        await authService.logout()
        isAuthenticated = false
        popToRoot()
    }
}
