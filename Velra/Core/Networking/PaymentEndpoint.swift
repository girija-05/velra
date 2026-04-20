import Foundation

enum PaymentEndpoint: APIEndpoint {
    case createIntent(orderId: String, amount: Int, currency: String)

    var path: String {
        "/payments/create-intent"
    }

    var method: HTTPMethod {
        .post
    }

    var body: Data? {
        switch self {
        case .createIntent(let orderId, let amount, let currency):
            let payload = CreatePaymentIntentRequest(
                orderId: orderId,
                amount: amount,
                currency: currency
            )
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            return try? encoder.encode(payload)
        }
    }
}

struct CreatePaymentIntentRequest: Encodable, Sendable {
    let orderId: String
    let amount: Int
    let currency: String
}
