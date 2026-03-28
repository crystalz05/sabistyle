# SabiStyle

A premium, feature-rich eCommerce application built with Flutter. SabiStyle offers a seamless shopping experience with elegant UI, dynamic animations, and robust functionality ranging from product discovery to secure checkout.

## 📱 Features

- **Authentication:** Secure user login, registration, and password recovery via Supabase.
- **Product Discovery:** Browse featured products, new arrivals, and category-specific items.
- **Smart Search & Filtering:** Filter products by price, category, and sorting preferences, with recent search history.
- **Shopping Cart & Checkout:** Intuitive cart management with promo code support, integrated address selection, and secure Paystack payment processing.
- **Wishlist:** Save and manage favorite items.
- **Order Management:** Track active, processing, shipped, and delivered orders with a clean grouped UI.
- **Real-time Notifications:** In-app notification center for order updates, promos, and account activities via Supabase Realtime.
- **Premium UI/UX:** Dark mode support, skeleton loading states (Shimmer), and standardized non-floating snackbar feedback for a native, premium feel.

## 🛠 Tech Stack

- **Framework:** [Flutter](https://flutter.dev/) (Dart)
- **State Management:** [BLoC](https://pub.dev/packages/flutter_bloc) (Business Logic Component) pattern
- **Routing:** [go_router](https://pub.dev/packages/go_router) for deep linking and screen-guarding
- **Backend as a Service:** [Supabase](https://supabase.com/) (Auth, PostgreSQL DB, Realtime)
- **Payment Gateway:** Paystack
- **Architecture:** Clean Architecture (Domain, Data, and Presentation layers)

## 📁 Project Structure

The project follows a modular, feature-based Clean Architecture:

```text
lib/
├── app.dart                   # Root material app configuration
├── app_router.dart            # GoRouter configuration & guards
├── injection_container.dart   # Service locator (GetIt) setup
└── features/
    ├── auth/                  # Login, Signup, Password reset
    ├── cart/                  # Cart management & summary
    ├── checkout/              # Addresses, Shipping, Paystack integration
    ├── home/                  # Home dashboard & Market discovery
    ├── market/                # Product details, search & listing
    ├── notifications/         # Notification inbox & real-time listeners
    ├── orders/                # Order history and tracking
    ├── profile/               # User account management
    ├── settings/              # App preferences & legal docs
    ├── widgets/               # Reusable UI components (AppShimmer, AppEmptyState, etc.)
    └── wishlist/              # Saved items
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (latest stable)
- Dart SDK
- [Supabase](https://supabase.com/) Account & Project credentials
- [Paystack](https://paystack.com/) API Keys

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/sabistyle.git
   cd sabistyle
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Environment Setup:**
   Configure your environment variables by updating or creating `lib/core/config/app_config.dart`:
   ```dart
   class AppConfig {
     static const supabaseUrl = 'YOUR_SUPABASE_PROJECT_URL';
     static const supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
     static const paystackPublicKey = 'YOUR_PAYSTACK_PUBLIC_KEY';
     static const paystackInitUrl = '$supabaseUrl/functions/v1/paystack-initialize';
   }
   ```

4. **Run the App:**
   ```bash
   flutter run
   ```

## 🎨 UI Guidelines

SabiStyle enforces a standardized UI palette and behavior:
- **Color Scheme:** Deep Purple & Gold premium palette. 
- **Feedback:** Uses `AppSnackBar` anchored to the bottom instead of floating.
- **Loading:** Uses `AppShimmer` skeleton loaders instead of basic circular progress indicators on data-heavy screens.
- **Empty States:** Centralized `AppEmptyState` widget is used across all list views (Cart, Orders, Wishlist).

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
