import SwiftUI

struct CartView: View {
    @StateObject private var viewModel: CartViewModel

    init(viewModel: CartViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Group {
            if viewModel.isEmpty {
                emptyCartView
            } else {
                cartContent
            }
        }
        .navigationTitle("Cart")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if !viewModel.isEmpty {
                    Button("Clear") {
                        viewModel.clearCart()
                    }
                    .foregroundStyle(.red)
                }
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
        .onAppear {
            viewModel.loadCart()
        }
    }

    private var emptyCartView: some View {
        ContentUnavailableView(
            "Your Cart is Empty",
            systemImage: "cart",
            description: Text("Add products to your cart to see them here.")
        )
    }

    private var cartContent: some View {
        VStack(spacing: 0) {
            List {
                ForEach(viewModel.items) { item in
                    CartItemRow(
                        item: item,
                        onUpdateQuantity: { quantity in
                            viewModel.updateQuantity(productId: item.productId, quantity: quantity)
                        },
                        onRemove: {
                            viewModel.removeItem(productId: item.productId)
                        }
                    )
                }
            }
            .listStyle(.plain)

            checkoutFooter
        }
    }

    private var checkoutFooter: some View {
        VStack(spacing: 12) {
            Divider()

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total (\(viewModel.itemCount) items)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(viewModel.formattedTotal)
                        .font(.title2)
                        .fontWeight(.bold)
                }

                Spacer()

                Button {
                    viewModel.proceedToCheckout()
                } label: {
                    Text("Checkout")
                        .fontWeight(.semibold)
                        .padding(.horizontal, 32)
                        .frame(height: Constants.UI.buttonHeight)
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: Constants.UI.cornerRadius))
                }
            }
            .padding(.horizontal, Constants.UI.horizontalPadding)
            .padding(.bottom, 8)
        }
        .background(Color(.systemBackground))
    }
}

struct CartItemRow: View {
    let item: CartItem
    let onUpdateQuantity: (Int) -> Void
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            itemImage

            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)

                Text(item.price.formattedPrice)
                    .font(.subheadline)
                    .foregroundStyle(.blue)

                quantityControls
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(item.subtotal.formattedPrice)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Button(role: .destructive) {
                    onRemove()
                } label: {
                    Image(systemName: "trash")
                        .font(.caption)
                }
            }
        }
        .padding(.vertical, 4)
    }

    private var itemImage: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray6))

            if let imageURL = item.imageURL, let url = URL(string: imageURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    default:
                        Image(systemName: "bag")
                            .foregroundStyle(.secondary)
                    }
                }
            } else {
                Image(systemName: "bag")
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 60, height: 60)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var quantityControls: some View {
        HStack(spacing: 12) {
            Button {
                onUpdateQuantity(item.quantity - 1)
            } label: {
                Image(systemName: "minus.circle")
                    .foregroundStyle(item.quantity > 1 ? .blue : .gray)
            }
            .disabled(item.quantity <= 1)

            Text("\(item.quantity)")
                .font(.subheadline)
                .fontWeight(.medium)

            Button {
                onUpdateQuantity(item.quantity + 1)
            } label: {
                Image(systemName: "plus.circle")
                    .foregroundStyle(.blue)
            }
        }
    }
}
