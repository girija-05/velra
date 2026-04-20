import Foundation

struct Order: Codable, Sendable, Identifiable, Hashable {
    let id: String
    let items: [OrderItem]
    let totalAmount: Double
    let status: OrderStatus
    let createdAt: Date?
    let shippingAddress: String?

    enum CodingKeys: String, CodingKey {
        case id
        case items
        case totalAmount
        case status
        case createdAt
        case shippingAddress
    }

    var formattedTotal: String {
        totalAmount.formattedPrice
    }
}

struct OrderItem: Codable, Sendable, Identifiable, Hashable {
    let id: String
    let productId: String
    let productName: String
    let quantity: Int
    let price: Double

    enum CodingKeys: String, CodingKey {
        case id
        case productId
        case productName
        case quantity
        case price
    }

    var subtotal: Double {
        price * Double(quantity)
    }
}

enum OrderStatus: String, Codable, Sendable, Hashable {
    case pending
    case confirmed
    case processing
    case shipped
    case delivered
    case cancelled

    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .confirmed: return "Confirmed"
        case .processing: return "Processing"
        case .shipped: return "Shipped"
        case .delivered: return "Delivered"
        case .cancelled: return "Cancelled"
        }
    }

    var iconName: String {
        switch self {
        case .pending: return "clock"
        case .confirmed: return "checkmark.circle"
        case .processing: return "gearshape.2"
        case .shipped: return "shippingbox"
        case .delivered: return "checkmark.seal"
        case .cancelled: return "xmark.circle"
        }
    }
}
