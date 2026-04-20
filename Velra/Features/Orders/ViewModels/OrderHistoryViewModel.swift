import Foundation
import SwiftUI

@MainActor
final class OrderHistoryViewModel: ObservableObject {
    @Published var orders: [Order] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false

    private let orderService: OrderRepositoryProtocol
    private let coordinator: OrderCoordinator

    init(orderService: OrderRepositoryProtocol, coordinator: OrderCoordinator) {
        self.orderService = orderService
        self.coordinator = coordinator
    }

    func loadOrders() async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        do {
            orders = try await orderService.fetchOrders()
        } catch let error as APIError {
            errorMessage = error.errorDescription
            showError = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }

        isLoading = false
    }

    func navigateToDetail(orderId: String) {
        coordinator.navigate(to: .detail(orderId: orderId))
    }

    func refresh() async {
        await loadOrders()
    }
}
