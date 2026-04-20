import Foundation
import SwiftUI

enum CartRoute: Hashable {
    case checkout
}

@MainActor
final class CartCoordinator: ObservableObject {
    @Published var path = NavigationPath()

    func navigate(to route: CartRoute) {
        path.append(route)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path = NavigationPath()
    }
}
