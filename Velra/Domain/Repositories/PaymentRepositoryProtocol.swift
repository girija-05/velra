import Foundation

protocol PaymentRepositoryProtocol: Sendable {
    func createPaymentIntent(
        orderId: String,
        amount: Int,
        currency: String
    ) async throws -> PaymentIntentResponse
}
