import Foundation
import SwiftUI

enum OrderRoute: Hashable {
    case detail(orderId: String)
}

@MainActor
final class OrderCoordinator: ObservableObject {
    @Published var path = NavigationPath()

    func navigate(to route: OrderRoute) {
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
