import Foundation
import SwiftUI

@MainActor
final class ProductDetailViewModel: ObservableObject {
    @Published var product: Product?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var quantity = 1
    @Published var addedToCart = false

    private let productService: ProductRepositoryProtocol
    private let cartService: CartRepositoryProtocol
    private let productId: String

    init(
        productId: String,
        productService: ProductRepositoryProtocol,
        cartService: CartRepositoryProtocol
    ) {
        self.productId = productId
        self.productService = productService
        self.cartService = cartService
    }

    func loadProduct() async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        do {
            product = try await productService.fetchProductDetail(id: productId)
        } catch let error as APIError {
            errorMessage = error.errorDescription
            showError = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }

        isLoading = false
    }

    func incrementQuantity() {
        guard let product, quantity < product.stock else { return }
        quantity += 1
    }

    func decrementQuantity() {
        guard quantity > 1 else { return }
        quantity -= 1
    }

    func addToCart() {
        guard let product else { return }

        let cartItem = CartItem(
            productId: product.id,
            name: product.name,
            price: product.price,
            quantity: quantity,
            imageURL: product.imageURL
        )

        do {
            try cartService.addItem(cartItem)
            addedToCart = true

            Task {
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                addedToCart = false
            }
        } catch {
            errorMessage = "Failed to add item to cart."
            showError = true
        }
    }
}
