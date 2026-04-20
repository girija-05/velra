import XCTest
@testable import Velra

final class APIClientTests: XCTestCase {

    private var tokenManager: TokenManager!
    private var apiClient: APIClient!

    override func setUp() async throws {
        try await super.setUp()
        tokenManager = TokenManager(keychainManager: .shared)
        apiClient = APIClient(
            baseURL: URL(string: "https://api.test.velra.dev")!,
            tokenManager: tokenManager,
            session: URLSession.shared
        )
    }

    override func tearDown() async throws {
        await tokenManager.clearTokens()
        tokenManager = nil
        apiClient = nil
        try await super.tearDown()
    }

    func testAPIErrorDescriptions() {
        let errors: [(APIError, String?)] = [
            (.invalidURL, "The URL is invalid."),
            (.invalidResponse, "The server response is invalid."),
            (.unauthorized, "Authentication required. Please log in again."),
            (.notFound, "The requested resource was not found."),
            (.serverError, "A server error occurred. Please try again later."),
            (.unknown, "An unknown error occurred.")
        ]

        for (error, expectedDescription) in errors {
            XCTAssertEqual(error.errorDescription, expectedDescription)
        }
    }

    func testHTTPStatusCodeMapping() {
        let data = Data()

        let unauthorized = APIError.fromHTTPStatusCode(401, data: data)
        if case .unauthorized = unauthorized {
            // Expected
        } else {
            XCTFail("Expected unauthorized error")
        }

        let notFound = APIError.fromHTTPStatusCode(404, data: data)
        if case .notFound = notFound {
            // Expected
        } else {
            XCTFail("Expected notFound error")
        }

        let serverError = APIError.fromHTTPStatusCode(500, data: data)
        if case .serverError = serverError {
            // Expected
        } else {
            XCTFail("Expected serverError")
        }

        let otherError = APIError.fromHTTPStatusCode(422, data: data)
        if case .httpError(let statusCode, _) = otherError {
            XCTAssertEqual(statusCode, 422)
        } else {
            XCTFail("Expected httpError")
        }
    }

    func testAuthEndpointPaths() {
        let loginEndpoint = AuthEndpoint.login(email: "test@test.com", password: "password")
        XCTAssertEqual(loginEndpoint.path, "/auth/login")
        XCTAssertEqual(loginEndpoint.method, .post)

        let registerEndpoint = AuthEndpoint.register(
            name: "Test",
            email: "test@test.com",
            password: "password"
        )
        XCTAssertEqual(registerEndpoint.path, "/auth/register")
        XCTAssertEqual(registerEndpoint.method, .post)
    }

    func testProductEndpointPaths() {
        let listEndpoint = ProductEndpoint.list(page: 1, limit: 20)
        XCTAssertEqual(listEndpoint.path, "/products")
        XCTAssertEqual(listEndpoint.method, .get)
        XCTAssertEqual(listEndpoint.queryItems?.count, 2)

        let detailEndpoint = ProductEndpoint.detail(id: "123")
        XCTAssertEqual(detailEndpoint.path, "/products/123")
        XCTAssertEqual(detailEndpoint.method, .get)
        XCTAssertNil(detailEndpoint.queryItems)
    }

    func testOrderEndpointPaths() {
        let listEndpoint = OrderEndpoint.list
        XCTAssertEqual(listEndpoint.path, "/orders")
        XCTAssertEqual(listEndpoint.method, .get)

        let detailEndpoint = OrderEndpoint.detail(id: "order-123")
        XCTAssertEqual(detailEndpoint.path, "/orders/order-123")
        XCTAssertEqual(detailEndpoint.method, .get)
    }

    func testPaymentEndpointPath() {
        let endpoint = PaymentEndpoint.createIntent(
            orderId: "order-1",
            amount: 5000,
            currency: "usd"
        )
        XCTAssertEqual(endpoint.path, "/payments/create-intent")
        XCTAssertEqual(endpoint.method, .post)
        XCTAssertNotNil(endpoint.body)
    }
}
