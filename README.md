# 🛍️ Shopify — Flutter E-Commerce Catalog App

A modern, production-ready Flutter e-commerce catalog app with Firebase authentication, real-time favorites, product browsing by category, and a clean BLoC architecture.

---

## ✨ Features

- 🔐 **Authentication** — Email/password & Google Sign-In via Firebase Auth
- 🏠 **Home** — Category grid with animated background
- 📦 **Products** — Browse products by category with shimmer loading states
- 🔍 **Search** — Real-time product search with debouncing
- ❤️ **Favorites** — Persistent favorites synced to Firestore
- 👤 **Profile** — User info with settings and sign-out
- 🌗 **Theming** — Custom dark theme with Google Fonts & Material 3

---

## 🏗️ Architecture

The app follows **Clean Architecture** with the **BLoC (Cubit)** pattern:

```
lib/
├── core/
│   ├── constants/       # API endpoints
│   ├── errors/          # Failure types & error mapping
│   ├── routing/         # GoRouter named routes
│   ├── theme/           # Colors, typography, dimensions, theme
│   ├── utils/           # Validators, formatters, debouncer
│   └── widgets/         # Shared reusable widgets
├── data/
│   ├── models/          # Data models (User, Product, Category, Favorite)
│   ├── repositories/    # Catalog, Favorites, User repositories
│   └── services/        # Dio API provider, Firebase Auth service
├── logic/
│   ├── auth/            # AuthCubit + AuthState
│   ├── categories/      # CategoriesCubit
│   ├── favorites/       # FavoritesCubit
│   ├── products/        # ProductsCubit
│   ├── profile/         # ProfileCubit
│   └── search/          # SearchCubit
└── presentation/
    ├── auth/            # Login & Register screens
    ├── favorites/       # Favorites screen
    ├── home/            # Home screen with category grid
    ├── products/        # Products list & detail screens
    ├── profile/         # Profile screen
    ├── search/          # Search screen
    └── shell/           # Main shell with bottom nav bar
```

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x / Dart 3.x |
| State Management | flutter_bloc 9.1.1 (Cubit) |
| Auth | firebase_auth 6.5.6 + google_sign_in 7.2.0 |
| Database | cloud_firestore 6.7.1 |
| Networking | dio 5.11.0 |
| Image Caching | cached_network_image 3.4.1 |
| UI | shimmer, google_fonts, material_symbols_icons |
| Testing | bloc_test, mocktail, fake_cloud_firestore, glados |

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK `^3.12.2`
- Dart SDK `^3.12.2`
- A Firebase project with **Authentication** and **Firestore** enabled

### Setup

1. **Clone the repo**
   ```bash
   git clone https://github.com/AhmedHassaan-7OS/shopify.git
   cd shopify
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**

   - Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
   - Enable **Email/Password** and **Google** sign-in methods
   - Enable **Cloud Firestore**
   - Download `google-services.json` and place it in `android/app/`
   - Download `GoogleService-Info.plist` and place it in `ios/Runner/`
   - Update `lib/firebase_options.dart` with your project config

4. **Run the app**
   ```bash
   flutter run
   ```

---

## 🧪 Running Tests

```bash
flutter test
```

The test suite covers:
- Unit tests for utilities (validators, formatters, debouncer)
- Widget tests for shared UI components
- Repository tests with mocked services
- Cubit tests with `bloc_test`
- Property-based tests with `glados`

---

## 📁 Project Structure Notes

- `design/stitch/` — UI design references and screen mockups
- `firestore.rules` — Firestore security rules
- `firebase.json` — Firebase project configuration

---

## 📄 License

This project is for personal/educational use. Feel free to fork and build upon it.
