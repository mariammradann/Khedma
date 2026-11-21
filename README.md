# Khedma (Flutter frontend)

*Empowering teenagers, assisting busy lives.* Mobile frontend for the Khedma
task marketplace, built from the project presentation (requirements, use
cases, class diagram/ERD and the existing mockups).

## Run

```bash
cd khedma
flutter create . --project-name khedma --platforms=android,ios,web   # generates platform folders once
flutter pub get
flutter run
```

Needs Flutter 3.22+ (Dart 3.3+).

## What is in it

| Deck requirement | Screen |
|---|---|
| Splash, "Lets get started" | `welcome_screen.dart` |
| Log in/out, choose user (customer/worker), retrieve password, create account | `auth_screens.dart`, `common_tabs.dart` (log out) |
| Customer: search by area, request task, set time / location / price / payment method / duration, cancel | `customer_shell.dart`, `request_task_screen.dart` |
| Worker: see all available tasks, accept / decline, end task, collect payment | `worker_shell.dart`, `tracking_screen.dart` |
| Know the worker's location, ETA, contact (message / call) | `tracking_screen.dart` (map is a painted placeholder) |
| Rate each other, payment receipt for both | `receipt_screen.dart` |
| My tasks, profile, earnings/spent | `common_tabs.dart` |

Data model (`models.dart`) mirrors the ERD: user (customer/worker), task,
payment fields, plus chat messages for the "communication" class.

## Demo flow

1. Sign up or log in as **customer**, request a task. After ~6 s a mock worker accepts it.
2. Log out, log in as **worker**, pick an area on **Nearby**, press **Accept**, then **End task**.
3. Receipt + rating appear.

## Wiring to a real backend

All mock data and timers live in `lib/state.dart` (`AppState`). Replace those
methods with API calls (and the two `Timer`s with push/websocket updates).
Replace `_MapPlaceholder` in `tracking_screen.dart` with `google_maps_flutter`
or `flutter_map`; use `geolocator` for the live location input the deck
lists, and `url_launcher` for the call button.
