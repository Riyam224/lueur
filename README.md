# Lueur — AI Companion, Mood Journal & Mindful Play

> Your pocket companion. Talk to Luna, track your moods, breathe, draw, and grow together.

---

## What is Lueur?

Lueur is a Flutter mobile app that pairs an AI mood journal with a small toolkit of calming activities. Users share how they feel through emoji and free-text thoughts, and Luna (a friendly AI companion backed by a Django REST API) replies with a warm, personalized note and is there for a follow-up chat. Luna is a companion, not a therapist or a medical tool. Beyond journaling, Lueur tracks mood history so you can see how your moods have looked over time, and gamifies consistency through a plant-growth streak system — and gives users guided breathing, free drawing, and sudoku for those days you just want to chill instead of talk.

The app supports English and Arabic (with full RTL layout), light/dark theming, and Firebase-based authentication (email/password + Google Sign-In).

---

## User Journey

How a user moves through the app, from first launch to their saved memories. A brand-new device goes Splash → Onboarding → Register → Home with no second onboarding; a returning account goes straight to Home after signing in.

```mermaid
flowchart TD
    A(["App launch"]) --> B["Splash"]
    B --> C{"Signed in?"}
    C -->|Yes| H["Home"]
    C -->|No| D{"Seen onboarding?"}
    D -->|No| ON["Onboarding"]
    D -->|Yes| E{"Signed in before on this device?"}
    ON --> E
    E -->|Never| RG["Register"]
    E -->|Before| LG["Login"]

    LG -->|Forgot password| FP["Forgot password"]
    FP --> LG
    RG -->|Continue as guest| GS["Guest session"]
    LG -->|Continue as guest, after a warning| GS
    GS --> H

    RG --> AG{"Which account?"}
    LG --> AG
    AG -->|New, email| CB["18+ checkbox on Register"]
    AG -->|New, Google| MD["18+ modal, declining deletes the account"]
    AG -->|Returning| H
    CB --> H
    MD --> H

    H --> MI["Pick a mood and write a few words"]
    MI --> MC["Mood choice dialog"]
    MC --> AF["Affirmation card"]
    AF -->|Talk to Luna| RS["Luna's reply"]
    AF -->|Breathe| BR["Guided breathing"]
    AF -->|Draw| DR["Free draw"]
    AF -->|Sudoku| SU["Sudoku"]

    RS -->|Guest| GB["Sign in to hear from Luna"]
    RS -->|Bookmark| SQ["Saved quotes"]
    RS -->|Talk again| CH["Chat with Luna"]
    BR -->|Talk to Luna| CH
    DR -->|Talk to Luna| CH
    CH -->|Session ends| JE["Entry saved to the journal"]

    RS -->|Entry saved| JR["Journal tab"]
    JE --> JR
    BR -->|Activity logged| JR
    DR -->|Activity logged| JR
    SU -->|Activity logged| JR

    H -->|See all| TL["Timeline"]
    JR --> TL
    JR --> WL["Weekly letter"]
    JR --> SC["Streak celebration"]
    TL -->|Open a day| CH

    H -.->|Bottom nav| JR
    JR -.->|Bottom nav| PF["Profile tab"]
    PF --> SQ
    PF --> DV["Saved drawings viewer"]
    PF --> SH["Sudoku history"]
    PF --> ST["Theme and language"]
    PF --> DE["Delete journal entries or account"]
    PF --> LO["Log out"]
    LO --> LG

    style A fill:#FFD4B8,stroke:#E8825A,color:#3A2A1E
    style H fill:#C8B4F8,stroke:#6E59C5,color:#3A2A1E
    style RS fill:#E8825A,stroke:#B23A0A,color:#fff
    style BR fill:#5BBFA0,stroke:#2E7D5F,color:#fff
    style DR fill:#FFD4B8,stroke:#E8825A,color:#3A2A1E
    style SU fill:#C8B4F8,stroke:#6E59C5,color:#3A2A1E
    style JR fill:#FFF8F5,stroke:#8C6A52,color:#3A2A1E
    style PF fill:#FFF8F5,stroke:#8C6A52,color:#3A2A1E
```

> **Chat ending:** when a chat ends, the backend saves the session as a journal entry and the app shows the "saved to your journal" card. The one exception is a fallback reply (when Luna can't answer): it is never saved, never shows that card, and never reaches the Journal or Saved quotes.

---

## Screenshots

The flow below follows the app in order — onboarding → sign in → capture a mood → get Luna's response → journal it → unwind with an activity — shown in both light and dark theme.

<table>
  <tr>
    <th>Screen</th>
    <th>Light</th>
    <th>Dark</th>
  </tr>
  <tr>
    <td>Splash</td>
    <td><img src="screenshots/splash_light.png" width="180" alt="Splash screen, light theme"/></td>
    <td><img src="screenshots/splash_dark.png" width="180" alt="Splash screen, dark theme"/></td>
  </tr>
  <tr>
    <td>Onboarding (1/3)</td>
    <td><img src="screenshots/onboarding_1_light.png" width="180" alt="Onboarding walkthrough page 1, light theme"/></td>
    <td><img src="screenshots/onboarding_1_dark.png" width="180" alt="Onboarding walkthrough page 1, dark theme"/></td>
  </tr>
  <tr>
    <td>Onboarding (2/3)</td>
    <td><img src="screenshots/onboarding_2_light.png" width="180" alt="Onboarding walkthrough page 2, light theme"/></td>
    <td><img src="screenshots/onboarding_2_dark.png" width="180" alt="Onboarding walkthrough page 2, dark theme"/></td>
  </tr>
  <tr>
    <td>Onboarding (3/3)</td>
    <td><img src="screenshots/onboarding_3_light.png" width="180" alt="Onboarding walkthrough page 3, light theme"/></td>
    <td><img src="screenshots/onboarding_3_dark.png" width="180" alt="Onboarding walkthrough page 3, dark theme"/></td>
  </tr>
  <tr>
    <td>Login</td>
    <td><img src="screenshots/login_light.png" width="180" alt="Login screen, light theme"/></td>
    <td><img src="screenshots/login_dark.png" width="180" alt="Login screen, dark theme"/></td>
  </tr>
  <tr>
    <td>Register</td>
    <td><img src="screenshots/register_light.png" width="180" alt="Register screen, light theme"/></td>
    <td><img src="screenshots/register_dark.png" width="180" alt="Register screen, dark theme"/></td>
  </tr>
  <tr>
    <td>Forgot password</td>
    <td><img src="screenshots/reset_password_light.png" width="180" alt="Forgot password screen, light theme"/></td>
    <td><img src="screenshots/reset_password_dark.png" width="180" alt="Forgot password screen, dark theme"/></td>
  </tr>
  <tr>
    <td>Choose a mood</td>
    <td><img src="screenshots/home_light.png" width="180" alt="Choosing a mood, light theme"/></td>
    <td><img src="screenshots/home_dark.png" width="180" alt="Choosing a mood, dark theme"/></td>
  </tr>
  <tr>
    <td>Mood choice dialog</td>
    <td><img src="screenshots/features_lght.png" width="180" alt="Mood choice dialog offering Talk, Breathe, Draw, or Sudoku, light theme"/></td>
    <td><img src="screenshots/features_dark.png" width="180" alt="Mood choice dialog offering Talk, Breathe, Draw, or Sudoku, dark theme"/></td>
  </tr>
  <tr>
    <td>Follow-up chat</td>
    <td><img src="screenshots/luna_ai_light.png" width="180" alt="Follow-up chat conversation with Luna, light theme"/></td>
    <td><img src="screenshots/talk_to_luna_dark.png" width="180" alt="Follow-up chat conversation with Luna, dark theme"/></td>
  </tr>
  <tr>
    <td>Follow-up chat (continued)</td>
    <td><img src="screenshots/chat_with_ai_luna_more_light.png" width="180" alt="Extended follow-up chat conversation with Luna, light theme"/></td>
    <td><img src="screenshots/chat_with_ai_luna_more_dark.png" width="180" alt="Extended follow-up chat conversation with Luna, dark theme"/></td>
  </tr>
  <tr>
    <td>Report a response</td>
    <td><img src="screenshots/talk_to_ai_flag_light.png" width="180" alt="Report bottom sheet for flagging one of Luna's replies, light theme"/></td>
    <td><img src="screenshots/talk_to_ai_flag_dark.png" width="180" alt="Report bottom sheet for flagging one of Luna's replies, dark theme"/></td>
  </tr>
  <tr>
    <td>Journal Screen</td>
    <td><img src="screenshots/journal_light.png" width="180" alt="Journal Screen with streak, weekly letter, and recent memories showing each day's single latest entry, light theme"/></td>
    <td><img src="screenshots/journal_dark.png" width="180" alt="Journal Screen with streak, weekly letter, and recent memories showing each day's single latest entry, dark theme"/></td>
  </tr>
  <tr>
    <td>Timeline</td>
    <td><img src="screenshots/timeline_light.png" width="180" alt="Full memory timeline with mood/month filters, listing every entry logged per day, light theme"/></td>
    <td><img src="screenshots/timeline_dark.png" width="180" alt="Full memory timeline with mood/month filters, listing every entry logged per day, dark theme"/></td>
  </tr>
  <tr>
    <td>Affirmation cards</td>
    <td><img src="screenshots/start_drawing_light.png" width="180" alt="Rotating affirmation cards with an activity nudge, light theme"/></td>
    <td><img src="screenshots/talk_to_luna_screen_dark.png" width="180" alt="Rotating affirmation cards with an activity nudge, dark theme"/></td>
  </tr>
  <tr>
    <td>Breathing exercise</td>
    <td><img src="screenshots/breathing_light.png" width="180" alt="Breathing exercise, light theme"/></td>
    <td><img src="screenshots/breathing_dark.png" width="180" alt="Breathing exercise, dark theme"/></td>
  </tr>
  <tr>
    <td>Free drawing</td>
    <td><img src="screenshots/freedraw_light.png" width="180" alt="Free drawing canvas, light theme"/></td>
    <td><img src="screenshots/freedraw_dark.png" width="180" alt="Free drawing canvas, dark theme"/></td>
  </tr>
  <tr>
    <td>Sudoku</td>
    <td><img src="screenshots/sudoku_light.png" width="180" alt="Sudoku puzzle, light theme"/></td>
    <td><img src="screenshots/sudoku_dark.png" width="180" alt="Sudoku puzzle, dark theme"/></td>
  </tr>
  <tr>
    <td>Profile & settings</td>
    <td><img src="screenshots/profile_light.png" width="180" alt="Profile & settings, light theme"/></td>
    <td><img src="screenshots/profile_dark.png" width="180" alt="Profile & settings, dark theme"/></td>
  </tr>
  <tr>
    <td>Profile — more settings</td>
    <td><img src="screenshots/profile_choose_theme_and_language_light.png" width="180" alt="Profile scrolled to saved quotes, drawings, Sudoku history, and appearance/language settings, light theme"/></td>
    <td><img src="screenshots/profile_choose_theme_and_language_dark.png" width="180" alt="Profile scrolled to journal data, account deletion, and log out, dark theme"/></td>
  </tr>
</table>

More screenshots live in [`screenshots/`](screenshots/).

---

## Features

| Feature | Description |
| --- | --- |
| AI Mood Response | Share an emoji + thoughts → Luna replies with a warm, personalized note. If Luna can't answer, a fallback reply is shown but never saved to the journal or to saved quotes, and never shows the "saved to your journal" card. When a chat ends normally, the backend saves it as a journal entry |
| Follow-up Chat | Continue the conversation with Luna after the initial response. Before each send, the history is trimmed to the last 10 turns, 5000 characters per item and 12000 in total, and failure or fallback bubbles are never sent |
| Journal Screen | Streak, weekly letter, and a "recent memories" teaser showing each day's single most recent entry (mood or activity) — tapping a card opens Timeline scrolled to that day |
| Activity Journal Entries | Completing a breathing session, sudoku puzzle, or drawing logs a journal card for it alongside mood entries |
| Timeline | Full scrollable/searchable memory history, grouped by day, listing every entry logged that day (not just one per type) with mood and month filters |
| Streak & Plant | Daily journaling grows a virtual plant (seed → sprout → blooming), with a streak celebration screen |
| Weekly Letter | A short, friendly weekly note from Luna, with a few stats |
| Saved Quotes | Bookmark Luna's responses for later, view and delete them (with Undo), with a retry option if loading them fails |
| Content Reporting | Flag one of Luna's chat replies (offensive/harmful, inaccurate, uncomfortable, or other) with an optional comment, satisfying Google Play's requirement that AI-generated content be reportable in-app |
| Breathing Exercise | Guided breathe-in/breathe-out cycle with animated ring visuals |
| Affirmations | Emoji-specific rotating affirmation cards |
| Free Drawing | Open canvas for expressive/calming drawing, with a gallery of saved drawings (deleting one can be undone) |
| Sudoku | Playable sudoku puzzles with move validation and saved results history (deleting a result can be undone) |
| Mood Choice Dialog | After every mood entry, a lightweight prompt offering Talk to Luna, Breathe, Draw or Sudoku; the choice leads to an affirmation card, then the activity |
| Auth | Email/password and Google Sign-In via Firebase Auth, plus forgot-password flow |
| Age Confirmation | Self-declaration checkbox ("I'm 18 or older") on register; for a new account created via a path with no checkbox (Google Sign-In on either auth screen), a mandatory modal gates access instead — declining rolls the account back. Confirmed per-account locally so returning users aren't re-prompted; never sent to the backend |
| Delete Journal Entries | From Profile, deletes all journal entries on the backend, which also clears Luna's saved memory on the server, so Luna no longer builds on the entries; any open chat is reset too. Saved drawings, quotes and Sudoku history stay on the device |
| Account Deletion | Permanently delete your account and all associated data from Profile settings |
| Profile Refresh | The Profile tab reloads its quotes, drawings and Sudoku history each time it becomes visible again |
| Dark / Light Theme | User-selectable, persisted locally, applied instantly across the app |
| Localization | English and Arabic, including RTL layout, via `AppLocalizations` (Flutter `intl`/l10n) |
| Analytics & Crash Reporting | Firebase Analytics + Sentry (with a privacy filter that scrubs sensitive data before sending) |
| Onboarding | First-launch walkthrough introducing Luna and the app's core loop. A returning account never sees it after login; a brand-new device goes Onboarding → Register |
| Guest Mode | Use breathing, drawing, and Sudoku without an account — Luna's AI responses require signing in, and guest-created content doesn't persist between sessions. Profile shows Log in / Register instead of Log out while in a guest session |

---

## Tech Stack

| Layer | Technology |
| --- | --- |
| Framework | Flutter (Dart) |
| State Management | flutter_bloc (Cubit) |
| Navigation | go_router |
| Auth | Firebase Auth (email/password + Google Sign-In via `google_sign_in`) |
| Backend | Django REST Framework, deployed on Railway |
| Local Storage | Hive (see [Local storage](#local-storage)) + `shared_preferences` (theme, language) |
| Networking | Dio + PrettyDioLogger |
| DI | GetIt |
| Error Handling | dartz (`Either<Failure, T>`) |
| Code Generation | json_serializable, build_runner |
| Responsive UI | flutter_screenutil |
| Localization | flutter_localizations + `intl` (ARB-based, `lib/l10n/`) |
| Analytics / Crash Reporting | firebase_analytics, sentry_flutter, sentry_dio |
| Misc | confetti (streak celebration), lottie (animations), screenshot + share_plus (sharing saved content) |

---

## Architecture

Clean Architecture with strict layer separation:

```text
Presentation  (Screens, Widgets, Cubits)
     ↓
Domain        (Entities, Repository interfaces, Use Cases)
     ↓
Data          (Models, Repository impls, DataSources)
     ↓
External      (Django API, Firebase, Hive, SharedPreferences, Dio)
```

Dependencies point downward only — presentation never talks to data directly, and the domain layer has zero Flutter imports. Two known deviations: `MoodCubit` takes `MoodRepository` directly (plus `JournalRefreshSignal`), and `WeeklyLetterCubit` takes a datasource directly; neither pattern is used for new code.

### Feature Structure

```text
lib/
├── core/
│   ├── chat/              — ChatResetSignal, tells open chats to forget their history after a journal wipe
│   ├── constants/         — AppSizes, AppSpacing, AppLimits (chat size limits)
│   ├── errors/            — Failure classes (NetworkFailure, ServerFailure, ...)
│   ├── injection/         — single setupInjection() — all GetIt registrations
│   ├── journal/           — JournalRefreshSignal, a lightweight cross-feature refresh signal
│   ├── models/            — shared UI models (MoodType, JournalCardColor, MoodChoiceDestination)
│   ├── monitoring/        — Sentry privacy filter (scrubs PII before reporting)
│   ├── navigation/        — shell screen, bottom nav bar
│   ├── networking/        — DioHelper, ApiEndpoints, AuthTokenInterceptor
│   ├── preferences/       — OnboardingPrefs, AgeConfirmationPrefs, AuthPrefs, StreakCelebrationPrefs (small Hive-backed flags; onboarding and age are per-uid)
│   ├── routing/           — GoRouter config (router_generation_config.dart, app_routes.dart)
│   ├── startup/           — app_initializer.dart, the Firebase/Hive/SharedPreferences/DI bootstrap sequence
│   ├── styling/           — AppTheme, AppColors, AppExtraColors, text styles, fonts
│   ├── theme/             — theme-related core widgets/helpers
│   ├── utils/             — shared helpers: calendar_days (calendarDaysAgo), local_entry_id (unique negative ids for local-only entries), streak_calculator, duration_format, list_ops
│   └── widgets/           — shared reusable widgets, incl. AppTopBar (canonical app bar for pushed/detail screens) and showUndoSnackBar (Undo snackbar for deletes)
│
├── features/
│   ├── affirmation/       — emoji-specific affirmation cards
│   ├── auth/               — login, register, forgot password, age confirmation, Firebase + Django auth
│   ├── breathing/          — guided breathe-in/breathe-out exercise
│   ├── chat/                — follow-up chat with Luna
│   ├── draw/                — free drawing canvas + saved drawings gallery
│   ├── home/                — mood input, AI response trigger, history, weekly letter
│   ├── journal/             — journal screen (streak, weekly letter, recent memories), and the full searchable/filterable timeline
│   ├── language/            — language preference (Cubit, local datasource, sync usecase)
│   ├── mood_choice/         — post-mood-selection activity dialog (presentation-only)
│   ├── onboarding/          — first-launch walkthrough (presentation-only)
│   ├── plant/                — streak calculation, plant growth visualization, celebration screen
│   ├── profile/              — user stats, settings entry point, logout (or Log in / Register for a guest session)
│   ├── quotes/                — save, browse, and delete Luna's saved responses
│   ├── report/                 — flag one of Luna's chat replies (reason + optional comment)
│   ├── response/               — AI-generated response screen + save-quote action
│   ├── splash/                  — entry point, decides auth/onboarding redirect
│   ├── sudoku/                   — sudoku puzzle generation, play, and saved results
│   └── theme/                     — light/dark theme preference (Cubit, local datasource)
│
├── l10n/                    — ARB files + generated AppLocalizations (en, ar)
├── firebase_options.dart    — generated Firebase config (FlutterFire CLI)
└── main.dart                — Firebase/Hive/DI/Sentry bootstrap, app entry point
```

`onboarding` and `mood_choice` are intentionally presentation-only — no domain/data layers exist for them since they hold no business logic of their own.

---

## Backend API

Base URL: `https://web-production-f8628.up.railway.app`

| Method | Endpoint | Description |
| --- | --- | --- |
| POST | `/api/v1/auth/verify/` | Verify a Firebase ID token with the backend |
| GET | `/api/v1/accounts/me/` | Fetch the current user's account/profile info |
| PATCH | `/api/v1/accounts/me/` | Update the user's preferred language (`preferred_language`); failures are non-fatal and retried later |
| DELETE | `/api/v1/accounts/delete-account/` | Permanently delete the current user's account and all associated data |
| POST | `/api/v1/companion/generate/` | Generate Luna's reply for an emoji + thoughts entry; also used by the follow-up chat (with trimmed `history`) |
| GET | `/api/v1/companion/history/` | Fetch the current user's mood history |
| GET | `/api/v1/companion/weekly-letter/` | Get the weekly note from Luna |
| POST | `/api/v1/companion/activity/` | Log a completed non-chat activity (breathing/sudoku/drawing) |
| POST | `/api/v1/companion/report/` | Submit a report flagging one of Luna's chat responses |
| DELETE | `/api/v1/companion/entries/delete-all/` | Delete every journal entry for the authenticated user |
| DELETE | `/api/v1/companion/entries/{id}/delete/` | Delete a single journal entry by id. A 404 counts as already deleted; entries that only exist on the device (negative ids) are removed locally without a request |

Requests are authenticated with a Firebase ID token attached by `AuthTokenInterceptor` (`core/networking/`).

### Local storage

| Store | Name | Keys |
| --- | --- | --- |
| Hive | `mood_cache` | `entries_<uid>` |
| Hive | `saved_quotes` | `quotes_<uid>` |
| Hive | `sudoku_results` | `sudoku_results_<uid>` |
| Hive | `saved_drawings` | `drawings_<uid>` |
| Hive | `onboarding` | `seen_<uid>`, `pending` (completion not yet attributed to an account), legacy `seen` (read-only) |
| Hive | `age_confirmation` | `confirmed_<uid>` |
| Hive | `auth` | `hasEverAuthenticated` |
| Hive | `streak_celebration` | `last_milestone` |
| `shared_preferences` | — | `theme_mode`, `preferred_language` |

Guest-created mood entries, drawings and Sudoku results are cleared at every app start. Entries that exist only on the device (placeholders, guest activities) get unique negative ids so they never collide with server ids.

---

## Setup

### Prerequisites

- Flutter SDK (Dart ≥ 3.0.0)
- Android Studio / Xcode
- A Firebase project (Auth + Analytics enabled) with `google-services.json` / `GoogleService-Info.plist` configured
- FlutterFire CLI to (re)generate `lib/firebase_options.dart` if setting up a new Firebase project
- Access to the deployed Django backend (or a local instance)

### Install & Run

```bash
# Install dependencies
flutter pub get

# Generate code (Hive adapters + JSON serialization)
dart run build_runner build --delete-conflicting-outputs

# Run the app
flutter run

# Run on a specific device
flutter run -d ios
flutter run -d android
```

### Optional runtime configuration

Sentry crash reporting and the environment label are supplied at build/run time via `--dart-define` (never hardcoded):

```bash
flutter run --dart-define=SENTRY_DSN=your-dsn --dart-define=APP_ENV=development
```

If `SENTRY_DSN` is omitted, Sentry simply stays inactive — the app runs normally.

### Build for Release

```bash
flutter build apk --release
flutter build ios --release
```

### Tests & Lint

```bash
flutter test
flutter analyze
```

---

## Design System

### Colors

| Role | Light | Dark |
| --- | --- | --- |
| Primary | Peach `#E8621A` | Purple `#7C5CDB` |
| Background | Cream `#FFF8F5` | Deep `#16132A` |
| Surface | `#FFF0E8` | `#1E1A35` |
| Text Primary | Dark brown `#2D2016` | Light purple `#EDE9FE` |
| Secondary text | `#7A5038` | `#6B6490` |

Extra semantic colors (mood colours, surface variants) live in `AppExtraColors`, a `ThemeExtension` accessed via `Theme.of(context).extension<AppExtraColors>()`.

### Typography

Two text style systems coexist by design:

| Class | Scaling | Used by |
| --- | --- | --- |
| `AppTextStyles` | Custom `_scale()` clamp based on screen width | Newer screens (splash, onboarding, auth) |
| `ThemeTextStyles` | `flutter_screenutil` (`.sp`) | Older feature screens (home, journal, etc.) |

Fonts: **Nunito** (primary body/UI), **DMSerifDisplay** (display/italic headings), and **DM Sans**, all bundled locally as assets — runtime fetching via `google_fonts` is disabled (`GoogleFonts.config.allowRuntimeFetching = false`) to avoid blocking cold starts on a network call.

### Spacing Grid

8px base — use `AppSizes` / `AppSpacing` constants and `flutter_screenutil` (`.r`/`.w`/`.h`), not raw literals.

---

## Key Design Decisions

1. **Cubit over Bloc** — simpler for this app size, no complex event streams needed
2. **Hive over SQLite** — no schema migrations, fast for simple local models (mood entries, quotes, sudoku results, drawings)
3. **GetIt over Provider/Riverpod for DI** — decoupled from the widget tree, easier to test
4. **MoodCubit as a singleton** — shared state across all bottom-nav tabs (home / journal / profile)
5. **Firebase Auth** — handles email/password + Google Sign-In; the Django backend verifies the Firebase ID token
6. **Sealed classes over Freezed** for state unions — native Dart 3 `sealed class` + exhaustive `switch`
7. **Theme & language persisted locally** — no flash on cold start, consistent across logout
8. **Sentry privacy filter** — `beforeSend` hook scrubs sensitive data before any crash report leaves the device
9. **Guest mode never calls the AI backend** — deliberate, to avoid unauthenticated usage of a paid, Groq-backed third-party service; guest-created content is cleared on app restart by design, not a bug
10. **Age confirmation is enforced centrally, not per-screen** — a shared `handleAuthSuccess` handler reacts to `AuthAuthenticated` for both login and register, so the gate can't be bypassed by entering through a path with no checkbox of its own (e.g. Google Sign-In on the login screen)

---

## State Management

All state is managed through Cubits. Pattern used throughout:

```dart
// In cubit
emit(Loading());
final result = await repository.doSomething();
result.fold(
  (failure) => emit(Error(failure.message)),
  (data)    => emit(Success(data)),
);

// In UI
BlocBuilder<XCubit, XState>(
  builder: (context, state) => switch (state) {
    XSuccess(:final data)  => DataWidget(data),
    XLoading()             => LoadingWidget(),
    XError(:final message) => ErrorWidget(message),
    _                      => const SizedBox(),
  },
);
```

---

## Developer

**Riyam** — sole developer
