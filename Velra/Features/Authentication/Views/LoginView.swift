import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel: LoginViewModel

    init(viewModel: LoginViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                headerSection
                formSection
                loginButton
                registerLink
            }
            .padding(.horizontal, Constants.UI.horizontalPadding)
            .padding(.top, 60)
        }
        .navigationBarHidden(true)
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
            Image(systemName: "bag.fill")
                .font(.system(size: 60))
                .foregroundStyle(.blue)

            Text("Velra")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Welcome back")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var formSection: some View {
        VStack(spacing: Constants.UI.verticalSpacing) {
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

                SecureField("Enter your password", text: $viewModel.password)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.password)
            }
        }
    }

    private var loginButton: some View {
        Button {
            Task {
                await viewModel.login()
            }
        } label: {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Sign In")
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

    private var registerLink: some View {
        HStack {
            Text("Don't have an account?")
                .foregroundStyle(.secondary)
            Button("Sign Up") {
                viewModel.navigateToRegister()
            }
            .fontWeight(.semibold)
        }
        .font(.subheadline)
    }
}
