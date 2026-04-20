import Foundation

@MainActor
protocol CartRepositoryProtocol {
    func fetchCartItems() throws -> [CartItem]
    func addItem(_ item: CartItem) throws
    func updateItemQuantity(productId: String, quantity: Int) throws
    func removeItem(productId: String) throws
    func clearCart() throws
    func cartTotal() throws -> Double
}
