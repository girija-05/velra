import Foundation
import SwiftUI

enum CheckoutRoute: Hashable {
    case paymentConfirmation(orderId: String)
}

@MainActor
final class CheckoutCoordinator: ObservableObject {
    @Published var path = NavigationPath()
    @Published var shouldDismiss = false

    func navigate(to route: CheckoutRoute) {
        path.append(route)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func dismiss() {
        shouldDismiss = true
    }
}
