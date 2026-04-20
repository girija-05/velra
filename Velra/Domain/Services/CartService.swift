import Foundation
import SwiftData

@MainActor
final class CartService: CartRepositoryProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchCartItems() throws -> [CartItem] {
        let descriptor = FetchDescriptor<CartItemModel>(
            sortBy: [SortDescriptor(\.addedAt, order: .reverse)]
        )
        let models = try modelContext.fetch(descriptor)
        return models.map { CartItem(from: $0) }
    }

    func addItem(_ item: CartItem) throws {
        let productId = item.productId
        var descriptor = FetchDescriptor<CartItemModel>(
            predicate: #Predicate<CartItemModel> { model in
                model.productId == productId
            }
        )
        descriptor.fetchLimit = 1

        let existing = try modelContext.fetch(descriptor)

        if let existingItem = existing.first {
            existingItem.quantity += item.quantity
        } else {
            let model = CartItemModel(
                productId: item.productId,
                name: item.name,
                price: item.price,
                quantity: item.quantity,
                imageURL: item.imageURL
            )
            modelContext.insert(model)
        }

        try modelContext.save()
    }

    func updateItemQuantity(productId: String, quantity: Int) throws {
        var descriptor = FetchDescriptor<CartItemModel>(
            predicate: #Predicate<CartItemModel> { model in
                model.productId == productId
            }
        )
        descriptor.fetchLimit = 1

        let results = try modelContext.fetch(descriptor)

        if let item = results.first {
            if quantity <= 0 {
                modelContext.delete(item)
            } else {
                item.quantity = quantity
            }
            try modelContext.save()
        }
    }

    func removeItem(productId: String) throws {
        var descriptor = FetchDescriptor<CartItemModel>(
            predicate: #Predicate<CartItemModel> { model in
                model.productId == productId
            }
        )
        descriptor.fetchLimit = 1

        let results = try modelContext.fetch(descriptor)

        if let item = results.first {
            modelContext.delete(item)
            try modelContext.save()
        }
    }

    func clearCart() throws {
        let descriptor = FetchDescriptor<CartItemModel>()
        let items = try modelContext.fetch(descriptor)
        for item in items {
            modelContext.delete(item)
        }
        try modelContext.save()
    }

    func cartTotal() throws -> Double {
        let items = try fetchCartItems()
        return items.reduce(0) { $0 + $1.subtotal }
    }
}
