import SwiftUI

struct OrderDetailView: View {
    @StateObject private var viewModel: OrderDetailViewModel

    init(viewModel: OrderDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            if let order = viewModel.order {
                orderContent(order)
            }
        }
        .navigationTitle("Order Details")
        .navigationBarTitleDisplayMode(.inline)
        .overlay {
            if viewModel.isLoading {
                ProgressView("Loading order...")
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
        .task {
            await viewModel.loadOrder()
        }
    }

    private func orderContent(_ order: Order) -> some View {
        VStack(alignment: .leading, spacing: 24) {
            statusSection(order)
            itemsSection(order)
            totalSection(order)
        }
        .padding(.horizontal, Constants.UI.horizontalPadding)
        .padding(.vertical, 16)
    }

    private func statusSection(_ order: Order) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: order.status.iconName)
                    .font(.title)
                    .foregroundStyle(statusColor(order.status))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Order #\(order.id.prefix(8))")
                        .font(.headline)

                    Text(order.status.displayName)
                        .font(.subheadline)
                        .foregroundStyle(statusColor(order.status))
                }

                Spacer()
            }

            if let date = order.createdAt {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundStyle(.secondary)
                    Text("Placed on \(date.formattedDate)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if let address = order.shippingAddress {
                HStack(alignment: .top) {
                    Image(systemName: "location")
                        .foregroundStyle(.secondary)
                    Text(address)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: Constants.UI.cornerRadius))
    }

    private func itemsSection(_ order: Order) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Items")
                .font(.headline)

            ForEach(order.items) { item in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.productName)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text("Qty: \(item.quantity) x \(item.price.formattedPrice)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Text(item.subtotal.formattedPrice)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .padding(.vertical, 4)

                if item.id != order.items.last?.id {
                    Divider()
                }
            }
        }
    }

    private func totalSection(_ order: Order) -> some View {
        VStack(spacing: 8) {
            Divider()

            HStack {
                Text("Total")
                    .font(.headline)
                Spacer()
                Text(order.formattedTotal)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.blue)
            }
        }
    }

    private func statusColor(_ status: OrderStatus) -> Color {
        switch status {
        case .pending: return .orange
        case .confirmed: return .blue
        case .processing: return .purple
        case .shipped: return .cyan
        case .delivered: return .green
        case .cancelled: return .red
        }
    }
}
