import Foundation
import StripePaymentSheet

@MainActor
protocol StripePaymentServiceProtocol {
    func configure(publishableKey: String)
    func processPayment(clientSecret: String) async -> Bool
}

@MainActor
final class StripePaymentService: StripePaymentServiceProtocol {
    private var paymentSheet: PaymentSheet?

    func configure(publishableKey: String) {
        STPAPIClient.shared.publishableKey = publishableKey
    }

    func processPayment(clientSecret: String) async -> Bool {
        var configuration = PaymentSheet.Configuration()
        configuration.merchantDisplayName = "Velra"
        configuration.allowsDelayedPaymentMethods = false

        paymentSheet = PaymentSheet(
            paymentIntentClientSecret: clientSecret,
            configuration: configuration
        )

        return await withCheckedContinuation { continuation in
            guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootViewController = scene.windows.first?.rootViewController else {
                continuation.resume(returning: false)
                return
            }

            var topController = rootViewController
            while let presented = topController.presentedViewController {
                topController = presented
            }

            paymentSheet?.present(from: topController) { result in
                switch result {
                case .completed:
                    continuation.resume(returning: true)
                case .canceled:
                    continuation.resume(returning: false)
                case .failed:
                    continuation.resume(returning: false)
                }
            }
        }
    }
}
