import SwiftUI
import SwiftData

@main
struct VelraApp: App {
    @StateObject private var container = DependencyContainer()
    @StateObject private var appCoordinator: AppCoordinator

    init() {
        let container = DependencyContainer()
        _container = StateObject(wrappedValue: container)
        _appCoordinator = StateObject(wrappedValue: AppCoordinator(container: container))
    }

    var body: some Scene {
        WindowGroup {
            RootView(container: container, appCoordinator: appCoordinator)
                .modelContainer(container.persistenceController.modelContainer)
        }
    }
}

struct RootView: View {
    @ObservedObject var container: DependencyContainer
    @ObservedObject var appCoordinator: AppCoordinator

    var body: some View {
        Group {
            if appCoordinator.isAuthenticated {
                MainTabView(container: container, appCoordinator: appCoordinator)
            } else {
                AuthFlowView(container: container, appCoordinator: appCoordinator)
            }
        }
        .task {
            await appCoordinator.checkAuthStatus()
        }
    }
}

struct AuthFlowView: View {
    @ObservedObject var container: DependencyContainer
    @ObservedObject var appCoordinator: AppCoordinator
    @StateObject private var authCoordinator: AuthCoordinator

    init(container: DependencyContainer, appCoordinator: AppCoordinator) {
        self.container = container
        self.appCoordinator = appCoordinator
        _authCoordinator = StateObject(wrappedValue: container.makeAuthCoordinator())
    }

    var body: some View {
        NavigationStack(path: $authCoordinator.path) {
            LoginView(
                viewModel: container.makeLoginViewModel(coordinator: authCoordinator)
            )
            .navigationDestination(for: AuthRoute.self) { route in
                switch route {
                case .register:
                    RegisterView(
                        viewModel: container.makeRegisterViewModel(coordinator: authCoordinator)
                    )
                case .login:
                    LoginView(
                        viewModel: container.makeLoginViewModel(coordinator: authCoordinator)
                    )
                }
            }
        }
        .onChange(of: authCoordinator.isAuthenticated) { _, newValue in
            if newValue {
                appCoordinator.didAuthenticate()
            }
        }
    }
}

struct MainTabView: View {
    @ObservedObject var container: DependencyContainer
    @ObservedObject var appCoordinator: AppCoordinator

    var body: some View {
        TabView(selection: $appCoordinator.selectedTab) {
            ProductsTabView(container: container)
                .tabItem {
                    Label("Products", systemImage: "bag")
                }
                .tag(AppTab.products)

            CartTabView(container: container)
                .tabItem {
                    Label("Cart", systemImage: "cart")
                }
                .tag(AppTab.cart)

            OrdersTabView(container: container)
                .tabItem {
                    Label("Orders", systemImage: "shippingbox")
                }
                .tag(AppTab.orders)

            ProfileTabView(appCoordinator: appCoordinator)
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
                .tag(AppTab.profile)
        }
    }
}

struct ProductsTabView: View {
    @ObservedObject var container: DependencyContainer
    @StateObject private var coordinator: ProductCoordinator

    init(container: DependencyContainer) {
        self.container = container
        _coordinator = StateObject(wrappedValue: container.makeProductCoordinator())
    }

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            ProductListView(
                viewModel: container.makeProductListViewModel(coordinator: coordinator)
            )
            .navigationDestination(for: ProductRoute.self) { route in
                switch route {
                case .detail(let productId):
                    ProductDetailView(
                        viewModel: container.makeProductDetailViewModel(productId: productId)
                    )
                }
            }
        }
    }
}

struct CartTabView: View {
    @ObservedObject var container: DependencyContainer
    @StateObject private var coordinator: CartCoordinator

    init(container: DependencyContainer) {
        self.container = container
        _coordinator = StateObject(wrappedValue: container.makeCartCoordinator())
    }

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            CartView(
                viewModel: container.makeCartViewModel(coordinator: coordinator)
            )
            .navigationDestination(for: CartRoute.self) { route in
                switch route {
                case .checkout:
                    CheckoutView(
                        viewModel: container.makeCheckoutViewModel()
                    )
                }
            }
        }
    }
}

struct OrdersTabView: View {
    @ObservedObject var container: DependencyContainer
    @StateObject private var coordinator: OrderCoordinator

    init(container: DependencyContainer) {
        self.container = container
        _coordinator = StateObject(wrappedValue: container.makeOrderCoordinator())
    }

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            OrderHistoryView(
                viewModel: container.makeOrderHistoryViewModel(coordinator: coordinator)
            )
            .navigationDestination(for: OrderRoute.self) { route in
                switch route {
                case .detail(let orderId):
                    OrderDetailView(
                        viewModel: container.makeOrderDetailViewModel(orderId: orderId)
                    )
                }
            }
        }
    }
}

struct ProfileTabView: View {
    @ObservedObject var appCoordinator: AppCoordinator

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(.blue)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("My Account")
                                .font(.headline)
                            Text("Manage your profile")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }

                Section("Settings") {
                    Label("Notifications", systemImage: "bell")
                    Label("Privacy", systemImage: "lock")
                    Label("Help & Support", systemImage: "questionmark.circle")
                    Label("About", systemImage: "info.circle")
                }

                Section {
                    Button(role: .destructive) {
                        Task {
                            await appCoordinator.logout()
                        }
                    } label: {
                        Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }
}
