import Foundation

enum AppEnvironment: String, Sendable {
    case development
    case staging
    case production
}

struct AppConfiguration: Sendable {
    let environment: AppEnvironment
    let apiBaseURL: URL
    let stripePublishableKey: String

    static let shared: AppConfiguration = {
        #if DEBUG
        return AppConfiguration(
            environment: .development,
            apiBaseURL: URL(string: "https://api.velra.dev")!,  // swiftlint:disable:this force_unwrapping
            stripePublishableKey: ""
        )
        #else
        return AppConfiguration(
            environment: .production,
            apiBaseURL: URL(string: "https://api.velra.com")!,  // swiftlint:disable:this force_unwrapping
            stripePublishableKey: ""
        )
        #endif
    }()

    var isDebug: Bool {
        environment == .development
    }
}
