import Foundation

enum CartEndpoint: APIEndpoint {
    case addToCart(productId: String, quantity: Int)

    var path: String {
        "/cart"
    }

    var method: HTTPMethod {
        .post
    }

    var body: Data? {
        switch self {
        case .addToCart(let productId, let quantity):
            let payload = AddToCartRequest(productId: productId, quantity: quantity)
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            return try? encoder.encode(payload)
        }
    }
}

struct AddToCartRequest: Encodable, Sendable {
    let productId: String
    let quantity: Int
}
