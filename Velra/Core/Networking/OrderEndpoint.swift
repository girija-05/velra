import Foundation

enum OrderEndpoint: APIEndpoint {
    case createOrder(items: [OrderItemRequest])
    case list
    case detail(id: String)

    var path: String {
        switch self {
        case .createOrder, .list:
            return "/orders"
        case .detail(let id):
            return "/orders/\(id)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .createOrder:
            return .post
        case .list, .detail:
            return .get
        }
    }

    var body: Data? {
        switch self {
        case .createOrder(let items):
            let payload = CreateOrderRequest(items: items)
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            return try? encoder.encode(payload)
        case .list, .detail:
            return nil
        }
    }
}

struct OrderItemRequest: Encodable, Sendable {
    let productId: String
    let quantity: Int
}

struct CreateOrderRequest: Encodable, Sendable {
    let items: [OrderItemRequest]
}
