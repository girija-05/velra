import Foundation

enum APIError: Error, Sendable, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int, data: Data)
    case decodingError(Error)
    case encodingError(Error)
    case networkError(Error)
    case unauthorized
    case notFound
    case serverError
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL is invalid."
        case .invalidResponse:
            return "The server response is invalid."
        case .httpError(let statusCode, _):
            return "HTTP error with status code \(statusCode)."
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .encodingError(let error):
            return "Failed to encode request: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .unauthorized:
            return "Authentication required. Please log in again."
        case .notFound:
            return "The requested resource was not found."
        case .serverError:
            return "A server error occurred. Please try again later."
        case .unknown:
            return "An unknown error occurred."
        }
    }

    static func fromHTTPStatusCode(_ statusCode: Int, data: Data) -> APIError {
        switch statusCode {
        case 401:
            return .unauthorized
        case 404:
            return .notFound
        case 500...599:
            return .serverError
        default:
            return .httpError(statusCode: statusCode, data: data)
        }
    }
}
