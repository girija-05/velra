import Foundation

actor APIClient {
    private let session: URLSession
    private let baseURL: URL
    private let tokenManager: TokenManager
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init(
        baseURL: URL = AppConfiguration.shared.apiBaseURL,
        tokenManager: TokenManager,
        session: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.tokenManager = tokenManager
        self.session = session

        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase

        self.encoder = JSONEncoder()
        self.encoder.dateEncodingStrategy = .iso8601
        self.encoder.keyEncodingStrategy = .convertToSnakeCase
    }

    func request<T: Decodable & Sendable>(
        endpoint: some APIEndpoint,
        responseType: T.Type
    ) async throws -> T {
        let token = await tokenManager.accessToken
        let urlRequest = try endpoint.buildURLRequest(baseURL: baseURL, authToken: token)

        let (data, response) = try await performRequest(urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            if httpResponse.statusCode == 401 {
                await tokenManager.clearTokens()
            }
            throw APIError.fromHTTPStatusCode(httpResponse.statusCode, data: data)
        }

        do {
            let decoded = try decoder.decode(T.self, from: data)
            return decoded
        } catch {
            throw APIError.decodingError(error)
        }
    }

    func requestWithoutResponse(endpoint: some APIEndpoint) async throws {
        let token = await tokenManager.accessToken
        let urlRequest = try endpoint.buildURLRequest(baseURL: baseURL, authToken: token)

        let (data, response) = try await performRequest(urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            if httpResponse.statusCode == 401 {
                await tokenManager.clearTokens()
            }
            throw APIError.fromHTTPStatusCode(httpResponse.statusCode, data: data)
        }
    }

    func encode<T: Encodable>(_ value: T) throws -> Data {
        do {
            return try encoder.encode(value)
        } catch {
            throw APIError.encodingError(error)
        }
    }

    private func performRequest(_ request: URLRequest) async throws -> (Data, URLResponse) {
        do {
            return try await session.data(for: request)
        } catch {
            throw APIError.networkError(error)
        }
    }
}
