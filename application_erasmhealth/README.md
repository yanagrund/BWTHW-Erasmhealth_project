# Erasmhealth – Flutter App

A Flutter application that fetches personal health data from the IMPACT wearable platform, computes a daily wellness score, and presents it across four screens: Home, History, Recovery, and Simulation.

---

## Features

- **Login with IMPACT credentials** — JWT tokens are stored via `SharedPreferences` so the session persists across restarts.
- **Wellness score (0–100)** — Computed from sleep duration, current heart rate, resting heart rate, and step count, with an alcohol-consumption penalty applied when relevant signals are elevated.
- **History** — View your score and raw metrics for yesterday, the last 7 days, or the last 30 days (averages for multi-day ranges).
- **Recovery** — Shows how many hours remain until you reach 100 % based on a fixed recovery rate, and compares today's score to yesterday's.
- **Simulation** — Interactively model how alcohol, water, sleep, and exercise would change your score.
- **Auto-refresh** — Score re-fetches every 30 seconds while the app is open.

---

## Tech stack

| Package | Purpose |
|---|---|
| [Flutter](https://flutter.dev) | UI framework |
| [provider](https://pub.dev/packages/provider) | State management (ChangeNotifier) |
| [http](https://pub.dev/packages/http) | REST API calls to IMPACT |
| [shared_preferences](https://pub.dev/packages/shared_preferences) | Persistent JWT token and login-state storage |
| [lottie](https://pub.dev/packages/lottie) | Splash-screen animation |

---

## Project structure

```
lib/
├── main.dart                  # App entry point, Provider setup, splash → login → home routing
├── providers/
│   └── app_state.dart         # Central state: login, logout, score, auto-refresh
├── utils/
│   └── impact.dart            # Repository: all HTTP calls and JSON parsing for the IMPACT API
├── services/
│   ├── History_service.dart   # Service layer: per-date and range data fetching with caching
│   └── health_score.dart      # Pure score computation (sleep, HR, resting HR, steps)
└── screens/
    ├── Cocktail_Animation.dart # Splash screen (Lottie animation, 5 s)
    ├── LoginPage.dart          # Credential entry, calls AppState.login()
    ├── HomePage.dart           # Current score, full-screen colour feedback, hamburger menu
    ├── HistoryPage.dart        # Tabbed view: Yesterday / Last Week / Last Month
    ├── RecoveryPage.dart       # Time-to-recovery countdown and daily improvement
    └── SimulationPage.dart     # What-if score simulator
```

---

## Architecture

The app uses a layered architecture with clear separation of concerns:

```
Screens  →  AppState (ChangeNotifier / Provider)
                  ↓
            Impact (Repository)   ←→   IMPACT REST API
                  ↑
          HistoryService (Service layer, wraps Impact)
                  ↑
          HealthScoreService (pure computation, no I/O)
```

**Design patterns in use:**

- **Observer (Provider)** — `AppState` notifies all listening widgets on state changes.
- **Repository** — `Impact` owns all HTTP calls and JSON parsing; nothing else touches the API directly.
- **Service layer** — `HistoryService` adds multi-day aggregation and request caching on top of the repository.
- **Facade** — `Impact.fetchHealthDataForDate()` fires four parallel API calls and returns one unified map.
- **Dependency injection** — `Impact` is injected into `AppState`; `HistoryService` receives `Impact` via constructor, making both testable and preventing unauthenticated instances.
- **Callback** — `HistorySubPage` reports its loaded score to the parent `HistoryScreen` via `onScoreLoaded`, allowing the AppBar colour to react per tab.

---

## Setup and running

### Prerequisites

- Flutter SDK ≥ 3.11 — [install guide](https://docs.flutter.dev/get-started/install)
- A device or simulator (iOS, Android, macOS, or web)

### Install dependencies

```bash
cd application_erasmhealth
flutter pub get
```

### Run the app

```bash
flutter run
```

To target a specific platform:

```bash
flutter run -d macos    # macOS desktop
flutter run -d chrome   # Web
```

### Login credentials

Use the test credentials provided in `credentials.xls` at the repo root. The app authenticates against the IMPACT API at `https://impact.dei.unipd.it/bwthw/`.

---

## Wellness score formula

The score is a weighted sum of four sub-scores, with an alcohol-consumption penalty:

| Component | Weight | Logic |
|---|---|---|
| Sleep | 30 % | 100 % at 7–10 hrs; proportionally less outside that range |
| Heart rate | 25 % | 100 % when within 15 bpm below baseline (70 bpm); 0 % at ≥ 20 bpm above |
| Resting HR | 20 % | 100 % at ≤ 60 bpm; 0 % at ≥ 90 bpm |
| Steps | 25 % | Linear, 100 % at ≥ 10 000 steps |
| Alcohol penalty | −10 pts each | Applied when HR is > 10 bpm above baseline **and/or** sleep < 6 hrs |

Final score is clamped to [0, 100].
