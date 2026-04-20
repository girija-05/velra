import Foundation
import SwiftData

@Model
final class CartItemModel {
    @Attribute(.unique) var productId: String
    var name: String
    var price: Double
    var quantity: Int
    var imageURL: String?
    var addedAt: Date

    init(
        productId: String,
        name: String,
        price: Double,
        quantity: Int,
        imageURL: String? = nil,
        addedAt: Date = Date()
    ) {
        self.productId = productId
        self.name = name
        self.price = price
        self.quantity = quantity
        self.imageURL = imageURL
        self.addedAt = addedAt
    }

    var subtotal: Double {
        price * Double(quantity)
    }
}

struct CartItem: Sendable, Identifiable, Hashable {
    let id: String
    let productId: String
    let name: String
    let price: Double
    var quantity: Int
    let imageURL: String?

    var subtotal: Double {
        price * Double(quantity)
    }

    init(from model: CartItemModel) {
        self.id = model.productId
        self.productId = model.productId
        self.name = model.name
        self.price = model.price
        self.quantity = model.quantity
        self.imageURL = model.imageURL
    }

    init(
        productId: String,
        name: String,
        price: Double,
        quantity: Int,
        imageURL: String? = nil
    ) {
        self.id = productId
        self.productId = productId
        self.name = name
        self.price = price
        self.quantity = quantity
        self.imageURL = imageURL
    }
}
