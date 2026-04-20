import Foundation

enum AuthEndpoint: APIEndpoint {
    case login(email: String, password: String)
    case register(name: String, email: String, password: String)

    var path: String {
        switch self {
        case .login:
            return "/auth/login"
        case .register:
            return "/auth/register"
        }
    }

    var method: HTTPMethod {
        .post
    }

    var body: Data? {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        switch self {
        case .login(let email, let password):
            let payload = LoginRequest(email: email, password: password)
            return try? encoder.encode(payload)
        case .register(let name, let email, let password):
            let payload = RegisterRequest(name: name, email: email, password: password)
            return try? encoder.encode(payload)
        }
    }
}

struct LoginRequest: Encodable, Sendable {
    let email: String
    let password: String
}

struct RegisterRequest: Encodable, Sendable {
    let name: String
    let email: String
    let password: String
}
