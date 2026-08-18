# TipidMeal 🍽️

A budget-friendly meal recommendation app designed to help users discover practical, affordable meals based on their budget, cooking skills, dietary restrictions, ingredient preferences, and available pantry ingredients.

> **Project status:** 🚧 In Development — **Week 4 In Progress**

---

## 🚀 Current Progress

### Authentication — ✅ Complete

Authentication is implemented using **Supabase Auth** and **Flutter Riverpod**.

Implemented:

* ✅ User sign up
* ✅ User login
* ✅ Password reset
* ✅ User sign out
* ✅ Authentication state listening
* ✅ Current user access
* ✅ Supabase access token access
* ✅ Loading and error states through `AsyncValue`
* ✅ Reusable Snackbar extension
* ✅ Light and dark theme support
* ✅ Custom authentication UI
* ✅ Post-authentication profile-status routing
* ✅ Splash authentication and profile checks

Authentication routing checks both the Supabase session and application profile:

```text
Supabase Session
      ↓
Profile Status
      ↓
 ┌───────────────┬──────────────────┐
 │ No Session    │ Session Exists   │
 ↓               ↓                  │
Login        Profile Exists?        │
             ↓         ↓            │
            YES        NO           │
             ↓         ↓            │
           Home   Profile Setup     │
```

---

## 👤 Profile — ✅ Complete

The Profile feature connects to the FastAPI + PostgreSQL backend through Supabase-hosted PostgreSQL and Supabase Storage.

Implemented:

* ✅ Profile model
* ✅ Profile create/update request models
* ✅ Profile remote datasource
* ✅ Typed `ApiException` handling
* ✅ Profile repository
* ✅ Riverpod `ProfileController`
* ✅ Profile loading
* ✅ Profile creation
* ✅ Profile updating
* ✅ Profile picture selection
* ✅ Profile picture upload
* ✅ Profile picture caching
* ✅ Food allergies
* ✅ Disliked ingredients
* ✅ Daily budget
* ✅ Cooking skill level
* ✅ Shared `ProfileForm`
* ✅ Profile Setup onboarding
* ✅ Profile viewing/editing
* ✅ Discard-changes confirmation
* ✅ Profile-status routing after login/register
* ✅ Profile-status routing from splash

Profile image uploads use a dedicated FastAPI endpoint backed by Supabase Storage.

```text
Flutter
   ↓
Profile Form
   ↓
Create / Update Profile
   ↓
FastAPI
   ↓
PostgreSQL

Profile Image
   ↓
POST /profiles/me/image
   ↓
FastAPI
   ↓
Supabase Storage
   ↓
Public Image URL
   ↓
Profile
```

---

# 🏠 Home — ✅ Complete

The Home screen has been implemented as the application's primary dashboard.

Implemented:

* ✅ Personalized greeting
* ✅ User first name
* ✅ Daily budget display
* ✅ Pantry item count
* ✅ Top recommendation previews
* ✅ Recommendation cards
* ✅ Pull-to-refresh
* ✅ Profile refresh
* ✅ Pantry refresh
* ✅ Recommendation refresh
* ✅ Navigation to Meals
* ✅ Navigation to Recommendations
* ✅ Navigation to Pantry
* ✅ Navigation to Profile

The Home screen provides a summary of the user's current meal-planning information.

```text
Home
 ├── Greeting
 ├── Daily Budget
 ├── Pantry Summary
 ├── Top Recommendations
 └── Quick Navigation
```

---

# 🥫 Pantry — ✅ Complete

The Pantry feature allows users to manage ingredients currently available to them.

Implemented:

* ✅ Pantry item entity
* ✅ Pantry item model
* ✅ Remote datasource
* ✅ Repository
* ✅ Riverpod `PantryController`
* ✅ Load pantry items
* ✅ Add pantry item
* ✅ Edit pantry item
* ✅ Delete pantry item
* ✅ Quantity support
* ✅ Unit support
* ✅ Ingredient autocomplete
* ✅ Add ingredient dialog
* ✅ Edit ingredient dialog
* ✅ Loading states
* ✅ Error states
* ✅ Success snackbars
* ✅ Empty pantry state
* ✅ Pull-to-refresh
* ✅ JWT authentication
* ✅ User-specific pantry access
* ✅ Automatic recommendation refresh after pantry changes

Pantry operations communicate with the FastAPI backend using the authenticated Supabase access token.

```text
Flutter
   ↓
PantryController
   ↓
PantryRepository
   ↓
PantryRemoteDatasource
   ↓
FastAPI
   ↓
PostgreSQL
```

Pantry data is user-specific:

```text
Supabase User
      ↓
Authenticated JWT
      ↓
FastAPI get_current_user()
      ↓
Profile
      ↓
Pantry Items
```

A user cannot access another user's pantry through the application API.

---

# 🍳 Meals — ✅ Complete

The Meals feature provides access to the application's meal database.

Implemented:

* ✅ Meal entity
* ✅ Meal ingredient entity
* ✅ Meal instruction entity
* ✅ Meal model
* ✅ Meal remote datasource
* ✅ Meal repository
* ✅ Riverpod meal provider/controller
* ✅ Meal list
* ✅ Meal search
* ✅ Meal filtering
* ✅ Meal cards
* ✅ Meal detail screen
* ✅ Ingredients
* ✅ Ingredient quantities
* ✅ Cooking instructions
* ✅ Estimated cost
* ✅ Cooking time
* ✅ Difficulty
* ✅ Servings
* ✅ Calories
* ✅ Cached network images
* ✅ Graceful handling of meals without images
* ✅ Seeded meal database

Current seeded meals include:

* Chicken Adobo
* Garlic Fried Rice
* Beef Tapa
* Vegetable Lumpia
* Ginisang Munggo

Meal navigation supports nested meal-detail routes:

```text
Meals
  ↓
Meal Card
  ↓
Meal Details
  ├── Image
  ├── Estimated Cost
  ├── Cooking Time
  ├── Difficulty
  ├── Ingredients
  └── Instructions
```

---

# ⭐ Recommendations — ✅ Complete

The deterministic recommendation system is now implemented end-to-end.

The recommendation system does **not** depend on an AI API.

Instead, recommendations are calculated using explicit business rules and scoring.

The system considers:

* ✅ Ingredient availability
* ✅ Ingredient substitutions
* ✅ Ingredient quantities
* ✅ Optional ingredients
* ✅ Budget compatibility
* ✅ Cooking skill
* ✅ Food allergies
* ✅ Disliked ingredients
* ✅ Meal coverage
* ✅ Hybrid recommendation score
* ✅ Server-side ranking

Recommendation flow:

```text
Authenticated User
        ↓
Profile
        ↓
Pantry
        ↓
Meals
        ↓
Ingredient Availability
        ↓
Meal Adaptation
        ↓
Allergy Filtering
        ↓
Budget Score
        ↓
Skill Score
        ↓
Preference Score
        ↓
Coverage Score
        ↓
Hybrid Score
        ↓
Ranked Recommendations
```

### Recommendation scoring

The recommendation system uses an explicit weighted scoring model.

The current hybrid score considers:

```text
Ingredient Coverage     30%
Budget Compatibility    30%
Cooking Skill           10%
Allergy Compatibility   20%
Disliked Ingredients    10%
```

Meals containing allergies are excluded.

Meals requiring unavailable mandatory ingredients are excluded through the adaptation/fallback logic.

Available substitutes and optional ingredients can allow a meal to remain recommendable.

### Ingredient adaptation

The recommendation system recognizes several ingredient actions:

```text
retain
insufficient
substitute
omit
unavailable
```

Meals are classified as either:

```text
adapt
fallback
```

Fallback meals are filtered server-side and do not reach the Flutter client.

### Recommendation UI

Recommendation cards display information such as:

* Hybrid score
* Ingredient coverage
* Ingredient substitutions
* Low-stock/insufficient ingredient information
* Omitted optional ingredients
* Meal image
* Estimated cost

Pantry changes automatically trigger a recommendation refresh.

This is important because the Flutter application uses a persistent `StatefulShellRoute`, meaning screens can remain alive while the user switches tabs.

---

# 📅 Meal Planner — ✅ Complete

The Meal Planner feature allows users to schedule meals from the meal database onto specific dates and meal slots (breakfast/lunch/dinner), and view them as a weekly calendar.

Implemented:

**Backend**

* ✅ `MealPlanEntry` model with `profile_id`, `meal_id`, `planned_date`, `meal_slot`
* ✅ `meal` relationship (`lazy="joined"`) for eager-loaded meal summaries in responses
* ✅ Alembic migration for `meal_plan_entries`
* ✅ Pydantic schemas (`MealPlanEntryCreate`, `MealPlanEntryUpdate`, `MealPlanEntryResponse`, `WeeklyPlanResponse`)
* ✅ Repository layer (create, list by date range, get by id, update, delete)
* ✅ Service layer with profile-ownership checks and meal-existence validation
* ✅ Router (`/meal-planner`) with full CRUD endpoints
* ✅ `estimated_cost_total` computed server-side for the weekly response
* ✅ Profile-ownership enforcement (a user can only access their own plan entries)

**Flutter**

* ✅ `MealPlanEntryModel` / `WeeklyPlanModel` / `MealPlanMealSummaryModel`
* ✅ Create/update request models
* ✅ Remote datasource (`MealPlannerRemoteDatasource`)
* ✅ Repository (`MealPlannerRepository`)
* ✅ Riverpod `MealPlanController`
* ✅ Weekly calendar screen with day-tab navigation
* ✅ Previous/next week navigation
* ✅ Breakfast / Lunch / Dinner slot grouping
* ✅ Add meal to plan (meal picker + date picker + slot selector)
* ✅ Edit planned meal
* ✅ Delete planned meal with confirmation dialog
* ✅ Optimistic delete (instant UI update, rollback on failure)
* ✅ Silent background refresh after add/update (no loading flicker)
* ✅ Snackbar feedback via the shared context extension
* ✅ Loading, error, and empty states
* ✅ Pull-to-refresh
* ✅ Bottom navigation tab (`Planner`)
* ✅ JWT-authenticated requests via existing `AuthInterceptor`

```text
Flutter
   ↓
MealPlannerScreen
   ↓
MealPlanController
   ↓
MealPlannerRepository
   ↓
MealPlannerRemoteDatasource
   ↓
FastAPI (/meal-planner)
   ↓
PostgreSQL
```

Meal plan entries are scoped to the authenticated user's profile, consistent with Pantry's access model.

---

# 🧭 Navigation — ✅ Complete

The application now uses a bottom navigation shell containing:

```text
Home
Meals
Planner
Recommendations
Pantry
```

Profile remains accessible separately.

Meal details use nested routing:

```text
/meals/:id
```

Meal planner add/edit uses nested routing:

```text
/meal-planner/add
```

The navigation structure allows users to move through the primary application flow:

```text
Login
  ↓
Profile
  ↓
Home
  ↓
 ┌─────────┬───────────┬─────────┬────────────────┐
 ↓         ↓           ↓         ↓                ↓
Meals    Planner     Pantry   Recommendations   Profile
 ↓                              ↓
Details                    Meal Details
```

---

# 🔐 Authentication & API Security

The Flutter application communicates with the FastAPI backend using the authenticated Supabase access token.

Requests to protected endpoints include:

```text
Authorization: Bearer <Supabase Access Token>
```

The application uses an `AuthInterceptor` to obtain the current Supabase session and attach the access token to API requests.

```text
Flutter
   ↓
Supabase Session
   ↓
Access Token
   ↓
Dio AuthInterceptor
   ↓
FastAPI
   ↓
JWT Verification
   ↓
Current User
```

Protected backend features include:

* Profile
* Pantry
* Meal Planner
* Recommendations

User-specific data is always associated with the authenticated user's profile.

---

# 🏗️ Architecture

The Flutter application follows a feature-oriented layered architecture.

Each major feature is separated into:

```text
presentation/
domain/
data/
```

### Presentation

Responsible for:

* Screens
* Widgets
* Riverpod controllers/providers
* UI state

```text
presentation/
├── providers/
├── screens/
└── widgets/
```

### Domain

Contains application-level contracts and abstractions.

```text
domain/
├── entities/
└── repositories/
```

### Data

Responsible for API communication and repository implementations.

```text
data/
├── datasources/
├── models/
└── repositories/
```

Typical feature flow:

```text
Screen
  ↓
Riverpod Controller
  ↓
Repository
  ↓
Repository Implementation
  ↓
Remote Datasource
  ↓
FastAPI
```

This keeps UI code independent from the underlying API implementation.

---

# 📁 Project Structure

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
│   ├── errors/
│   ├── extensions/
│   ├── networks/
│   ├── services/
│   ├── utils/
│   └── widgets/
│
├── features/
│   │
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
│   │   │   ├── models/
│   │   │   ├── repositories/
│   │   │   └── profile_dependencies.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   └── repositories/
│   │   └── presentation/
│   │       ├── providers/
│   │       ├── screens/
│   │       └── widgets/
│   │
│   ├── home/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │       ├── screens/
│   │       └── widgets/
│   │
│   ├── pantry/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   └── repositories/
│   │   └── presentation/
│   │       ├── providers/
│   │       ├── screens/
│   │       └── widgets/
│   │
│   ├── meals/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   └── repositories/
│   │   └── presentation/
│   │       ├── providers/
│   │       ├── screens/
│   │       └── widgets/
│   │
│   ├── meal_planner/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   ├── repositories/
│   │   │   └── meal_planner_dependencies.dart
│   │   ├── domain/
│   │   │   └── repository/
│   │   └── presentation/
│   │       ├── providers/
│   │       ├── screens/
│   │       └── widgets/
│   │
│   └── recommendations/
│       ├── data/
│       │   ├── datasources/
│       │   ├── models/
│       │   └── repositories/
│       ├── domain/
│       │   ├── entities/
│       │   └── repositories/
│       └── presentation/
│           ├── providers/
│           ├── screens/
│           └── widgets/
│
└── shared/
    ├── extensions/
    ├── models/
    ├── providers/
    └── widgets/
```

---

# 🎨 UI & Theme

The application supports:

* ✅ Light theme
* ✅ Dark theme
* ✅ Poppins typography
* ✅ Food-inspired visual identity
* ✅ Burnt-orange primary accents
* ✅ Rounded Material cards
* ✅ Consistent input styling
* ✅ Cached network images
* ✅ Loading states
* ✅ Error states
* ✅ Empty states
* ✅ Snackbar feedback

### Brand Colors

The primary visual identity uses warm food-inspired colors:

* Orange
* Burnt Orange
* Cream
* Olive Green
* Green

The authentication, profile, pantry, meals, meal planner, recommendations, and home screens have been styled to maintain a consistent visual language.

---

# 🔌 Backend Integration

The Flutter application communicates with a FastAPI backend.

Current backend feature areas include:

```text
FastAPI
│
├── Authentication / JWT verification
│
├── Profiles
│
├── Pantry
│
├── Meals
│
├── Meal Planner
│
└── Recommendations
```

The general API flow is:

```text
Flutter
   ↓
Dio
   ↓
Authorization: Bearer <Supabase JWT>
   ↓
FastAPI
   ↓
JWT Verification
   ↓
Feature Router
   ↓
Service
   ↓
Repository
   ↓
PostgreSQL
```

Profile image uploads additionally use:

```text
FastAPI
   ↓
Supabase Storage
```

---

# 📊 Week 4 Application Flow

```text
Login
  ↓
Profile Check
  ↓
Home
  ↓
┌─────────────────────────────────────────────┐
│               │              │               │
↓               ↓              ↓               ↓
Meals        Planner        Pantry     Recommendations
│               │              │
↓               ↓              ↓
Meal Details  Add/Edit    Available Ingredients
              Entry              │
                                 ↓
                          Recommendations
                                 │
                                 ↓
                          Meal Details
```

Recommendations are personalized using:

```text
Profile
+
Pantry
+
Meals
+
Business Rules
      ↓
Ranked Recommendations
```

---

# 🧪 Testing & Edge Cases

Implemented and tested:

* ✅ Empty pantry
* ✅ Pantry CRUD
* ✅ Recommendation refresh after pantry changes
* ✅ Matching pantry ingredients
* ✅ Ingredient substitutions
* ✅ Optional ingredients
* ✅ Insufficient/low-stock ingredients
* ✅ Allergy filtering
* ✅ Disliked ingredient scoring
* ✅ Budget scoring
* ✅ Cooking skill scoring
* ✅ Server-side recommendation ranking
* ✅ Meal detail navigation
* ✅ Cached meal images
* ✅ Meals without images
* ✅ Authentication-protected API requests
* ✅ User-specific pantry data
* ✅ API loading states
* ✅ API error states
* ✅ Empty recommendation states
* ✅ Meal planner CRUD (create/read/update/delete)
* ✅ Meal planner weekly navigation
* ✅ Meal planner empty-day state
* ✅ Meal planner optimistic delete + rollback on failure
* ✅ Meal planner profile-ownership enforcement (backend)

---

# ⚙️ Development

## Requirements

Make sure you have:

* Flutter SDK
* Dart SDK
* Android Studio or Xcode
* A Supabase project
* A running TipidMeal FastAPI backend
* Supabase authentication configured
* Supabase PostgreSQL configured
* Supabase Storage configured

The backend must have the required environment variables configured, including:

```text
DATABASE_URL
SUPABASE_URL
SUPABASE_SERVICE_ROLE_KEY
```

The service-role key is **server-side only** and must never be included in the Flutter application.

---

## Install Dependencies

```bash
flutter pub get
```

---

## Run the Application

```bash
flutter run
```

---

## Analyze the Project

```bash
flutter analyze
```

---

## Run Tests

```bash
flutter test
```

---

# 🔐 Environment & Secrets

Supabase credentials should be provided through the project's environment/configuration system.

Do **not** commit:

* Supabase service-role keys
* Private API keys
* Database credentials
* JWT secrets
* `.env` files containing secrets

The Supabase service-role key belongs exclusively on the FastAPI backend.

---

# 🗺️ Roadmap

## Phase 1 — Authentication ✅

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
* [x] Profile-status routing

## Phase 2 — Profile ✅

* [x] Profile model
* [x] Profile datasource
* [x] Profile repository
* [x] Profile provider/controller
* [x] View profile
* [x] Edit profile
* [x] Create profile
* [x] Profile validation
* [x] Profile avatar selection
* [x] Profile avatar upload
* [x] Profile avatar caching
* [x] Food allergies
* [x] Disliked ingredients
* [x] Daily budget
* [x] Cooking skill level
* [x] Profile Setup onboarding

## Phase 3 — Core Application Features ✅

* [x] Home screen
* [x] Bottom navigation
* [x] Pantry feature
* [x] Pantry CRUD
* [x] Ingredient autocomplete
* [x] Meal data model
* [x] Meal repository
* [x] Meal list
* [x] Meal search
* [x] Meal details
* [x] Ingredients
* [x] Cooking instructions
* [x] Seed meals

## Phase 4 — Recommendation System ✅

* [x] Recommendation data model
* [x] Recommendation repository
* [x] Recommendation datasource
* [x] Recommendation controller
* [x] Ingredient availability
* [x] Quantity-aware pantry matching
* [x] Ingredient substitution
* [x] Optional ingredient handling
* [x] Allergy filtering
* [x] Disliked ingredient scoring
* [x] Budget scoring
* [x] Cooking skill scoring
* [x] Ingredient coverage scoring
* [x] Hybrid recommendation scoring
* [x] Recommendation ranking
* [x] Recommendation UI
* [x] Recommendation refresh after pantry changes
* [x] Match/coverage display

## Phase 5 — Integration & Polish ✅

* [x] Home → Meals navigation
* [x] Home → Pantry navigation
* [x] Home → Recommendations navigation
* [x] Recommendations → Meal Details
* [x] Pantry → Recommendations integration
* [x] Authentication → Profile → Home flow
* [x] JWT-protected API requests
* [x] Loading states
* [x] Error states
* [x] Empty states
* [x] UI consistency
* [x] Light/dark theme support
* [x] Cached network images
* [x] Final Week 2 screen polish

## Phase 6 — Meal Planner ✅

* [x] `MealPlanEntry` backend model + migration
* [x] Meal relationship fix (`lazy="joined"`)
* [x] Pydantic schemas
* [x] Repository / service / router (full CRUD)
* [x] `estimated_cost_total` fix
* [x] Flutter models, datasource, repository
* [x] Riverpod `MealPlanController`
* [x] Weekly calendar screen
* [x] Day-tab navigation
* [x] Add/edit meal plan entry screen
* [x] Meal picker with search
* [x] Delete with confirmation dialog
* [x] Optimistic delete + rollback
* [x] Snackbar feedback (shared extension)
* [x] Bottom navigation integration

---

# 🚧 Future / Not Yet Implemented Features

The following features are **not yet implemented** and are the primary focus for the remainder of Week 4.

### ⚙️ Settings — 🔲 Not Yet Implemented

Planned functionality includes:

* [ ] Settings screen
* [ ] Theme preferences
* [ ] Dark mode toggle
* [ ] Light mode toggle
* [ ] Account-related settings
* [ ] Sign out
* [ ] Additional application preferences

> **Note:** The application already supports light and dark themes at the theme level, but a user-facing Settings screen for controlling these preferences has not yet been implemented.

### 🔐 Sign Out in Settings — 🔲 Not Yet Implemented

Supabase sign-out functionality already exists as part of Authentication.

However, the final UI location for sign-out is planned to be:

```text
Settings
   ↓
Sign Out
   ↓
Supabase Auth
   ↓
Login
```

### ⭐ Favorites / Saved Meals — 🔲 Not Yet Implemented

* [ ] Save meals
* [ ] Remove saved meals
* [ ] Favorites screen
* [ ] Persistent saved meals

### 🛒 Grocery List Generator — 🔲 Not Yet Implemented

* [ ] Generate grocery list from planned meals
* [ ] Combine duplicate ingredients across the week
* [ ] Track purchased ingredients
* [ ] Integrate grocery requirements with pantry
* [ ] Weekly budget overview based on planned meals

### 🔎 Advanced Meal Search & Filtering — 🔲 Not Yet Implemented

* [ ] Food category filtering
* [ ] Cost filtering
* [ ] Cooking-time filtering
* [ ] Difficulty filtering
* [ ] More advanced ingredient filtering

### 🍱 Food Categories — 🔲 Not Yet Implemented

* [ ] Breakfast
* [ ] Lunch
* [ ] Dinner
* [ ] Snacks
* [ ] Category-based filtering

### 🥗 Nutrition Information — 🔲 Not Yet Implemented

* [ ] Detailed nutritional information
* [ ] Protein
* [ ] Carbohydrates
* [ ] Fat
* [ ] Other nutritional metrics

Basic calorie information is currently available for seeded meals, but a complete nutrition feature has not yet been implemented.

### 🔔 Notifications — 🔲 Not Yet Implemented

* [ ] Meal recommendations notifications
* [ ] Pantry reminders
* [ ] Meal-planning reminders
* [ ] Other application notifications

### 🤖 AI-Assisted Recommendations — 🔲 Not Yet Implemented

The current recommendation system intentionally uses deterministic and explainable business rules.

AI integration is deferred until the deterministic recommendation system can be evaluated independently.

Potential future functionality:

* [ ] AI-assisted meal recommendations
* [ ] Natural-language recommendation explanations
* [ ] AI-assisted ingredient substitutions
* [ ] Personalized recommendation explanations

### 🛠️ Admin Functionality — 🔲 Not Yet Implemented

* [ ] Admin authentication
* [ ] Meal management
* [ ] Ingredient management
* [ ] Meal image management
* [ ] Recommendation monitoring

---

# 📌 Project Status

> **Current milestone: Week 4 In Progress 🚧**

TipidMeal now has a working core application flow consisting of:

```text
Authentication
      ↓
Profile
      ↓
Home
      ↓
Meals
      ↓
Meal Planner
      ↓
Pantry
      ↓
Deterministic Recommendations
      ↓
Meal Details
```

Completed so far in Week 4:

* ✅ Meal Planner (backend + Flutter, full CRUD)
* ✅ Weekly calendar UI with day-tab navigation
* ✅ Meal-slot grouping (breakfast/lunch/dinner)
* ✅ Optimistic delete with rollback
* ✅ Consistent snackbar/dialog UX across Pantry and Meal Planner

### Current Limitations / Remaining Week 4 Work

* 🔲 Settings screen
* 🔲 User-facing dark/light mode preference control
* 🔲 Sign out inside Settings
* 🔲 Favorites / saved meals
* 🔲 Grocery list generator
* 🔲 Food categories
* 🔲 Advanced meal filtering
* 🔲 Full nutrition information
* 🔲 Notifications
* 🔲 AI-assisted recommendations
* 🔲 Admin functionality

These remain the primary targets for the rest of Week 4 and subsequent phases.

---

## 📄 License

This project is currently under development as part of an undergraduate thesis.