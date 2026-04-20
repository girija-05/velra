import Foundation
import SwiftUI

enum ProductRoute: Hashable {
    case detail(productId: String)
}

@MainActor
final class ProductCoordinator: ObservableObject {
    @Published var path = NavigationPath()

    func navigate(to route: ProductRoute) {
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
