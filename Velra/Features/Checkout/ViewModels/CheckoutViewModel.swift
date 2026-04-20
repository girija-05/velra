import Foundation
import SwiftUI

@MainActor
final class CheckoutViewModel: ObservableObject {
    @Published var cartItems: [CartItem] = []
    @Published var isProcessing = false
    @Published var paymentStatus: PaymentStatus = .idle
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var completedOrder: Order?

    private let cartService: CartRepositoryProtocol
    private let orderService: OrderRepositoryProtocol
    private let paymentService: PaymentRepositoryProtocol
    private let stripeService: StripePaymentServiceProtocol

    init(
        cartService: CartRepositoryProtocol,
        orderService: OrderRepositoryProtocol,
        paymentService: PaymentRepositoryProtocol,
        stripeService: StripePaymentServiceProtocol
    ) {
        self.cartService = cartService
        self.orderService = orderService
        self.paymentService = paymentService
        self.stripeService = stripeService
    }

    var totalAmount: Double {
        cartItems.reduce(0) { $0 + $1.subtotal }
    }

    var formattedTotal: String {
        totalAmount.formattedPrice
    }

    var totalAmountInCents: Int {
        Int((totalAmount * 100).rounded())
    }

    func loadCartItems() {
        do {
            cartItems = try cartService.fetchCartItems()
        } catch {
            errorMessage = "Failed to load cart items."
            showError = true
        }
    }

    func processCheckout() async {
        guard !cartItems.isEmpty else {
            errorMessage = "Your cart is empty."
            showError = true
            return
        }

        isProcessing = true
        paymentStatus = .processing
        errorMessage = nil

        do {
            let orderItems = cartItems.map { item in
                OrderItemRequest(productId: item.productId, quantity: item.quantity)
            }
            let order = try await orderService.createOrder(items: orderItems)

            let paymentIntent = try await paymentService.createPaymentIntent(
                orderId: order.id,
                amount: totalAmountInCents,
                currency: "usd"
            )

            let success = await stripeService.processPayment(
                clientSecret: paymentIntent.clientSecret
            )

            if success {
                paymentStatus = .succeeded
                completedOrder = order
                try? cartService.clearCart()
                cartItems = []
            } else {
                paymentStatus = .failed
                errorMessage = "Payment was not completed. Please try again."
                showError = true
            }
        } catch let error as APIError {
            paymentStatus = .failed
            errorMessage = error.errorDescription
            showError = true
        } catch {
            paymentStatus = .failed
            errorMessage = error.localizedDescription
            showError = true
        }

        isProcessing = false
    }
}
