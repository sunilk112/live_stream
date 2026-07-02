# Alive — Live Streaming App (Flutter)

**Alive** is a mobile live-streaming application (Flutter) where users browse
live streams in a discovery grid, filter by category/country, and sign in
(email/phone or **Google via Firebase**). It is built with a strict
**Clean Architecture + MVVM** structure so the codebase is modular, testable,
and easy to scale feature-by-feature.

- **Framework:** Flutter 3.44.3 · Dart 3.12.2
- **Architecture:** Clean Architecture (Domain / Data / Presentation) + MVVM
- **State management:** `provider` (MVVM ViewModels as `ChangeNotifier`)
- **Dependency injection:** `get_it` (service locator)
- **Navigation:** `go_router`
- **Auth:** Firebase Authentication + Google Sign-In
- **Functional error handling:** `dartz` (`Either<Failure, T>`)

> Firebase / Google setup steps live in **[FIREBASE_SETUP.md](FIREBASE_SETUP.md)**.

---

## Table of contents
1. [What the app does](#1-what-the-app-does)
2. [Tech stack & why each package](#2-tech-stack--why-each-package)
3. [Architecture overview](#3-architecture-overview)
4. [The three layers & the dependency rule](#4-the-three-layers--the-dependency-rule)
5. [Full folder & file reference](#5-full-folder--file-reference)
6. [App flow & navigation](#6-app-flow--navigation)
7. [End-to-end data flow (Google login example)](#7-end-to-end-data-flow-google-login-example)
8. [State management & DI](#8-state-management--di)
9. [Error handling model](#9-error-handling-model)
10. [Design system (theme, colors, sizes)](#10-design-system-theme-colors-sizes)
11. [Assets](#11-assets)
12. [Testing](#12-testing)
13. [Running the app](#13-running-the-app)
14. [How to add a new feature](#14-how-to-add-a-new-feature)
15. [Known placeholders / TODO](#15-known-placeholders--todo)

---

## 1. What the app does

| Screen | Purpose |
|--------|---------|
| **Splash** | Brand intro. Shows the animated Alive logo, then routes to Login. |
| **Login** | Email/phone + password (mock) **or** Google Sign-In (Firebase). On success → Home. Google login shows a "Welcome <name>" bottom toast. |
| **Home** | Discovery feed: top bar (logo, notifications, wallet), Stream/Hot/Follow tabs, country filter chips, a 2-column grid of live-stream cards, and a custom bottom nav with an elevated "Go Live" button. |

Current data is **mock** (served through the same Clean Architecture pipeline a
real API would use), so the app runs end-to-end out of the box.

---

## 2. Tech stack & why each package

| Package | Version | Role |
|---------|---------|------|
| `provider` | ^6.1.5 | Binds Views to MVVM ViewModels (`ChangeNotifier`). |
| `get_it` | ^9.2.1 | Service locator / dependency injection. |
| `go_router` | ^17.3.0 | Declarative, URL-based navigation. |
| `dio` | ^5.10.0 | HTTP client (configured, ready for real APIs). |
| `dartz` | ^0.10.1 | `Either<Failure, T>` for functional error handling. |
| `equatable` | ^2.0.8 | Value equality for entities/params/failures. |
| `flutter_animate` | ^4.5.2 | Declarative splash animations (fade/scale/shimmer). |
| `shared_preferences` | ^2.5.5 | Local key-value storage (registered, ready to use). |
| `font_awesome_flutter` | ^11.0.0 | Facebook brand icon. |
| `flutter_svg` | ^2.3.0 | Renders the multicolor Google "G" SVG. |
| `firebase_core` | ^4.11.0 | Firebase initialization. |
| `firebase_auth` | ^6.5.4 | Firebase Authentication. |
| `google_sign_in` | ^7.2.0 | Google account picker (7.x `initialize()`/`authenticate()` API). |
| `fluttertoast` | ^9.1.0 | OS-level bottom toast (welcome message survives navigation). |
| `cupertino_icons` | ^1.0.8 | iOS-style icons. |

---

## 3. Architecture overview

The app follows **Clean Architecture** with a **feature-first** folder layout.
Each feature is a vertical slice split into three layers; shared infrastructure
lives in `core/`.

```
Presentation (UI + MVVM ViewModel)
        │  depends on ↓ (calls use cases)
Domain (entities, repository contracts, use cases)   ← pure Dart, no Flutter/Firebase
        ▲  implemented by ↑
Data (models, data sources, repository implementations)
```

**MVVM** sits inside the Presentation layer:
- **Model** → domain entities / use-case results
- **View** → `*_page.dart` widgets (dumb; only render state & forward events)
- **ViewModel** → `*_viewmodel.dart` (`ChangeNotifier`; holds UI state, calls use cases, exposes getters)

**The golden rule:** dependencies point **inward**. Domain knows nothing about
Data or Presentation. Data implements Domain contracts. Presentation depends on
Domain only (never directly on Data).

---

## 4. The three layers & the dependency rule

### Domain (innermost, pure)
- **Entities** — plain business objects (`UserEntity`, `LiveStreamEntity`), `Equatable`, no JSON.
- **Repository contracts** — abstract classes (`AuthRepository`, `HomeRepository`).
- **Use cases** — one unit of business logic each (`LoginUser`, `SignInWithGoogle`, `GetLiveStreams`). All return `Future<Either<Failure, T>>`.
- No imports of Flutter, Firebase, Dio, etc.

### Data (outermost of the "business" side)
- **Models** — extend entities, add `fromJson` / `toJson` / `fromFirebase`.
- **Data sources** — talk to the outside world (Firebase, Dio, mock). Throw `Exception`s.
- **Repository implementations** — implement Domain contracts, catch data-source `Exception`s and convert them into Domain `Failure`s (`try/catch` → `Left(Failure)` / `Right(value)`).

### Presentation
- **Views** (`*_page.dart`) — widgets; create ViewModels via Provider/`get_it`; render state; forward user events.
- **ViewModels** (`*_viewmodel.dart`) — `ChangeNotifier`; call use cases; `fold` the `Either` into UI state; `notifyListeners()`.
- **Feature widgets** — presentational sub-widgets used by that feature's pages.

### Core (cross-cutting, shared by all features)
Theme, constants, DI container, routing, error types, base use-case contract,
network client, reusable widgets, utilities.

---

## 5. Full folder & file reference

```
lib/
├── main.dart                      # App entry: ensureInitialized → Firebase init → DI → runApp
├── app.dart                       # Root widget: MaterialApp.router (theme + router)
│
├── core/                          # Shared, feature-agnostic infrastructure
│   ├── constants/
│   │   ├── app_constants.dart     # App name, asset paths, splash duration, base URL/timeouts
│   │   ├── app_sizes.dart         # Spacing scale, radii, field/button heights, max content width
│   │   └── auth_config.dart       # Google Web (server) client ID for Firebase ID tokens
│   ├── di/
│   │   └── injection_container.dart  # get_it registrations (sl) — wires every dependency
│   ├── error/
│   │   ├── failures.dart          # Domain failures: Server/Cache/Network/Unknown/AuthCancelled
│   │   └── exceptions.dart        # Data exceptions: Server/Cache/Network/AuthCancelled
│   ├── network/
│   │   └── dio_client.dart        # Configured Dio wrapper (baseUrl, timeouts, logging)
│   ├── routing/
│   │   ├── app_routes.dart        # Route path + name constants (splash/login/home)
│   │   └── app_router.dart        # GoRouter config: routes + error page
│   ├── theme/
│   │   ├── app_colors.dart        # Brand palette + gradients (splash, brand, wave, bottom nav)
│   │   └── app_theme.dart         # Material 3 ThemeData (light)
│   ├── usecases/
│   │   └── usecase.dart           # UseCase<T,P> base contract + NoParams
│   ├── utils/
│   │   └── number_formatter.dart  # formatCompactCount() → 8200 => "8.2K"
│   └── widgets/                   # Reusable app-wide widgets
│       ├── brand_logo.dart        # Rounded white logo badge (fallback icon)
│       ├── app_text_field.dart    # Labelled, filled, validated TextFormField
│       ├── primary_gradient_button.dart  # Lime→green CTA with loading state
│       └── social_auth_button.dart       # White "Continue with …" pill (loading state)
│
└── features/
    ├── splash/
    │   └── presentation/
    │       ├── view/splash_page.dart         # Animated logo, breathing glow → routes to Login
    │       └── viewmodel/splash_viewmodel.dart # Timer; flips isReady; View navigates
    │
    ├── auth/
    │   ├── domain/
    │   │   ├── entities/user_entity.dart          # id, name, email, photoUrl, accessToken
    │   │   ├── repositories/auth_repository.dart   # login / signInWithGoogle / signOut contracts
    │   │   └── usecases/
    │   │       ├── login_user.dart                 # email/phone + password (+ LoginParams)
    │   │       └── sign_in_with_google.dart        # Google → Firebase
    │   ├── data/
    │   │   ├── models/user_model.dart              # fromJson/toJson + fromFirebase factory
    │   │   ├── datasources/auth_remote_data_source.dart  # mock login + real Google/Firebase flow
    │   │   └── repositories/auth_repository_impl.dart     # maps exceptions → failures
    │   └── presentation/
    │       ├── view/login_page.dart               # Full login UI, form validation, Google/FB buttons
    │       ├── viewmodel/login_viewmodel.dart     # status, obscurePassword, isGoogleLoading, googleUser
    │       └── widgets/
    │           ├── auth_wave_section.dart         # Green double-hill wave (CustomClipper) footer
    │           └── or_divider.dart                # "or continue with" divider
    │
    └── home/
        ├── domain/
        │   ├── entities/live_stream_entity.dart   # id, title, host, thumb, avatar, viewers, flag, isLive, isFollowed
        │   ├── repositories/home_repository.dart   # getLiveStreams contract
        │   └── usecases/get_live_streams.dart      # returns list of streams
        ├── data/
        │   ├── models/live_stream_model.dart       # fromJson/toJson
        │   ├── datasources/home_remote_data_source.dart  # mock streams (Picsum thumbnails)
        │   └── repositories/home_repository_impl.dart    # maps exceptions → failures
        └── presentation/
            ├── view/home_page.dart                 # Composes app bar, tabs, chips, grid, bottom nav; PopScope → Login
            ├── viewmodel/home_viewmodel.dart       # status, streams, selectedTab, selectedCountry, toggleFollow
            └── widgets/
                ├── home_app_bar.dart               # Logo + notification bell (badge) + wallet button
                ├── stream_tab_bar.dart             # Stream / Hot / Follow tabs
                ├── country_filter_bar.dart         # Scrollable country chips (Global, India, …)
                ├── stream_grid_card.dart           # Card: thumbnail, viewer badge, name+flag, follow
                └── alive_bottom_nav_bar.dart       # Gradient bar + elevated "Go Live" button
```

### File-by-file details

**Entry / root**
- `main.dart` — `WidgetsFlutterBinding.ensureInitialized()`, `Firebase.initializeApp()` (native config, wrapped in try/catch so the app still runs pre-config), `initDependencies()`, then `runApp(AliveApp())`.
- `app.dart` — `AliveApp` → `MaterialApp.router` wired to `AppTheme.light` and `AppRouter.router`.

**core/constants**
- `app_constants.dart` — `appName`, `logoPath`, `googleLogoPath`, `splashDuration` (3s), API `baseUrl`/timeouts.
- `app_sizes.dart` — single source of spacing (`gapXs…gapXxl`), radii, `fieldHeight`, `buttonHeight`, `logoBadge`, `maxContentWidth` (tablet cap).
- `auth_config.dart` — `googleServerClientId` (Web OAuth client ID) via `String.fromEnvironment` with a hardcoded default.

**core/di**
- `injection_container.dart` — the `sl` (get_it) instance and `initDependencies()`. Registers: `SharedPreferences`, `Dio`, `DioClient`, `FirebaseAuth`, `GoogleSignIn`, and every feature's data source → repository → use case → ViewModel. ViewModels are `registerFactory` (fresh per screen); everything else is `registerLazySingleton`.

**core/error**
- `failures.dart` — `Failure` (Equatable) + `ServerFailure`, `CacheFailure`, `NetworkFailure`, `UnknownFailure`, `AuthCancelledFailure`.
- `exceptions.dart` — `ServerException`, `CacheException`, `NetworkException`, `AuthCancelledException`.

**core/network**
- `dio_client.dart` — configures one `Dio` (base URL, timeouts, `LogInterceptor`), exposes `get`/`post`.

**core/routing**
- `app_routes.dart` — `splash '/'`, `login '/login'`, `home '/home'` (+ their names).
- `app_router.dart` — `GoRouter` with the three routes and a fallback error page.

**core/theme**
- `app_colors.dart` — brand greens, field/chip/badge/follow colors, and gradients (`splashGradient`, `brandGradient`, `waveGradient`, `bottomNavGradient`).
- `app_theme.dart` — Material 3 `ThemeData` from a seeded `ColorScheme`, app bar & elevated-button themes.

**core/usecases**
- `usecase.dart` — `abstract class UseCase<T, P> { Future<Either<Failure, T>> call(P params); }` and `NoParams`.

**core/utils**
- `number_formatter.dart` — `formatCompactCount(int)` → `"8.2K"`, `"1.5M"`.

**core/widgets**
- `brand_logo.dart` — white rounded logo badge; falls back to an icon if the asset is missing.
- `app_text_field.dart` — labelled `TextFormField` (filled, rounded, validator, suffix, obscure).
- `primary_gradient_button.dart` — full-width gradient CTA with spinner + disabled state.
- `social_auth_button.dart` — white pill with icon + label; `isLoading` shows a spinner.

**Splash feature**
- `splash_viewmodel.dart` — starts a `Timer(splashDuration)`, flips `isReady`, notifies (safe after dispose).
- `splash_page.dart` — white background, animated logo (blur→focus scale/fade + shimmer), breathing radial glow, tagline + loader; on `isReady` → `context.goNamed(login)`.

**Auth feature**
- `user_entity.dart` / `user_model.dart` — user shape + serialization (`fromJson`, `toJson`, `fromFirebase`).
- `auth_repository.dart` — `login`, `signInWithGoogle`, `signOut` (all `Either<Failure, …>`).
- `login_user.dart` / `sign_in_with_google.dart` — the two auth use cases.
- `auth_remote_data_source.dart` — mock email/password `login`; real `signInWithGoogle` using `google_sign_in` 7.x (`initialize` w/ `serverClientId` → `authenticate` → `GoogleAuthProvider.credential(idToken)` → `FirebaseAuth.signInWithCredential`). Firebase/Google are injected **lazily** so the login screen loads even before Firebase is configured.
- `auth_repository_impl.dart` — maps `AuthCancelledException`/`FirebaseAuthException`/`ServerException`/`NetworkException` → `Failure`s.
- `login_viewmodel.dart` — `status`, `errorMessage`, `obscurePassword`, `isGoogleLoading`, `googleUser`; `login()`, `signInWithGoogle()`, `togglePasswordVisibility()`.
- `login_page.dart` — logo + heading + form (`app_text_field`), Forgot Password, gradient Login button, wave section with Google/Facebook buttons + Sign Up. Scrolls only when the keyboard opens. Google success → welcome toast (Google-only) → Home.
- `auth_wave_section.dart` — `CustomClipper` double-hill wave with a back layer for depth.
- `or_divider.dart` — "or continue with" with side lines.

**Home feature**
- `live_stream_entity.dart` / `live_stream_model.dart` — stream shape + serialization + `copyWith` (for follow toggle).
- `home_repository.dart` / `get_live_streams.dart` — contract + use case.
- `home_remote_data_source.dart` — mock list (Picsum thumbnails; `Sofia Chen`, `8.2K`, 🇵🇭).
- `home_repository_impl.dart` — maps exceptions → failures.
- `home_viewmodel.dart` — `status`, `streams`, `selectedTab`, `selectedCountry`, `countries`; `selectTab`, `selectCountry`, `toggleFollow`, `loadLiveStreams`.
- `home_page.dart` — composes app bar, tabs, chips, and a responsive `GridView`; `PopScope` sends hardware-back to Login; loading/error/empty states + pull-to-refresh.
- Home widgets — see the tree above.

---

## 6. App flow & navigation

```
Splash ("/")  ──3s──►  Login ("/login")  ──success──►  Home ("/home")
                                                         │
                                              hardware back → Login
```

- Navigation uses **`go_router`**; screens call `context.goNamed(AppRoutes.xxxName)`.
- `go` **replaces** the location (no growing back stack), so Home won't pop back to Login by default — hardware back is explicitly redirected to Login via `PopScope` on Home.
- Route constants are centralized in `app_routes.dart`; the config is in `app_router.dart`.

---

## 7. End-to-end data flow (Google login example)

```
LoginPage (View)
  → LoginViewModel.signInWithGoogle()                     [Presentation]
     → SignInWithGoogle(NoParams)                          [Domain use case]
        → AuthRepository.signInWithGoogle()                [Domain contract]
           → AuthRepositoryImpl                            [Data]
              → AuthRemoteDataSourceImpl.signInWithGoogle()[Data source]
                 → google_sign_in.authenticate()           (external)
                 → FirebaseAuth.signInWithCredential()      (external)
              ← UserModel  (or throws Exception)
           ← Either<Failure, UserEntity>                   (Right / Left)
     ← bool (true on success; stores googleUser)
  → View: show "Welcome <name>" toast → context.goNamed(home)
```

Every feature's happy path follows the same shape: **View → ViewModel → UseCase
→ Repository (contract) → RepositoryImpl → DataSource**, with results flowing
back as `Either<Failure, T>` and the ViewModel `fold`-ing them into UI state.

---

## 8. State management & DI

- **MVVM binding:** each screen wraps its widget tree in
  `ChangeNotifierProvider<XxxViewModel>(create: (_) => sl<XxxViewModel>())`.
  Views read state with `context.watch<XxxViewModel>()` and call methods with
  `context.read<XxxViewModel>()`.
- **DI:** `get_it` (`sl`) is configured once in `initDependencies()` (called from
  `main`). ViewModels are **factories** (new instance per screen, disposed with
  the widget); repositories/use cases/data sources are **lazy singletons**.
- **Why lazy Firebase providers:** `FirebaseAuth.instance` throws if Firebase
  isn't initialized, so it's injected as `() => sl<FirebaseAuth>()` and only
  resolved when the user actually taps "Continue with Google" — the rest of the
  app (and tests) run without a Firebase project.

---

## 9. Error handling model

```
Data source        →  throws  ServerException / NetworkException / AuthCancelledException
RepositoryImpl     →  catches →  returns  Left(ServerFailure / NetworkFailure / AuthCancelledFailure)
UseCase            →  passes through  Either<Failure, T>
ViewModel          →  result.fold( (failure) → error state , (data) → success state )
View               →  renders loading / success / error (snackbar) from ViewModel state
```

- Exceptions never leak to the UI; they're converted to typed `Failure`s at the
  repository boundary.
- `AuthCancelledFailure` is treated as a **no-op** (dismissing the Google dialog
  is not an error).

---

## 10. Design system (theme, colors, sizes)

- **Colors** (`app_colors.dart`): primary green `#34B233`, dark `#1E8A1E`, accent
  lime `#B7E92B`; plus field/chip/badge/follow colors and four gradients used by
  the splash, buttons, auth wave, and bottom nav.
- **Sizes** (`app_sizes.dart`): a single spacing scale and component dimensions so
  spacing stays consistent; `maxContentWidth` centers/limits content on tablets.
- **Theme** (`app_theme.dart`): Material 3, seeded color scheme, shared app-bar and
  button styling.
- **Reusable widgets** in `core/widgets/` keep the UI DRY (logo badge, text field,
  gradient button, social button).

---

## 11. Assets

Declared in `pubspec.yaml` under `flutter/assets: - assets/images/`.

| Asset | Use |
|-------|-----|
| `assets/images/logo.png` | Alive app logo (splash, brand badge). |
| `assets/images/google_logo.svg` | Official multicolor Google "G" (login button). |

> Stream thumbnails currently come from the Picsum placeholder service at runtime
> (network); host avatars render as empty rings (supply a URL to fill them).

---

## 12. Testing

`test/`
- `widget_test.dart` — Splash smoke test: renders the logo/tagline, then routes to Login.
- `login_to_home_test.dart` — end-to-end: Splash → Login → enter valid credentials → **Home** (asserts the route and `HomePage`).

Run: `flutter test`

---

## 13. Running the app

```bash
flutter pub get
flutter run
```

- The app runs out of the box on mock data (Splash → Login → Home).
- **Google Sign-In** additionally requires your Firebase project — see
  **[FIREBASE_SETUP.md](FIREBASE_SETUP.md)** (enable Google provider,
  `flutterfire configure` or native `google-services.json`, register your
  SHA-1/SHA-256, set the Web client ID).
- Handy checks: `flutter analyze` · `flutter test` · `flutter build web`.

---

## 14. How to add a new feature

Mirror the existing structure — e.g. a `profile` feature:

```
features/profile/
├── domain/
│   ├── entities/profile_entity.dart
│   ├── repositories/profile_repository.dart
│   └── usecases/get_profile.dart
├── data/
│   ├── models/profile_model.dart
│   ├── datasources/profile_remote_data_source.dart
│   └── repositories/profile_repository_impl.dart
└── presentation/
    ├── view/profile_page.dart
    ├── viewmodel/profile_viewmodel.dart
    └── widgets/…
```

Then: register the chain in `injection_container.dart`, add a route in
`app_routes.dart` + `app_router.dart`, and reuse `core/widgets` + the theme.

**Conventions**
- Domain stays pure (no Flutter/Firebase imports).
- Data sources throw; repositories return `Either<Failure, T>`.
- ViewModels are `ChangeNotifier`, expose immutable getters, and `notifyListeners()`.
- Pull spacing/colors from `AppSizes` / `AppColors` — no magic numbers in widgets.

---

## 15. Known placeholders / TODO

- **Mock data** — auth `login` and `getLiveStreams` are mock; swap the data-source
  bodies for real Dio calls (`DioClient` + `AppConstants.baseUrl` are ready).
- **Email/password backend** — currently a mock (any non-empty identifier +
  6+ char password succeeds; password `wrong` demonstrates the error path).
- **Facebook / Forgot Password / Sign Up** — UI present; wire real flows.
- **Tabs & country chips** — update selection state but don't filter the feed yet
  (add a query param to the use case/repository to make them filter).
- **Firebase (web)** — mobile uses native config; for web, run
  `flutterfire configure` and pass `DefaultFirebaseOptions.currentPlatform`.
