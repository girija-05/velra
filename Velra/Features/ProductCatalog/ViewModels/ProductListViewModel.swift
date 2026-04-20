import Foundation
import SwiftUI

@MainActor
final class ProductListViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var searchText = ""

    private let productService: ProductRepositoryProtocol
    private let coordinator: ProductCoordinator
    private var currentPage = 1
    private var totalPages = 1
    private let pageSize = Constants.API.defaultPageSize

    init(productService: ProductRepositoryProtocol, coordinator: ProductCoordinator) {
        self.productService = productService
        self.coordinator = coordinator
    }

    var filteredProducts: [Product] {
        if searchText.isEmpty {
            return products
        }
        return products.filter { product in
            product.name.localizedCaseInsensitiveContains(searchText)
                || product.description.localizedCaseInsensitiveContains(searchText)
        }
    }

    var canLoadMore: Bool {
        currentPage < totalPages && !isLoadingMore
    }

    func loadProducts() async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil
        currentPage = 1

        do {
            let response = try await productService.fetchProducts(page: currentPage, limit: pageSize)
            products = response.items
            totalPages = response.totalPages
        } catch let error as APIError {
            errorMessage = error.errorDescription
            showError = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }

        isLoading = false
    }

    func loadMoreProducts() async {
        guard canLoadMore, !isLoadingMore else { return }

        isLoadingMore = true
        currentPage += 1

        do {
            let response = try await productService.fetchProducts(page: currentPage, limit: pageSize)
            products.append(contentsOf: response.items)
            totalPages = response.totalPages
        } catch {
            currentPage -= 1
        }

        isLoadingMore = false
    }

    func navigateToDetail(productId: String) {
        coordinator.navigate(to: .detail(productId: productId))
    }

    func refresh() async {
        await loadProducts()
    }
}
