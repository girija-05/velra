import Foundation
import SwiftUI

enum AppTab: Hashable {
    case products
    case cart
    case orders
    case profile
}

@MainActor
final class AppCoordinator: ObservableObject {
    @Published var selectedTab: AppTab = .products
    @Published var isAuthenticated = false

    private let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
    }

    func checkAuthStatus() async {
        isAuthenticated = await container.authService.isAuthenticated()
    }

    func didAuthenticate() {
        isAuthenticated = true
    }

    func logout() async {
        await container.authService.logout()
        isAuthenticated = false
    }
}
