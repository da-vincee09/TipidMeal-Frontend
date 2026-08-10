# TipidMeal 🍽️

A budget-friendly meal recommendation app designed to help users discover practical meals based on their budget and preferences.

> **Project status:** 🚧 In Development

## Current Progress

### Authentication — ✅ Complete

The authentication flow is currently implemented using **Supabase Auth** and **Flutter Riverpod**.

Implemented:

* ✅ User sign up
* ✅ User login
* ✅ Password reset
* ✅ User sign out
* ✅ Authentication state listening
* ✅ Current user access
* ✅ Access token access
* ✅ Loading and error states through `AsyncValue`
* ✅ Reusable Snackbar extension
* ✅ Light and dark theme support
* ✅ Custom authentication UI
* ✅ Post-auth routing (Login/Register/Splash all check profile status, not just session, before deciding where to send the user)

### Profile — ✅ Complete

The profile feature connects to an already-implemented FastAPI + PostgreSQL backend (via Supabase-hosted Postgres and Supabase Storage), using the same layered Riverpod architecture as Authentication.

Implemented:

* ✅ Profile model, create/update request models
* ✅ Profile remote datasource (Dio-based, typed `ApiException` mapping for 401/404/422/500/network errors)
* ✅ Profile repository + Riverpod controller (`loadProfile`, `createProfile`, `updateProfile`, `uploadProfileImage`)
* ✅ Shared `ProfileForm` widget used by both onboarding and editing (single source of truth for fields, validation, and layout)
* ✅ **Profile Setup** — one-time onboarding screen shown when a logged-in user has no profile yet (`GET /profiles/me` → 404)
* ✅ **Profile screen** — view mode with an Edit toggle that reuses `ProfileForm`, pre-filled, to update via `PUT`
* ✅ **Profile picture upload** — pick from gallery, uploaded via a dedicated FastAPI endpoint (`POST /profiles/me/image`) backed by a public Supabase Storage bucket; deferred upload pattern (image is picked in the form, then uploaded right after the profile itself is successfully created/updated)
* ✅ Splash-screen routing: session check → profile check → routes to Login / Profile Setup / Home accordingly
* ✅ Login and Register both re-check profile status after authenticating, instead of assuming Home — so a user who signed up but never finished Setup is correctly routed back to it on their next login
* ✅ Discard-changes confirmation when canceling an in-progress profile edit

### Coming Next

* 🔲 Home screen (currently a placeholder with sign-out and a link into Profile)
* 🔲 Meal recommendations
* 🔲 Budget-based meal filtering
* 🔲 Meal details
* 🔲 Food categories
* 🔲 Favorites
* 🔲 Additional app features

---

## Tech Stack

* **Flutter** — Mobile application framework
* **Dart** — Programming language
* **Riverpod** — State management
* **Supabase** — Authentication, Postgres hosting, and file storage
* **FastAPI** — Backend REST API (profiles, and future feature endpoints)
* **Dio** — HTTP client for talking to the FastAPI backend
* **image_picker** — Profile picture selection
* **Poppins** — Application typography

---

## Project Structure

The project follows a feature-oriented architecture with separation between presentation, domain, and data layers.

```text
lib/
├── app/
│   ├── colors.dart
│   ├── routes.dart
│   ├── router.dart
│   └── theme.dart
│
├── core/
│   ├── constants/
│   │   └── profile_options.dart
│   ├── errors/
│   │   └── api_exception.dart
│   ├── extensions/
│   ├── networks/
│   ├── services/
│   ├── utils/
│   └── widgets/
│
├── features/
│   ├── authentication/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   └── repositories/
│   │   └── presentation/
│   │       ├── providers/
│   │       ├── screens/
│   │       └── widgets/
│   │
│   ├── profile/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── profile_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   ├── profile_model.dart
│   │   │   │   ├── profile_create_request.dart
│   │   │   │   ├── profile_update_request.dart
│   │   │   │   ├── food_allergy_model.dart
│   │   │   │   └── disliked_ingredient_model.dart
│   │   │   ├── repositories/
│   │   │   │   └── profile_repository_impl.dart
│   │   │   └── profile_dependencies.dart
│   │   ├── domain/
│   │   │   └── repositories/
│   │   │       └── profile_repository.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── profile_provider.dart
│   │       ├── screens/
│   │       │   ├── profile_setup_screen.dart
│   │       │   └── profile_screen.dart
│   │       └── widgets/
│   │           └── profile_form.dart
│   │
│   └── home/
│       ├── data/
│       ├── domain/
│       └── presentation/
│           └── screens/
│
└── shared/
    ├── extensions/
    ├── models/
    ├── providers/
    └── widgets/
```

---

## Architecture

The application uses a layered approach to keep the UI, business logic, and data access separated.

For authentication, the current flow is:

```text
UI
 │
 ▼
AuthController
 │
 ▼
AuthRepository
 │
 ▼
AuthRepositoryImpl
 │
 ▼
AuthRemoteDatasource
 │
 ▼
Supabase Auth
```

For profile, the same pattern is used against the FastAPI backend instead:

```text
UI (ProfileSetupScreen / ProfileScreen / ProfileForm)
 │
 ▼
ProfileController (Riverpod Notifier — loadProfile, createProfile,
                    updateProfile, uploadProfileImage)
 │
 ▼
ProfileRepository (domain contract)
 │
 ▼
ProfileRepositoryImpl
 │
 ▼
ProfileRemoteDatasource (Dio → FastAPI)
 │
 ▼
FastAPI  ──▶  PostgreSQL (profile data)
        └──▶  Supabase Storage (profile pictures, via a
               dedicated FastAPI upload endpoint using a
               server-side service-role key)
```

### Presentation

Responsible for screens, widgets, and Riverpod controllers.

```text
presentation/
├── providers/
├── screens/
└── widgets/
```

### Domain

Contains repository contracts and application-level abstractions.

```text
domain/
└── repositories/
```

### Data

Handles communication with Supabase/FastAPI and implements domain repositories.

```text
data/
├── datasources/
└── repositories/
```

This structure makes it easier to replace or modify the data source without tightly coupling the UI to Supabase or FastAPI.

---

## Authentication

Authentication is handled through Supabase.

The current authentication operations include:

```text
Sign Up
   ↓
Supabase Auth
   ↓
Check profile status → Profile Setup (no profile) or Home (has profile)

Login
   ↓
Supabase Auth
   ↓
Check profile status → Profile Setup (no profile) or Home (has profile)

Reset Password
   ↓
Supabase Auth

Sign Out
   ↓
Supabase Auth
```

Riverpod manages the asynchronous state of authentication operations using `AsyncValue`.

App start (splash) follows the same profile-status check:

```text
Splash
  ↓
Check Supabase session
  ↓
No session            → Login
Session, no profile   → Profile Setup
Session, has profile  → Home
Error checking either → Error state with retry
```

---

## Profile

Profile data (name, date of birth, sex, daily budget, cooking skill level, food allergies, disliked ingredients, and profile picture) is managed through a FastAPI backend, authenticated via Supabase JWTs verified server-side against Supabase's JWKS endpoint.

```text
Create Profile (onboarding, once per user)
   ↓
POST /profiles

Get Profile
   ↓
GET /profiles/me

Update Profile
   ↓
PUT /profiles/me

Upload Profile Picture
   ↓
POST /profiles/me/image   (multipart upload → Supabase Storage,
                            public URL saved back onto the profile row)
```

`ProfileSetupScreen` and `ProfileScreen`'s edit mode share a single `ProfileForm` widget, so field definitions, validation, and the picture picker only exist in one place. The picture is picked locally in the form and uploaded as a follow-up step only after the profile itself has been successfully created or updated — the upload endpoint requires an existing profile row, so it can't run before that.

---

## UI & Theme

The app currently supports both light and dark themes.

### Brand Colors

The primary visual identity uses warm food-inspired colors:

* Orange
* Burnt Orange
* Cream
* Olive Green
* Green

The authentication screens use a more distinctive food-themed visual style (hero image, colored background, card-over-background layout) while the Profile screens currently use a simpler, flatter layout using the same color tokens and pill-input styling. Bringing Profile Setup in line with the auth screens' hero/card motif is a possible future polish item.

### Typography

The application uses **Poppins** as its primary font.

---

## Development

### Requirements

Make sure you have the following installed:

* Flutter SDK
* Dart SDK
* Android Studio or Xcode
* A Supabase project
* A running instance of the FastAPI backend (see backend repo/folder), with:
  * `SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` configured for server-side Storage uploads
  * `python-multipart` installed (required for file upload endpoints)

### Install Dependencies

```bash
flutter pub get
```

### Run the Application

```bash
flutter run
```

### Analyze the Project

```bash
flutter analyze
```

### Run Tests

```bash
flutter test
```

---

## Environment Configuration

Supabase credentials should be configured through the project's environment/configuration setup.

The backend additionally requires:

* `DATABASE_URL`
* `SUPABASE_URL`
* `SUPABASE_SERVICE_ROLE_KEY` (server-side only — used for Storage uploads, bypasses Row Level Security, must never be exposed client-side)

Do **not** commit private credentials, service-role keys, or other sensitive secrets to Git.

---

## Roadmap

### Phase 1 — Authentication ✅

* [x] Project structure
* [x] Supabase integration
* [x] Authentication datasource
* [x] Authentication repository
* [x] Riverpod authentication controller
* [x] Sign up
* [x] Login
* [x] Password reset
* [x] Sign out
* [x] Authentication UI
* [x] Theme and colors

### Phase 2 — Profile ✅

* [x] Create profile model
* [x] Supabase-hosted Postgres profiles table (backend, pre-existing)
* [x] Profile datasource
* [x] Profile repository
* [x] Profile provider/controller
* [x] View profile
* [x] Edit profile
* [x] Save profile
* [x] Profile avatar (upload, display, and edit)
* [x] Onboarding gate (Profile Setup) wired into splash/login/register routing

### Phase 3 — Home

* [ ] Home screen
* [ ] Meal categories
* [ ] Meal recommendation UI
* [ ] Budget information
* [ ] Navigation

### Phase 4 — Meal Recommendations

* [ ] Meal data model
* [ ] Meal repository
* [ ] Recommendation logic
* [ ] Budget-based filtering
* [ ] Meal details
* [ ] Ingredients
* [ ] Cooking instructions

### Phase 5 — Additional Features

* [ ] Favorites
* [ ] Search
* [ ] User preferences
* [ ] Improved recommendations
* [ ] Notifications
* [ ] Additional UI/UX improvements

---

## Project Status

**Current milestone: Profile feature complete 🎉**

The next major milestone is the **Home screen and meal recommendation system**.

---

## License

This project is currently under development.