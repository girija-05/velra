import Foundation

enum ProductEndpoint: APIEndpoint {
    case list(page: Int, limit: Int)
    case detail(id: String)

    var path: String {
        switch self {
        case .list:
            return "/products"
        case .detail(let id):
            return "/products/\(id)"
        }
    }

    var method: HTTPMethod {
        .get
    }

    var queryItems: [URLQueryItem]? {
        switch self {
        case .list(let page, let limit):
            return [
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "limit", value: String(limit))
            ]
        case .detail:
            return nil
        }
    }
}
