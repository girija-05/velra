import SwiftUI

struct RegisterView: View {
    @StateObject private var viewModel: RegisterViewModel

    init(viewModel: RegisterViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                headerSection
                formSection
                registerButton
                loginLink
            }
            .padding(.horizontal, Constants.UI.horizontalPadding)
            .padding(.top, 40)
        }
        .navigationTitle("Create Account")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "person.badge.plus")
                .font(.system(size: 50))
                .foregroundStyle(.blue)

            Text("Join Velra")
                .font(.title2)
                .fontWeight(.bold)

            Text("Create your account to start shopping")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var formSection: some View {
        VStack(spacing: Constants.UI.verticalSpacing) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Full Name")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                TextField("John Doe", text: $viewModel.name)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.name)
                    .autocapitalization(.words)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Email")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                TextField("your@email.com", text: $viewModel.email)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Password")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                SecureField("At least 8 characters", text: $viewModel.password)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.newPassword)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Confirm Password")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                SecureField("Re-enter your password", text: $viewModel.confirmPassword)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.newPassword)
            }
        }
    }

    private var registerButton: some View {
        Button {
            Task {
                await viewModel.register()
            }
        } label: {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Create Account")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: Constants.UI.buttonHeight)
            .background(viewModel.isFormValid ? Color.blue : Color.blue.opacity(0.5))
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: Constants.UI.cornerRadius))
        }
        .disabled(viewModel.isLoading)
    }

    private var loginLink: some View {
        HStack {
            Text("Already have an account?")
                .foregroundStyle(.secondary)
            Button("Sign In") {
                viewModel.navigateBack()
            }
            .fontWeight(.semibold)
        }
        .font(.subheadline)
    }
}
