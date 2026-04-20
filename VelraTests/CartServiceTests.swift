import XCTest
import SwiftData
@testable import Velra

@MainActor
final class CartServiceTests: XCTestCase {

    private var cartService: CartService!
    private var modelContainer: ModelContainer!

    override func setUp() async throws {
        try await super.setUp()
        modelContainer = PersistenceController.createPreviewContainer()
        cartService = CartService(modelContext: modelContainer.mainContext)
    }

    override func tearDown() async throws {
        cartService = nil
        modelContainer = nil
        try await super.tearDown()
    }

    func testAddItem() throws {
        let item = CartItem(
            productId: "prod-001",
            name: "Test Product",
            price: 29.99,
            quantity: 1
        )

        try cartService.addItem(item)
        let items = try cartService.fetchCartItems()

        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items.first?.productId, "prod-001")
        XCTAssertEqual(items.first?.name, "Test Product")
        XCTAssertEqual(items.first?.price, 29.99)
        XCTAssertEqual(items.first?.quantity, 1)
    }

    func testAddDuplicateItemIncrementsQuantity() throws {
        let item = CartItem(
            productId: "prod-001",
            name: "Test Product",
            price: 29.99,
            quantity: 1
        )

        try cartService.addItem(item)
        try cartService.addItem(item)

        let items = try cartService.fetchCartItems()
        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items.first?.quantity, 2)
    }

    func testUpdateQuantity() throws {
        let item = CartItem(
            productId: "prod-001",
            name: "Test Product",
            price: 29.99,
            quantity: 1
        )

        try cartService.addItem(item)
        try cartService.updateItemQuantity(productId: "prod-001", quantity: 5)

        let items = try cartService.fetchCartItems()
        XCTAssertEqual(items.first?.quantity, 5)
    }

    func testUpdateQuantityToZeroRemovesItem() throws {
        let item = CartItem(
            productId: "prod-001",
            name: "Test Product",
            price: 29.99,
            quantity: 1
        )

        try cartService.addItem(item)
        try cartService.updateItemQuantity(productId: "prod-001", quantity: 0)

        let items = try cartService.fetchCartItems()
        XCTAssertTrue(items.isEmpty)
    }

    func testRemoveItem() throws {
        let item = CartItem(
            productId: "prod-001",
            name: "Test Product",
            price: 29.99,
            quantity: 1
        )

        try cartService.addItem(item)
        try cartService.removeItem(productId: "prod-001")

        let items = try cartService.fetchCartItems()
        XCTAssertTrue(items.isEmpty)
    }

    func testClearCart() throws {
        let item1 = CartItem(productId: "prod-001", name: "Product 1", price: 10.0, quantity: 1)
        let item2 = CartItem(productId: "prod-002", name: "Product 2", price: 20.0, quantity: 2)

        try cartService.addItem(item1)
        try cartService.addItem(item2)

        var items = try cartService.fetchCartItems()
        XCTAssertEqual(items.count, 2)

        try cartService.clearCart()

        items = try cartService.fetchCartItems()
        XCTAssertTrue(items.isEmpty)
    }

    func testCartTotal() throws {
        let item1 = CartItem(productId: "prod-001", name: "Product 1", price: 10.0, quantity: 2)
        let item2 = CartItem(productId: "prod-002", name: "Product 2", price: 25.0, quantity: 1)

        try cartService.addItem(item1)
        try cartService.addItem(item2)

        let total = try cartService.cartTotal()
        XCTAssertEqual(total, 45.0, accuracy: 0.01)
    }
}
