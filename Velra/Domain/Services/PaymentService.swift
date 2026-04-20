import Foundation

final class PaymentService: PaymentRepositoryProtocol, Sendable {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func createPaymentIntent(
        orderId: String,
        amount: Int,
        currency: String
    ) async throws -> PaymentIntentResponse {
        let endpoint = PaymentEndpoint.createIntent(
            orderId: orderId,
            amount: amount,
            currency: currency
        )
        return try await apiClient.request(
            endpoint: endpoint,
            responseType: PaymentIntentResponse.self
        )
    }
}
