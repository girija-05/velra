import Foundation
import SwiftUI

@MainActor
final class OrderDetailViewModel: ObservableObject {
    @Published var order: Order?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false

    private let orderService: OrderRepositoryProtocol
    private let orderId: String

    init(orderId: String, orderService: OrderRepositoryProtocol) {
        self.orderId = orderId
        self.orderService = orderService
    }

    func loadOrder() async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        do {
            order = try await orderService.fetchOrderDetail(id: orderId)
        } catch let error as APIError {
            errorMessage = error.errorDescription
            showError = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }

        isLoading = false
    }
}
