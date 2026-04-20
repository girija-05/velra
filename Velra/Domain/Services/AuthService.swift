import Foundation

final class AuthService: AuthRepositoryProtocol, Sendable {
    private let apiClient: APIClient
    private let tokenManager: TokenManager

    init(apiClient: APIClient, tokenManager: TokenManager) {
        self.apiClient = apiClient
        self.tokenManager = tokenManager
    }

    func login(email: String, password: String) async throws -> AuthResponse {
        let endpoint = AuthEndpoint.login(email: email, password: password)
        let response = try await apiClient.request(
            endpoint: endpoint,
            responseType: AuthResponse.self
        )
        try await tokenManager.storeTokens(
            accessToken: response.accessToken,
            refreshToken: response.refreshToken
        )
        return response
    }

    func register(name: String, email: String, password: String) async throws -> AuthResponse {
        let endpoint = AuthEndpoint.register(name: name, email: email, password: password)
        let response = try await apiClient.request(
            endpoint: endpoint,
            responseType: AuthResponse.self
        )
        try await tokenManager.storeTokens(
            accessToken: response.accessToken,
            refreshToken: response.refreshToken
        )
        return response
    }

    func logout() async {
        await tokenManager.clearTokens()
    }

    func isAuthenticated() async -> Bool {
        await tokenManager.isAuthenticated
    }
}
