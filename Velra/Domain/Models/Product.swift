import Foundation

struct Product: Codable, Sendable, Identifiable, Hashable {
    let id: String
    let name: String
    let description: String
    let price: Double
    let imageURL: String?
    let category: String?
    let stock: Int
    let rating: Double?
    let reviewCount: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case price
        case imageURL = "imageUrl"
        case category
        case stock
        case rating
        case reviewCount
    }

    var isInStock: Bool {
        stock > 0
    }

    var formattedPrice: String {
        price.formattedPrice
    }
}

struct PaginatedResponse<T: Codable & Sendable>: Codable, Sendable {
    let items: [T]
    let page: Int
    let totalPages: Int
    let totalItems: Int

    enum CodingKeys: String, CodingKey {
        case items
        case page
        case totalPages
        case totalItems
    }
}
