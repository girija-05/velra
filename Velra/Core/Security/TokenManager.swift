import Foundation

actor TokenManager {
    private let keychainManager: KeychainManager

    private enum Keys {
        static let accessToken = "velra_access_token"
        static let refreshToken = "velra_refresh_token"
    }

    init(keychainManager: KeychainManager = .shared) {
        self.keychainManager = keychainManager
    }

    var accessToken: String? {
        get async {
            try? await keychainManager.loadString(for: Keys.accessToken)
        }
    }

    var refreshToken: String? {
        get async {
            try? await keychainManager.loadString(for: Keys.refreshToken)
        }
    }

    var isAuthenticated: Bool {
        get async {
            let token = await accessToken
            return token != nil
        }
    }

    func storeTokens(accessToken: String, refreshToken: String?) async throws {
        try await keychainManager.save(string: accessToken, for: Keys.accessToken)
        if let refreshToken {
            try await keychainManager.save(string: refreshToken, for: Keys.refreshToken)
        }
    }

    func clearTokens() async {
        try? await keychainManager.delete(key: Keys.accessToken)
        try? await keychainManager.delete(key: Keys.refreshToken)
    }
}
