# BookNest - Online Book Store

A Flutter mobile application for browsing and purchasing books online.

## Screens

- **Splash Screen** – Animated app intro with auto-navigation
- **Login Screen** – Email & password login with validation
- **Register Screen** – Full registration form with real-time validation
- **Home Screen** – Book grid with search and category filter
- **Book Detail Screen** – Full book info, rating, add to cart
- **Cart Screen** – Cart management with quantity controls
- **Checkout Screen** – Delivery form + payment + order summary
- **Order Success Screen** – Confirmation with order details

## Features

- Provider-based state management (cart)
- Navigator.push / pop navigation with data passing
- Real-time form validation on all screens
- Responsive layout for mobile and tablet
- Category filtering and live search

## How to Run

1. **Install Flutter** from https://flutter.dev/docs/get-started/install

2. **Clone / extract** the project folder

3. **Install dependencies**
   ```bash
   flutter pub get
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## Dependencies

| Package    | Version | Purpose               |
|------------|---------|-----------------------|
| provider   | ^6.1.1  | State management      |
| flutter    | SDK     | Core framework        |

## Project Structure

```
lib/
├── main.dart
├── models/
│   └── book.dart
├── providers/
│   └── cart_provider.dart
└── screens/
    ├── splash_screen.dart
    ├── login_screen.dart
    ├── register_screen.dart
    ├── home_screen.dart
    ├── book_detail_screen.dart
    ├── cart_screen.dart
    └── checkout_screen.dart
```
