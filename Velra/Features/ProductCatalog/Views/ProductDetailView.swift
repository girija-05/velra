import SwiftUI

struct ProductDetailView: View {
    @StateObject private var viewModel: ProductDetailViewModel

    init(viewModel: ProductDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            if let product = viewModel.product {
                productContent(product)
            }
        }
        .navigationTitle(viewModel.product?.name ?? "Product")
        .navigationBarTitleDisplayMode(.inline)
        .overlay {
            if viewModel.isLoading {
                ProgressView("Loading...")
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
        .overlay(alignment: .top) {
            if viewModel.addedToCart {
                addedToCartBanner
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .animation(.spring(), value: viewModel.addedToCart)
            }
        }
        .task {
            await viewModel.loadProduct()
        }
    }

    private func productContent(_ product: Product) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            productImage(product)
            productDetails(product)
            quantitySelector
            addToCartButton(product)
        }
        .padding(.bottom, 32)
    }

    private func productImage(_ product: Product) -> some View {
        ZStack {
            Rectangle()
                .fill(Color(.systemGray6))

            if let imageURL = product.imageURL, let url = URL(string: imageURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    case .failure:
                        Image(systemName: "photo")
                            .font(.system(size: 60))
                            .foregroundStyle(.secondary)
                    case .empty:
                        ProgressView()
                    @unknown default:
                        Image(systemName: "photo")
                            .font(.system(size: 60))
                            .foregroundStyle(.secondary)
                    }
                }
            } else {
                Image(systemName: "bag")
                    .font(.system(size: 60))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(height: 300)
    }

    private func productDetails(_ product: Product) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(product.name)
                    .font(.title2)
                    .fontWeight(.bold)

                Spacer()

                Text(product.formattedPrice)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.blue)
            }

            if let category = product.category {
                Text(category)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray6))
                    .clipShape(Capsule())
            }

            if let rating = product.rating {
                HStack(spacing: 4) {
                    ForEach(0..<5) { index in
                        Image(systemName: index < Int(rating) ? "star.fill" : "star")
                            .font(.caption)
                            .foregroundStyle(.yellow)
                    }
                    if let reviewCount = product.reviewCount {
                        Text("(\(reviewCount) reviews)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Text(product.description)
                .font(.body)
                .foregroundStyle(.secondary)
                .lineSpacing(4)

            HStack {
                Image(systemName: product.isInStock ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundStyle(product.isInStock ? .green : .red)
                Text(product.isInStock ? "In Stock (\(product.stock) available)" : "Out of Stock")
                    .font(.subheadline)
                    .foregroundStyle(product.isInStock ? .green : .red)
            }
        }
        .padding(.horizontal, Constants.UI.horizontalPadding)
    }

    private var quantitySelector: some View {
        HStack(spacing: 20) {
            Text("Quantity:")
                .font(.headline)

            HStack(spacing: 16) {
                Button {
                    viewModel.decrementQuantity()
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(viewModel.quantity > 1 ? .blue : .gray)
                }
                .disabled(viewModel.quantity <= 1)

                Text("\(viewModel.quantity)")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .frame(minWidth: 30)

                Button {
                    viewModel.incrementQuantity()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.blue)
                }
            }

            Spacer()
        }
        .padding(.horizontal, Constants.UI.horizontalPadding)
    }

    private func addToCartButton(_ product: Product) -> some View {
        Button {
            viewModel.addToCart()
        } label: {
            HStack {
                Image(systemName: "cart.badge.plus")
                Text("Add to Cart")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .frame(height: Constants.UI.buttonHeight)
            .background(product.isInStock ? Color.blue : Color.gray)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: Constants.UI.cornerRadius))
        }
        .disabled(!product.isInStock)
        .padding(.horizontal, Constants.UI.horizontalPadding)
    }

    private var addedToCartBanner: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
            Text("Added to cart")
                .fontWeight(.medium)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.green)
        .foregroundStyle(.white)
    }
}
