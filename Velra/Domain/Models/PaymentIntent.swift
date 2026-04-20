import Foundation

struct PaymentIntentResponse: Codable, Sendable {
    let clientSecret: String
    let paymentIntentId: String
    let amount: Int
    let currency: String

    enum CodingKeys: String, CodingKey {
        case clientSecret
        case paymentIntentId
        case amount
        case currency
    }
}

enum PaymentStatus: String, Sendable, Hashable {
    case idle
    case processing
    case succeeded
    case failed
    case cancelled
}
