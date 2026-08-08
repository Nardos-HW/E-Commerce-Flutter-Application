# E-Commerce App (Fake Store API)

A Flutter e-commerce app built against [Fake Store API](https://fakestoreapi.com), with product browsing, category filtering, search, a persisted shopping cart, authentication, and a user profile screen.

## Setup & Run

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run -d <device-id>
```

Run `flutter devices` to see available targets. This app is built and tested primarily against a mobile device/emulator — see [Known Limitations](#known-limitations) for notes on running it on web.

### Test login credentials

The Fake Store API has no registration flow, only a fixed set of seeded users. Use:

```
Username: mor_2314
Password: 83r5^_
```

(Pre-filled by default on the login screen.)

## Architecture

Feature-first structure, with each feature split into `data` / `domain` / `presentation`:

```
lib/
  core/
    network/       # DioClient, Result<T>/Failure wrapper, error mapping
    theme/          # AppTheme (light/dark)
    utils/          # Responsive breakpoint helper
    widgets/        # Shared LoadingView / ErrorView / EmptyView
    routing/        # go_router config + auth redirect guard

  features/
    auth/
      domain/       # Session model, AuthRepository interface
      data/          # AuthRepositoryImpl (login, logout, session persistence)
      presentation/  # AuthNotifier, LoginScreen

    products/
      domain/       # Product/Rating models, ProductRepository interface
      data/          # ProductRepositoryImpl
      presentation/  # Product list/detail screens, filter & search providers

    cart/
      domain/       # CartItem model, CartRepository interface
      data/          # CartRepositoryImpl (Hive-backed persistence)
      presentation/  # CartNotifier, CartScreen

    profile/
      domain/       # UserProfile model, ProfileRepository interface
      data/          # ProfileRepositoryImpl
      presentation/  # ProfileScreen

  main.dart
```

The domain layer in every feature has no Flutter or Dio imports — repositories are defined as interfaces there and implemented in `data/`, so `presentation/` only ever depends on an abstraction, not a concrete HTTP client.

## State Management

**Riverpod**, using hand-written `Notifier`/`AsyncNotifier` classes rather than the code-generation (`@riverpod`) variant. This was a deliberate choice: it avoids adding another `build_runner`-dependent package on top of `freezed`/`json_serializable`, keeping the generated-code surface smaller and easier to debug.

Key providers:
- `productListProvider` / `categoriesProvider` — `AsyncNotifier`s wrapping the product API
- `selectedCategoryProvider` / `searchQueryProvider` — plain `Notifier`s driving client-side filtering
- `filteredProductsProvider` — derived provider combining fetch + filters into a single `AsyncValue`
- `cartProvider` — `Notifier<List<CartItem>>`, persists to Hive on every mutation
- `authProvider` — `AsyncNotifier<Session?>`, source of truth for the `go_router` redirect guard

## Error Handling

Every network call goes through `DioClient.safeCall`, which maps `DioException` types (timeout, connection error, bad response, unknown) into a sealed `Failure` hierarchy, and wraps results in a `Result<T>` (`Success` / `FailureResult`) type. Repositories never throw raw exceptions to the UI layer — every screen consumes either a `Result` (via `.fold`) or an `AsyncValue`, and handles loading / error / empty / data explicitly.

## Known Limitations

- **Search is client-side.** Fake Store API has no `/products/search` endpoint, so title search filters the already-fetched product list locally rather than hitting the network per keystroke.
- **`/auth/login` returns no user ID.** After a successful login, the app fetches `/users` and matches by `username` to resolve the ID needed for `/users/{id}` profile lookups. This is a limitation of the API, not the app.
- **Tokens don't expire.** Fake Store API's login tokens aren't validated or expired server-side, so there's no real way to test session-expiry handling end-to-end against this API. The app persists the session indefinitely until the user explicitly logs out, matching real-world app behavior (e.g. most shopping apps don't ask for a login every launch).
- **Web (Chrome) testing caveats:** Hive's web storage (IndexedDB) is scoped per port, so `flutter run -d chrome` on a different port each run will appear to "lose" cart data that's actually just under a different origin. Pin the port with `--web-port=<n>` if testing on web, or prefer an emulator/device — this is also closer to the actual target platform for a mobile app.

## Testing Notes

Manually verified: product loading/empty/error states, category filter + search combined, product detail navigation (including direct deep-link fallback fetch), cart add/increment/decrement/remove with survival across a full app restart, login/logout with the auth-gated route redirect, and profile loading tied to the active session.