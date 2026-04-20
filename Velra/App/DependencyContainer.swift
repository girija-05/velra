import Foundation
import SwiftData

@MainActor
final class DependencyContainer: ObservableObject {
    let tokenManager: TokenManager
    let keychainManager: KeychainManager
    let apiClient: APIClient
    let persistenceController: PersistenceController

    let authService: AuthRepositoryProtocol
    let productService: ProductRepositoryProtocol
    let cartService: CartRepositoryProtocol
    let orderService: OrderRepositoryProtocol
    let paymentService: PaymentRepositoryProtocol
    let stripeService: StripePaymentServiceProtocol
    let pushNotificationManager: PushNotificationManager

    init() {
        self.keychainManager = KeychainManager.shared
        self.tokenManager = TokenManager(keychainManager: keychainManager)
        self.apiClient = APIClient(tokenManager: tokenManager)
        self.persistenceController = PersistenceController.shared
        self.pushNotificationManager = PushNotificationManager.shared

        self.authService = AuthService(apiClient: apiClient, tokenManager: tokenManager)
        self.productService = ProductService(apiClient: apiClient)
        self.cartService = CartService(
            modelContext: persistenceController.modelContainer.mainContext
        )
        self.orderService = OrderService(apiClient: apiClient)
        self.paymentService = PaymentService(apiClient: apiClient)

        let stripe = StripePaymentService()
        stripe.configure(publishableKey: AppConfiguration.shared.stripePublishableKey)
        self.stripeService = stripe
    }

    // MARK: - Coordinator Factories

    func makeAuthCoordinator() -> AuthCoordinator {
        AuthCoordinator(authService: authService)
    }

    func makeProductCoordinator() -> ProductCoordinator {
        ProductCoordinator()
    }

    func makeCartCoordinator() -> CartCoordinator {
        CartCoordinator()
    }

    func makeCheckoutCoordinator() -> CheckoutCoordinator {
        CheckoutCoordinator()
    }

    func makeOrderCoordinator() -> OrderCoordinator {
        OrderCoordinator()
    }

    // MARK: - ViewModel Factories

    func makeLoginViewModel(coordinator: AuthCoordinator) -> LoginViewModel {
        LoginViewModel(authService: authService, coordinator: coordinator)
    }

    func makeRegisterViewModel(coordinator: AuthCoordinator) -> RegisterViewModel {
        RegisterViewModel(authService: authService, coordinator: coordinator)
    }

    func makeProductListViewModel(coordinator: ProductCoordinator) -> ProductListViewModel {
        ProductListViewModel(productService: productService, coordinator: coordinator)
    }

    func makeProductDetailViewModel(productId: String) -> ProductDetailViewModel {
        ProductDetailViewModel(
            productId: productId,
            productService: productService,
            cartService: cartService
        )
    }

    func makeCartViewModel(coordinator: CartCoordinator) -> CartViewModel {
        CartViewModel(cartService: cartService, coordinator: coordinator)
    }

    func makeCheckoutViewModel() -> CheckoutViewModel {
        CheckoutViewModel(
            cartService: cartService,
            orderService: orderService,
            paymentService: paymentService,
            stripeService: stripeService
        )
    }

    func makeOrderHistoryViewModel(coordinator: OrderCoordinator) -> OrderHistoryViewModel {
        OrderHistoryViewModel(orderService: orderService, coordinator: coordinator)
    }

    func makeOrderDetailViewModel(orderId: String) -> OrderDetailViewModel {
        OrderDetailViewModel(orderId: orderId, orderService: orderService)
    }
}
