import Foundation

struct User: Codable, Sendable, Identifiable, Hashable {
    let id: String
    let name: String
    let email: String
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case createdAt
    }
}

struct AuthResponse: Codable, Sendable {
    let user: User
    let accessToken: String
    let refreshToken: String?

    enum CodingKeys: String, CodingKey {
        case user
        case accessToken
        case refreshToken
    }
}
