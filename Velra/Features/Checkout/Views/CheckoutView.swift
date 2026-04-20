import SwiftUI

struct CheckoutView: View {
    @StateObject private var viewModel: CheckoutViewModel

    init(viewModel: CheckoutViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Group {
            switch viewModel.paymentStatus {
            case .succeeded:
                orderConfirmationView
            default:
                checkoutContent
            }
        }
        .navigationTitle("Checkout")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
        .onAppear {
            viewModel.loadCartItems()
        }
    }

    private var checkoutContent: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    orderSummarySection
                    itemsSection
                }
                .padding(.horizontal, Constants.UI.horizontalPadding)
                .padding(.top, 16)
            }

            paymentButton
        }
    }

    private var orderSummarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Order Summary")
                .font(.headline)

            VStack(spacing: 8) {
                HStack {
                    Text("Items (\(viewModel.cartItems.count))")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(viewModel.formattedTotal)
                }

                Divider()

                HStack {
                    Text("Total")
                        .font(.headline)
                    Spacer()
                    Text(viewModel.formattedTotal)
                        .font(.headline)
                        .foregroundStyle(.blue)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: Constants.UI.cornerRadius))
        }
    }

    private var itemsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Items")
                .font(.headline)

            ForEach(viewModel.cartItems) { item in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.name)
                            .font(.subheadline)
                        Text("Qty: \(item.quantity)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Text(item.subtotal.formattedPrice)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .padding(.vertical, 4)

                if item.id != viewModel.cartItems.last?.id {
                    Divider()
                }
            }
        }
    }

    private var paymentButton: some View {
        VStack(spacing: 12) {
            Divider()

            Button {
                Task {
                    await viewModel.processCheckout()
                }
            } label: {
                Group {
                    if viewModel.isProcessing {
                        HStack(spacing: 8) {
                            ProgressView()
                                .tint(.white)
                            Text("Processing...")
                        }
                    } else {
                        HStack {
                            Image(systemName: "creditcard")
                            Text("Pay \(viewModel.formattedTotal)")
                        }
                    }
                }
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .frame(height: Constants.UI.buttonHeight)
                .background(Color.blue)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: Constants.UI.cornerRadius))
            }
            .disabled(viewModel.isProcessing || viewModel.cartItems.isEmpty)
            .padding(.horizontal, Constants.UI.horizontalPadding)
            .padding(.bottom, 8)
        }
        .background(Color(.systemBackground))
    }

    private var orderConfirmationView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 80))
                .foregroundStyle(.green)

            Text("Payment Successful!")
                .font(.title)
                .fontWeight(.bold)

            if let order = viewModel.completedOrder {
                Text("Order #\(order.id)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Text("Thank you for your purchase.\nYour order has been placed successfully.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .padding(Constants.UI.horizontalPadding)
    }
}
