import Foundation

final class OrderService: OrderRepositoryProtocol, Sendable {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func createOrder(items: [OrderItemRequest]) async throws -> Order {
        let endpoint = OrderEndpoint.createOrder(items: items)
        return try await apiClient.request(
            endpoint: endpoint,
            responseType: Order.self
        )
    }

    func fetchOrders() async throws -> [Order] {
        let endpoint = OrderEndpoint.list
        return try await apiClient.request(
            endpoint: endpoint,
            responseType: [Order].self
        )
    }

    func fetchOrderDetail(id: String) async throws -> Order {
        let endpoint = OrderEndpoint.detail(id: id)
        return try await apiClient.request(
            endpoint: endpoint,
            responseType: Order.self
        )
    }
}
