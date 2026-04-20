import XCTest
@testable import Velra

final class ModelTests: XCTestCase {

    func testProductDecoding() throws {
        let json = """
        {
            "id": "prod-001",
            "name": "Wireless Headphones",
            "description": "Premium noise-cancelling headphones",
            "price": 199.99,
            "image_url": "https://example.com/image.jpg",
            "category": "Electronics",
            "stock": 50,
            "rating": 4.5,
            "review_count": 120
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let product = try decoder.decode(Product.self, from: json)

        XCTAssertEqual(product.id, "prod-001")
        XCTAssertEqual(product.name, "Wireless Headphones")
        XCTAssertEqual(product.price, 199.99)
        XCTAssertEqual(product.stock, 50)
        XCTAssertEqual(product.rating, 4.5)
        XCTAssertTrue(product.isInStock)
    }

    func testProductOutOfStock() throws {
        let json = """
        {
            "id": "prod-002",
            "name": "Sold Out Item",
            "description": "This item is sold out",
            "price": 49.99,
            "stock": 0
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let product = try decoder.decode(Product.self, from: json)

        XCTAssertFalse(product.isInStock)
        XCTAssertEqual(product.stock, 0)
    }

    func testOrderStatusDisplayNames() {
        XCTAssertEqual(OrderStatus.pending.displayName, "Pending")
        XCTAssertEqual(OrderStatus.confirmed.displayName, "Confirmed")
        XCTAssertEqual(OrderStatus.processing.displayName, "Processing")
        XCTAssertEqual(OrderStatus.shipped.displayName, "Shipped")
        XCTAssertEqual(OrderStatus.delivered.displayName, "Delivered")
        XCTAssertEqual(OrderStatus.cancelled.displayName, "Cancelled")
    }

    func testOrderStatusIcons() {
        XCTAssertEqual(OrderStatus.pending.iconName, "clock")
        XCTAssertEqual(OrderStatus.shipped.iconName, "shippingbox")
        XCTAssertEqual(OrderStatus.delivered.iconName, "checkmark.seal")
    }

    func testUserDecoding() throws {
        let json = """
        {
            "id": "user-001",
            "name": "John Doe",
            "email": "john@example.com"
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let user = try decoder.decode(User.self, from: json)

        XCTAssertEqual(user.id, "user-001")
        XCTAssertEqual(user.name, "John Doe")
        XCTAssertEqual(user.email, "john@example.com")
    }

    func testAuthResponseDecoding() throws {
        let json = """
        {
            "user": {
                "id": "user-001",
                "name": "John Doe",
                "email": "john@example.com"
            },
            "access_token": "eyJhbGciOiJIUzI1NiJ9.test",
            "refresh_token": "refresh_token_value"
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let response = try decoder.decode(AuthResponse.self, from: json)

        XCTAssertEqual(response.user.id, "user-001")
        XCTAssertEqual(response.accessToken, "eyJhbGciOiJIUzI1NiJ9.test")
        XCTAssertEqual(response.refreshToken, "refresh_token_value")
    }

    func testCartItemSubtotal() {
        let item = CartItem(
            productId: "prod-001",
            name: "Test Product",
            price: 29.99,
            quantity: 3
        )

        XCTAssertEqual(item.subtotal, 89.97, accuracy: 0.01)
        XCTAssertEqual(item.id, "prod-001")
    }

    func testPaginatedResponseDecoding() throws {
        let json = """
        {
            "items": [
                {
                    "id": "prod-001",
                    "name": "Product 1",
                    "description": "Description 1",
                    "price": 10.00,
                    "stock": 5
                }
            ],
            "page": 1,
            "total_pages": 5,
            "total_items": 100
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let response = try decoder.decode(PaginatedResponse<Product>.self, from: json)

        XCTAssertEqual(response.items.count, 1)
        XCTAssertEqual(response.page, 1)
        XCTAssertEqual(response.totalPages, 5)
        XCTAssertEqual(response.totalItems, 100)
    }

    func testPaymentIntentResponseDecoding() throws {
        let json = """
        {
            "client_secret": "pi_secret_123",
            "payment_intent_id": "pi_123",
            "amount": 5000,
            "currency": "usd"
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let response = try decoder.decode(PaymentIntentResponse.self, from: json)

        XCTAssertEqual(response.clientSecret, "pi_secret_123")
        XCTAssertEqual(response.paymentIntentId, "pi_123")
        XCTAssertEqual(response.amount, 5000)
        XCTAssertEqual(response.currency, "usd")
    }
}
