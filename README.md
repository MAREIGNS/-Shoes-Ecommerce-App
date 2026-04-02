# Shoescomm

Flutter e-commerce app for shoes, powered by Supabase (auth, database, storage).

## Features

- User sign up / sign in
- Product list, detail, cart, wishlist
- Checkout with address and orders
- User dashboard and order history
- Admin: user list, add/edit products

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (SDK ^3.10.7)
- A [Supabase](https://supabase.com) project (tables: `users`, `products`, `cart`, `wishlist`, `orders`, `order_items`, `addresses`; storage buckets: `user-images`, `product-images`)

## Getting started

1. Clone the repo and open the project folder.
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. **Development:** Supabase URL and anon key are read from `lib/supabase_config.dart` (defaults). Ensure your Supabase project URL and anon key are set there for local runs.
4. Run the app:
   ```bash
   flutter run
   ```

## Building the APK (low-spec friendly)

The app is refactored for low-spec devices: **minSdk 21** (Android 5.0+), lighter splash, cached images, and release minification.

**Single APK (recommended for testing):**
```bash
flutter build apk --release
```

**Smaller APKs per ABI (recommended for distribution):**
```bash
flutter build apk --split-per-abi --release
```
Outputs `app-armeabi-v7a-release.apk`, `app-arm64-v8a-release.apk`, etc. Users download only their device’s ABI.

**Production build with env (secrets):**
```bash
flutter build apk --release --split-per-abi --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co --dart-define=SUPABASE_ANON_KEY=your_anon_key
```

For iOS:

```bash
flutter build ios --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co --dart-define=SUPABASE_ANON_KEY=your_anon_key
```

If `SUPABASE_URL` and `SUPABASE_ANON_KEY` are not set, the app falls back to the values in `lib/supabase_config.dart` (intended for development only).

## Production checklist

Before going live, ensure:

- **Secrets:** Build with `--dart-define` for production; do not ship with default keys from `supabase_config.dart`.
- **Supabase:** Enable Row Level Security (RLS) on all tables and define policies so users only access their own data (e.g. `cart`, `wishlist`, `orders` by `user_id`).
- **Schema:** Tables `products` should have an `is_active` column (boolean) used to filter visible products.
- **Storage:** Buckets `user-images` and `product-images` should have appropriate public/private and RLS policies.
- **Optional:** Add crash reporting (e.g. Firebase Crashlytics) and analytics; consider rate limiting or CAPTCHA on auth endpoints.

## Project structure

- `lib/main.dart` – App entry, theme, routes
- `lib/supabase_config.dart` – Supabase init and client
- `lib/pages/` – Screens (login, signup, product list, cart, orders, admin, etc.)
- `lib/service/` – `UserService`, `EcommerceService`
- `lib/models/` – Data models (user, product, cart, order, address, category)

## Tests

```bash
flutter test
```

## License

Private / none.
