import Foundation
import SwiftUI

@MainActor
final class CartViewModel: ObservableObject {
    @Published var items: [CartItem] = []
    @Published var errorMessage: String?
    @Published var showError = false

    private let cartService: CartRepositoryProtocol
    private let coordinator: CartCoordinator

    init(cartService: CartRepositoryProtocol, coordinator: CartCoordinator) {
        self.cartService = cartService
        self.coordinator = coordinator
    }

    var totalPrice: Double {
        items.reduce(0) { $0 + $1.subtotal }
    }

    var formattedTotal: String {
        totalPrice.formattedPrice
    }

    var itemCount: Int {
        items.reduce(0) { $0 + $1.quantity }
    }

    var isEmpty: Bool {
        items.isEmpty
    }

    func loadCart() {
        do {
            items = try cartService.fetchCartItems()
        } catch {
            errorMessage = "Failed to load cart items."
            showError = true
        }
    }

    func updateQuantity(productId: String, quantity: Int) {
        do {
            try cartService.updateItemQuantity(productId: productId, quantity: quantity)
            loadCart()
        } catch {
            errorMessage = "Failed to update quantity."
            showError = true
        }
    }

    func removeItem(productId: String) {
        do {
            try cartService.removeItem(productId: productId)
            loadCart()
        } catch {
            errorMessage = "Failed to remove item."
            showError = true
        }
    }

    func clearCart() {
        do {
            try cartService.clearCart()
            items = []
        } catch {
            errorMessage = "Failed to clear cart."
            showError = true
        }
    }

    func proceedToCheckout() {
        coordinator.navigate(to: .checkout)
    }
}
