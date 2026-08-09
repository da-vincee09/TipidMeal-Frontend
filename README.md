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

### Coming Next

* 🔲 User profile
* 🔲 Profile editing
* 🔲 Home screen
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
* **Supabase** — Authentication and backend services
* **Poppins** — Application typography

---

## Project Structure

The project follows a feature-oriented architecture with separation between presentation, domain, and data layers.

```text
lib/
├── app/
│   ├── colors.dart
│   └── theme.dart
│
├── core/
│   ├── constants/
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

Handles communication with Supabase and implements domain repositories.

```text
data/
├── datasources/
└── repositories/
```

This structure makes it easier to replace or modify the data source without tightly coupling the UI to Supabase.

---

## Authentication

Authentication is handled through Supabase.

The current authentication operations include:

```text
Sign Up
   ↓
Supabase Auth

Login
   ↓
Supabase Auth

Reset Password
   ↓
Supabase Auth

Sign Out
   ↓
Supabase Auth
```

Riverpod manages the asynchronous state of authentication operations using `AsyncValue`.

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

The authentication screens use a more distinctive food-themed visual style while still following the application's overall theme.

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

Do **not** commit private credentials, service-role keys, or other sensitive secrets to Git.

---

## Roadmap

### Phase 1 — Authentication

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

### Phase 2 — Profile

* [ ] Create profile model
* [ ] Create Supabase profiles table
* [ ] Profile datasource
* [ ] Profile repository
* [ ] Profile provider/controller
* [ ] View profile
* [ ] Edit profile
* [ ] Save profile
* [ ] Profile avatar

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

**Current milestone: Authentication complete 🎉**

The next major milestone is the **Profile feature**, followed by the **Home and meal recommendation system**.

---

## License

This project is currently under development.
