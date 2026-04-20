import Foundation

final class ProductService: ProductRepositoryProtocol, Sendable {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func fetchProducts(page: Int, limit: Int) async throws -> PaginatedResponse<Product> {
        let endpoint = ProductEndpoint.list(page: page, limit: limit)
        return try await apiClient.request(
            endpoint: endpoint,
            responseType: PaginatedResponse<Product>.self
        )
    }

    func fetchProductDetail(id: String) async throws -> Product {
        let endpoint = ProductEndpoint.detail(id: id)
        return try await apiClient.request(
            endpoint: endpoint,
            responseType: Product.self
        )
    }
}
