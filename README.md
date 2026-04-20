# Velra - E-Commerce iOS Application

A production-grade, scalable e-commerce iOS application built with SwiftUI, following MVVM-C architecture.

## Overview

Velra is a full-featured e-commerce app with authentication, product catalog, shopping cart, checkout with Stripe payments, and order management.

## Requirements

- **Xcode**: 15.0+
- **iOS**: 16.0+
- **Swift**: 5.9 (with strict concurrency checks enabled)
- **Dependencies**: Managed via Swift Package Manager

## Tech Stack

| Category | Technology |
|---|---|
| UI Framework | SwiftUI |
| Architecture | MVVM-C (Model-View-ViewModel + Coordinator) |
| Navigation | NavigationStack with Coordinators |
| Concurrency | Swift Concurrency (async/await, Actors) |
| Persistence | SwiftData |
| Networking | URLSession with async/await |
| Payments | Stripe iOS SDK (StripePaymentSheet) |
| Push Notifications | Apple Push Notification service (APNs) |
| Security | Keychain for token storage |
| Dependency Management | Swift Package Manager |

## Project Structure

```
Velra/
├── App/
│   ├── VelraApp.swift              # App entry point
│   ├── AppCoordinator.swift        # Root coordinator & tab management
│   └── DependencyContainer.swift   # Dependency injection container
├── Core/
│   ├── Configuration/
│   │   └── AppConfiguration.swift  # Environment & API configuration
│   ├── Networking/
│   │   ├── APIClient.swift         # Strongly typed API client actor
│   │   ├── APIEndpoint.swift       # Endpoint protocol
│   │   ├── APIError.swift          # Error types
│   │   ├── HTTPMethod.swift        # HTTP method enum
│   │   ├── AuthEndpoint.swift      # Auth API endpoints
│   │   ├── ProductEndpoint.swift   # Product API endpoints
│   │   ├── CartEndpoint.swift      # Cart API endpoints
│   │   ├── OrderEndpoint.swift     # Order API endpoints
│   │   └── PaymentEndpoint.swift   # Payment API endpoints
│   ├── Security/
│   │   ├── KeychainManager.swift   # Keychain access actor
│   │   └── TokenManager.swift      # JWT token management actor
│   ├── Storage/
│   │   └── PersistenceController.swift  # SwiftData container
│   └── Utilities/
│       ├── Constants.swift         # App-wide constants
│       └── Extensions.swift        # Swift extensions
├── Domain/
│   ├── Models/
│   │   ├── User.swift              # User & AuthResponse models
│   │   ├── Product.swift           # Product & PaginatedResponse
│   │   ├── CartItem.swift          # CartItem & SwiftData model
│   │   ├── Order.swift             # Order, OrderItem, OrderStatus
│   │   └── PaymentIntent.swift     # Payment intent models
│   ├── Repositories/
│   │   ├── AuthRepositoryProtocol.swift
│   │   ├── ProductRepositoryProtocol.swift
│   │   ├── CartRepositoryProtocol.swift
│   │   ├── OrderRepositoryProtocol.swift
│   │   └── PaymentRepositoryProtocol.swift
│   └── Services/
│       ├── AuthService.swift
│       ├── ProductService.swift
│       ├── CartService.swift       # SwiftData-backed cart
│       ├── OrderService.swift
│       └── PaymentService.swift
├── Features/
│   ├── Authentication/
│   │   ├── Coordinator/AuthCoordinator.swift
│   │   ├── ViewModels/LoginViewModel.swift
│   │   ├── ViewModels/RegisterViewModel.swift
│   │   ├── Views/LoginView.swift
│   │   └── Views/RegisterView.swift
│   ├── ProductCatalog/
│   │   ├── Coordinator/ProductCoordinator.swift
│   │   ├── ViewModels/ProductListViewModel.swift
│   │   ├── ViewModels/ProductDetailViewModel.swift
│   │   ├── Views/ProductListView.swift
│   │   └── Views/ProductDetailView.swift
│   ├── Cart/
│   │   ├── Coordinator/CartCoordinator.swift
│   │   ├── ViewModels/CartViewModel.swift
│   │   └── Views/CartView.swift
│   ├── Checkout/
│   │   ├── Coordinator/CheckoutCoordinator.swift
│   │   ├── ViewModels/CheckoutViewModel.swift
│   │   └── Views/CheckoutView.swift
│   └── Orders/
│       ├── Coordinator/OrderCoordinator.swift
│       ├── ViewModels/OrderHistoryViewModel.swift
│       ├── ViewModels/OrderDetailViewModel.swift
│       ├── Views/OrderHistoryView.swift
│       └── Views/OrderDetailView.swift
├── Integrations/
│   ├── StripePaymentService/
│   │   └── StripePaymentService.swift
│   └── PushNotificationManager/
│       └── PushNotificationManager.swift
└── Resources/
    ├── Assets.xcassets/
    └── Preview Content/

VelraTests/
├── APIClientTests.swift
├── ModelTests.swift
├── ExtensionTests.swift
└── CartServiceTests.swift

VelraUITests/
├── VelraUITests.swift
└── VelraUITestsLaunchTests.swift
```

## Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/girija-05/velra.git
cd velra
```

### 2. Open in Xcode

```bash
open Velra.xcodeproj
```

### 3. Resolve Swift Packages

Xcode will automatically resolve Swift Package Manager dependencies (Stripe iOS SDK). If not, go to **File > Packages > Resolve Package Versions**.

### 4. Configure API Base URL

Edit `Velra/Core/Configuration/AppConfiguration.swift` and update the `apiBaseURL` to point to your backend server.

### 5. Configure Stripe

Set your Stripe publishable key in `AppConfiguration.swift`:
- For development: Update the `stripePublishableKey` in the `#if DEBUG` block
- For production: Update the `stripePublishableKey` in the `#else` block

> **Important**: Never hardcode secret keys in source code. Use environment variables or a secure configuration system for the Stripe secret key on your backend.

### 6. Build and Run

Select a simulator or device target, then press `Cmd + R` to build and run.

## API Endpoints

The app expects the following backend endpoints:

| Method | Endpoint | Description |
|---|---|---|
| POST | `/auth/login` | User login |
| POST | `/auth/register` | User registration |
| GET | `/products` | Product list (paginated) |
| GET | `/products/{id}` | Product detail |
| POST | `/cart` | Add to cart |
| POST | `/orders` | Create order |
| POST | `/payments/create-intent` | Create Stripe payment intent |

## Architecture

### MVVM-C Pattern

- **Model**: Domain models and data layer
- **View**: SwiftUI views (declarative UI)
- **ViewModel**: Business logic and state management (`@MainActor`, `ObservableObject`)
- **Coordinator**: Navigation management using `NavigationStack` and `NavigationPath`

### Dependency Injection

`DependencyContainer` acts as the composition root, creating and injecting all services, repositories, coordinators, and view models.

### Concurrency

The app uses Swift Concurrency exclusively:
- `actor` for thread-safe shared state (`APIClient`, `KeychainManager`, `TokenManager`)
- `async/await` for all asynchronous operations
- `@MainActor` for UI-bound classes
- `Sendable` conformance throughout

### Security

- JWT tokens stored in iOS Keychain via `KeychainManager` actor
- No secrets hardcoded in source code
- Secure token lifecycle management

## Testing

### Run Unit Tests

```bash
xcodebuild test \
  -project Velra.xcodeproj \
  -scheme Velra \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -only-testing:VelraTests
```

### Run UI Tests

```bash
xcodebuild test \
  -project Velra.xcodeproj \
  -scheme Velra \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -only-testing:VelraUITests
```

## Build

```bash
xcodebuild build \
  -project Velra.xcodeproj \
  -scheme Velra \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -configuration Debug
```

## Features

- **Authentication**: Login & registration with JWT token management
- **Product Catalog**: Paginated product grid with search, detail view with images and ratings
- **Shopping Cart**: Add/remove products, quantity management, SwiftData persistence
- **Checkout**: Stripe payment integration with PaymentSheet
- **Order History**: View past orders with status tracking and details
- **Push Notifications**: Native APNs integration
- **Profile**: Account management and settings

## License

Copyright © 2024 Velra Technologies. All rights reserved.
