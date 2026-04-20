import Foundation

protocol ProductRepositoryProtocol: Sendable {
    func fetchProducts(page: Int, limit: Int) async throws -> PaginatedResponse<Product>
    func fetchProductDetail(id: String) async throws -> Product
}
