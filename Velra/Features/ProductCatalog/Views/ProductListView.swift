import SwiftUI

struct ProductListView: View {
    @StateObject private var viewModel: ProductListViewModel

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    init(viewModel: ProductListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(viewModel.filteredProducts) { product in
                    ProductCardView(product: product) {
                        viewModel.navigateToDetail(productId: product.id)
                    }
                    .onAppear {
                        if product.id == viewModel.filteredProducts.last?.id {
                            Task {
                                await viewModel.loadMoreProducts()
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, Constants.UI.horizontalPadding)
            .padding(.top, 8)

            if viewModel.isLoadingMore {
                ProgressView()
                    .padding()
            }
        }
        .searchable(text: $viewModel.searchText, prompt: "Search products")
        .navigationTitle("Products")
        .refreshable {
            await viewModel.refresh()
        }
        .overlay {
            if viewModel.isLoading && viewModel.products.isEmpty {
                ProgressView("Loading products...")
            } else if viewModel.filteredProducts.isEmpty && !viewModel.isLoading {
                emptyStateView
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("Retry") {
                Task { await viewModel.loadProducts() }
            }
            Button("OK", role: .cancel) {}
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
        .task {
            if viewModel.products.isEmpty {
                await viewModel.loadProducts()
            }
        }
    }

    private var emptyStateView: some View {
        ContentUnavailableView(
            "No Products Found",
            systemImage: "bag.badge.questionmark",
            description: Text(
                viewModel.searchText.isEmpty
                    ? "Products will appear here once available."
                    : "No products match your search."
            )
        )
    }
}

struct ProductCardView: View {
    let product: Product
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                productImage
                productInfo
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: Constants.UI.cornerRadius))
            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }

    private var productImage: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Constants.UI.cornerRadius)
                .fill(Color(.systemGray6))

            if let imageURL = product.imageURL, let url = URL(string: imageURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                    case .empty:
                        ProgressView()
                    @unknown default:
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                    }
                }
            } else {
                Image(systemName: "bag")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(height: 160)
        .clipShape(RoundedRectangle(cornerRadius: Constants.UI.cornerRadius))
    }

    private var productInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(product.name)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(2)
                .foregroundStyle(.primary)

            Text(product.formattedPrice)
                .font(.headline)
                .foregroundStyle(.blue)

            if let rating = product.rating {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundStyle(.yellow)
                    Text(String(format: "%.1f", rating))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 8)
    }
}
