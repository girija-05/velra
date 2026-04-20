import Foundation

protocol OrderRepositoryProtocol: Sendable {
    func createOrder(items: [OrderItemRequest]) async throws -> Order
    func fetchOrders() async throws -> [Order]
    func fetchOrderDetail(id: String) async throws -> Order
}
