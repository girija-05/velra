import SwiftUI

struct OrderHistoryView: View {
    @StateObject private var viewModel: OrderHistoryViewModel

    init(viewModel: OrderHistoryViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Group {
            if viewModel.orders.isEmpty && !viewModel.isLoading {
                emptyStateView
            } else {
                orderList
            }
        }
        .navigationTitle("Orders")
        .refreshable {
            await viewModel.refresh()
        }
        .overlay {
            if viewModel.isLoading && viewModel.orders.isEmpty {
                ProgressView("Loading orders...")
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("Retry") {
                Task { await viewModel.loadOrders() }
            }
            Button("OK", role: .cancel) {}
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
        .task {
            if viewModel.orders.isEmpty {
                await viewModel.loadOrders()
            }
        }
    }

    private var emptyStateView: some View {
        ContentUnavailableView(
            "No Orders Yet",
            systemImage: "shippingbox",
            description: Text("Your order history will appear here.")
        )
    }

    private var orderList: some View {
        List(viewModel.orders) { order in
            OrderRow(order: order) {
                viewModel.navigateToDetail(orderId: order.id)
            }
        }
        .listStyle(.plain)
    }
}

struct OrderRow: View {
    let order: Order
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: order.status.iconName)
                    .font(.title2)
                    .foregroundStyle(statusColor)
                    .frame(width: 40)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Order #\(order.id.prefix(8))")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)

                    Text(order.status.displayName)
                        .font(.caption)
                        .foregroundStyle(statusColor)

                    if let date = order.createdAt {
                        Text(date.formattedDate)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(order.formattedTotal)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)

                    Text("\(order.items.count) items")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }

    private var statusColor: Color {
        switch order.status {
        case .pending: return .orange
        case .confirmed: return .blue
        case .processing: return .purple
        case .shipped: return .cyan
        case .delivered: return .green
        case .cancelled: return .red
        }
    }
}
