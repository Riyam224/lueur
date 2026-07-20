# Lueur — AI Therapist & Mood Journal

> Your pocket therapist. Talk to Luna, track your moods, and grow together.

---

## What is Lueur?

Lueur is a Flutter mobile app that acts as an AI-powered mood journal and therapist companion. Users share how they feel through emoji and free-text thoughts, and Luna (powered by GROQ's LLM) responds with empathetic, personalized reflections. The app tracks mood history, visualizes emotional patterns, and gamifies consistency through a plant-growth streak system.

---

## Screenshots

<table>
  <tr>
    <td><img src="screenshots/1.png" width="200" alt="Screenshot 1"/></td>
    <td><img src="screenshots/2.png" width="200" alt="Screenshot 2"/></td>
    <td><img src="screenshots/3.png" width="200" alt="Screenshot 3"/></td>
  </tr>
  <tr>
    <td><img src="screenshots/4.png" width="200" alt="Screenshot 4"/></td>
    <td><img src="screenshots/5.png" width="200" alt="Screenshot 5"/></td>
    <td><img src="screenshots/6.png" width="200" alt="Screenshot 6"/></td>
  </tr>
  <tr>
    <td><img src="screenshots/7.png" width="200" alt="Screenshot 7"/></td>
    <td><img src="screenshots/9.png" width="200" alt="Screenshot 9"/></td>
  </tr>
</table>

---

## Features

| Feature | Description |
| --- | --- |
| AI Mood Response | Share emoji + thoughts → Luna responds with empathy via GROQ AI |
| Mood Journal | Full history of all entries with search and emoji filter |
| Streak & Plant | Daily journaling grows a virtual plant (seed → sprout → blooming) |
| Weekly Letter | AI-generated weekly emotional reflection with stats |
| Saved Quotes | Bookmark Luna's responses for later |
| Breathing Exercise | Guided 4-7-8 breathing technique |
| Affirmations | Emoji-specific affirmation cards |
| Dark / Light Theme | Persisted across sessions via Hive |
| Google OAuth | Sign in with Google or email/password via Supabase |

---

## Tech Stack

| Layer | Technology |
| --- | --- |
| Framework | Flutter (Dart) |
| State Management | flutter_bloc (Cubit) |
| Navigation | go_router |
| Auth | Supabase (email + Google OAuth) |
| Backend | Django REST Framework on Railway |
| AI | GROQ API — llama-3.1-8b-instant |
| Local Storage | Hive |
| Networking | Dio + PrettyDioLogger |
| DI | GetIt |
| Error Handling | dartz (Either) |
| Code Generation | json_serializable, build_runner |
| Responsive UI | flutter_screenutil |

---

## Architecture

Clean Architecture with strict layer separation:

```text
Presentation  (Screens, Cubits)
     ↓
Domain        (Entities, Repository interfaces, Use Cases)
     ↓
Data          (Models, Repository impls, DataSources)
     ↓
External      (Django API, Supabase, Hive, Dio)
```

### Feature Structure

```text
lib/
├── core/
│   ├── constants/         — spacing, sizes
│   ├── cubits/            — ThemeCubit
│   ├── errors/            — Failure classes
│   ├── injection/         — GetIt DI setup
│   ├── models/            — shared UI models
│   ├── navigation/        — shell screen, bottom nav bar
│   ├── networking/        — DioHelper, ApiEndpoints
│   ├── routing/           — GoRouter config, route constants
│   └── styling/           — AppColors, AppTheme, AppExtraColors, text styles
│
├── features/
│   ├── affirmation/       — emoji-specific affirmation cards
│   ├── auth/              — login, register, Supabase auth
│   ├── breathing/         — 4-7-8 breathing exercise
│   ├── home/              — mood input, AI response, history, weekly letter
│   ├── journal/           — searchable history screen
│   ├── plant/             — streak calculation, plant growth visualization
│   ├── profile/           — user stats, settings, logout
│   └── quotes/            — save and browse Luna's responses
│
└── main.dart              — app init, Supabase listener, DI bootstrap
```

---

## Backend API

Base URL: `https://web-production-f8628.up.railway.app`

| Method | Endpoint | Description |
| --- | --- | --- |
| POST | `/api/therapist/generate/` | Generate AI response for emoji + thoughts |
| GET | `/api/therapist/history/?user_id=` | Fetch user's mood history |
| GET | `/api/therapist/weekly-letter/` | Get AI weekly reflection |

**Generate request body:**

```json
{
  "user_id": "<supabase-uuid>",
  "emoji": "😔",
  "thoughts": "I feel overwhelmed today"
}
```

**Generate response:**

```json
{
  "id": 1,
  "user_id": "abc123",
  "emoji": "😔",
  "thoughts": "I feel overwhelmed today",
  "ai_response": "It sounds like you're carrying a lot...",
  "created_at": "2026-04-08T11:00:00Z"
}
```

---

## Setup

### Prerequisites

- Flutter SDK
- Dart SDK
- Android Studio / Xcode
- A Supabase project
- Access to the deployed Django backend

### Environment Variables

Create a `.env` file in the project root (never commit this):

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

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

### Build for Release

```bash
flutter build apk --release
flutter build ios --release
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

### Typography

`AppTextStyles` + `ThemeTextStyles` — never hardcode font sizes.

### Spacing Grid

8px base — use `AppSpacing` constants.

---

## Key Design Decisions

1. **Cubit over Bloc** — simpler for this app size, no complex event streams needed
2. **Hive over SQLite** — no schema migrations, fast for simple models
3. **GetIt over Provider for DI** — decoupled from widget tree, easier to test
4. **MoodCubit as singleton** — shared state across all bottom nav tabs
5. **Supabase for auth** — handles email + Google OAuth with minimal code
6. **Offline fallback** — history cached in Hive, served when API unavailable
7. **Theme persisted in Hive** — no flash on cold start, consistent across logout

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
