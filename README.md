# TipidMeal 🍽️

A budget-friendly meal recommendation app designed to help users discover practical, affordable meals based on their budget, cooking skills, dietary restrictions, ingredient preferences, and available pantry ingredients.

> **Project status:** 🚧 In Development — **Week 6 Complete, Week 7 Nearly Complete (Day 4 outstanding)**

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

Sign out is accessible via **Settings**, reusing this same `AuthController.signOut()` flow — see the Settings section below.

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
* ✅ Physical activity level (Week 7 — see below)
* ✅ Shared `ProfileForm`
* ✅ Profile Setup onboarding
* ✅ Profile viewing/editing
* ✅ Discard-changes confirmation
* ✅ Profile-status routing after login/register
* ✅ Profile-status routing from splash
* ✅ Settings entry point (AppBar action)

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

### Physical Activity Level (Week 7)

Groundwork for Week 8's Nutrition feature (PDRI-based caloric bracket calculation) — **not currently used anywhere in recommendation scoring or displayed on Home/recommendation cards.**

* ✅ `ProfileOptions.physicalActivityLevels` — `sedentary`, `moderately_active`, `active`, matching the backend enum exactly
* ✅ `ProfileOptions.activityLabel()` / `activityHint()` — human-readable display labels and short explanatory hints per level
* ✅ `ProfileFormData.physicalActivityLevel` — required field, non-nullable
* ✅ `ProfileForm` — choice-chip selector, shared between Setup and Edit, with a hint line under the selected chip
* ✅ `_submit()` validation — blocks submission with a snackbar if no activity level is selected
* ✅ `ProfileCreateRequest.physicalActivityLevel` — required, always sent (matches the backend's `ProfileCreate` requiring it)
* ✅ `ProfileUpdateRequest.physicalActivityLevel` — optional, only sent if changed (matches `ProfileUpdate`)
* ✅ `ProfileModel.physicalActivityLevel` — parsed from `GET /profiles/me`, surfaced on the read-only Profile view via `ProfileOptions.activityLabel()`

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
* ✅ Navigation to Favorites (AppBar action)
* ✅ Quick Actions (Meal Planner, Grocery List)

The Home screen provides a summary of the user's current meal-planning information.

```text
Home
 ├── Greeting
 ├── Daily Budget
 ├── Pantry Summary
 ├── Quick Actions (Planner, Grocery List)
 ├── Top Recommendations
 └── Quick Navigation (incl. Favorites)
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
* ✅ Unit auto-detection from meal data (single-unit ingredients auto-select; multi-unit ingredients narrow the picker to only their known units)
* ✅ Backend-driven unit list (`GET /meals/units`) — no hardcoded unit set on the client
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

### Ingredient/unit matching

Pantry and recipe ingredients are matched by an exact `(ingredient, unit)` key across Pantry, Recommendations, and Grocery List. Free-text unit entry previously allowed mismatched spellings (e.g. `"pcs"` vs `"cloves"`) to silently break matching — a pantry item could exist without ever being recognized as satisfying a recipe's requirement. This has been addressed by constraining unit selection to a backend-sourced canonical list, with automatic single-unit detection based on how each ingredient is actually used across seeded meals.

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
* ✅ Favorite button on meal cards and meal detail screen

Current seeded meals (20 total, confirmed Week 7):

* Sinigang na Baboy, Tortang Talong, Ginisang Ampalaya, Pinakbet, Bicol Express, Ukoy, Vegetable Lumpia, Chicken Adobo, Chop Suey, Beef Tapa, Beef Caldereta, Ginisang Sardinas, Chicken Tinola, Garlic Fried Rice, Pancit Bihon, Corned Beef Guisado, Pork Menudo, Ginataang Gulay, Ginisang Munggo, Filipino Chicken Curry

> ⚠️ **Known gap (Week 7, Day 4 — not yet done):** `servings` and the associated ingredient quantities/cost/calories for these seeded meals are still **sample data**, not yet normalized to represent exactly 1 serving. The Meal Detail screen currently shows whatever `servings` value the seed data has, not a guaranteed "1 serving."

Meal navigation supports nested meal-detail routes (within the Meals tab) and a standalone meal-detail route (from Favorites and other non-shell entry points):

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
  ├── Instructions
  └── Favorite toggle
```

---

# ⭐ Recommendations — ✅ Complete (Week 6), Extended (Week 7)

The deterministic recommendation system is now implemented end-to-end.

The recommendation system does **not** depend on an AI API.

Instead, recommendations are calculated using explicit business rules and scoring.

The system considers:

* ✅ Ingredient availability
* ✅ Ingredient substitutions
* ✅ Ingredient quantities
* ✅ Optional ingredients
* ✅ Budget compatibility (now a hard affordability filter as of Week 7 — see below)
* ✅ Cooking skill
* ✅ Food allergies
* ✅ Disliked ingredients
* ✅ Meal coverage
* ✅ Hybrid recommendation score
* ✅ Server-side ranking + client-side re-sort (Week 7)

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
Affordability Filter (hard, Week 7)
        ↓
Ingredient Availability
        ↓
Meal Adaptation
        ↓
Allergy Filtering (hard)
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
Ranked Recommendations (score or cost)
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

**Week 7 change:** any meal whose `estimated_cost` exceeds the user's `daily_budget` is now excluded entirely, before scoring runs, rather than only being scored down by the 30%-weighted Budget Compatibility factor. The 30% weight still applies among the meals that pass this filter.

Meals containing allergies are excluded (unchanged, hard filter).

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

**Week 7 change:** fallback meals are **no longer excluded** from the API response. They're still returned by the backend, just tiered after `adapt` meals in the default sort order. `MealAdaptationModel.decision` is now actively used by `RecommendationController._sorted()` for client-side tiering, not just carried defensively.

### Cost-Based Sort (Week 7)

A floating sort toggle ("Best Match" / "Lowest Cost") sits pinned to the bottom of the Recommendations screen.

* ✅ `RecommendationsRemoteDatasource.getRecommendations({sortBy})` — passes `sort_by` as a query param to the backend
* ✅ **Client-side re-sort architecture:** rather than re-fetching from the network on every toggle tap, `RecommendationController` fetches the full recommendation list once (default order from the backend), then re-sorts it in memory via `setSortBy()`. This makes toggling instant with no loading state and eliminates any stale-response race between fast repeated taps.
* ✅ The client-side sort logic in `_sorted()` exactly mirrors the backend's own `sort_by=score` / `sort_by=cost` ordering rules (fallback tiering + hybrid score tiebreak for score; cost ascending + hybrid score tiebreak for cost), so the two stay consistent even though the client isn't literally re-querying the server per toggle.
* ✅ `RecommendationRepository` / `RecommendationRepositoryImpl` both updated to accept and forward `sortBy`.

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

# 📅 Meal Planner — ✅ Complete (Week 6), Fixed (Week 7)

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
* ✅ Past-date/slot rejection on create and update (Week 7)

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
* ✅ Grocery List entry point (AppBar action, scoped to the currently-viewed week)
* ✅ Date picker disables past dates; slot chips disable past slots for today (Week 7)
* ✅ 400 error from the past-slot guard surfaces as a clear snackbar via `BadRequestException`, not a generic error (Week 7)

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

# 🛒 Grocery List — ✅ Complete

The Grocery List feature generates a shopping list from the user's planned meals for a given date range, offset against what's already in their pantry.

The grocery list is **fully derived** — there is no dedicated database table for it. It is computed on request from `meal_plan_entries` and `pantry_items`.

Implemented:

**Backend**

* ✅ `GroceryListResponse` / `GroceryListItem` schemas
* ✅ Aggregation of required ingredients across all planned meals in a date range
* ✅ Aggregation of current pantry quantities
* ✅ Per-`(ingredient, unit)` subtraction — ingredients where the pantry already covers the requirement are excluded entirely
* ✅ Router (`/grocery-list`) with default current-week (Monday–Sunday) date range when no dates are supplied
* ✅ Explicit `start_date`/`end_date` query parameter support
* ✅ `start_date > end_date` validation
* ✅ Profile-ownership enforcement

**Flutter**

* ✅ `GroceryListItemModel` / `GroceryListResponseModel`
* ✅ Remote datasource (`GroceryListRemoteDatasource`)
* ✅ Repository (`GroceryListRepository`)
* ✅ Riverpod `GroceryListController`
* ✅ Grocery List screen with per-item required/pantry/to-buy quantities
* ✅ Checkbox-based checklist UI
* ✅ Persistent checklist state via `SharedPreferences`, keyed per week
* ✅ Automatic stale-checklist cleanup on app launch (weeks older than a configurable threshold, default 8 weeks)
* ✅ Launched from Meal Planner (AppBar action) and Home (Quick Actions)
* ✅ Loading, error, and empty states
* ✅ Pull-to-refresh

```text
Flutter
   ↓
GroceryListScreen
   ↓
GroceryListController
   ↓
GroceryListRepository
   ↓
GroceryListRemoteDatasource
   ↓
FastAPI (/grocery-list)
   ↓
PostgreSQL (meal_plan_entries + pantry_items)
```

### Known limitations

* Checklist state is local-only (`SharedPreferences`) and does not sync across devices.
* Grocery list matching uses the same exact `(ingredient, unit)` matching as Recommendations — see Pantry's "Ingredient/unit matching" section above.
* Quantities shown reflect current (not-yet-normalized) seed data servings — see the Week 7 servings gap noted under Meals above.

---

# ⭐ Favorites — ✅ Complete

The Favorites feature allows users to bookmark meals from the meal database for quick access, independent of whether the meal is scheduled anywhere in their Meal Planner.

Implemented:

**Backend**

* ✅ `Favorite` model with unique `(profile_id, meal_id)` constraint
* ✅ `meal` relationship (`lazy="joined"`) for eager-loaded meal summaries in responses
* ✅ Cascading deletion on both `profile_id` and `meal_id` (a favorite is a bookmark, not a scheduling record)
* ✅ Alembic migration for `favorites`
* ✅ Pydantic schemas (`FavoriteCreate`, `FavoriteResponse`, `FavoriteMealSummary`)
* ✅ Repository layer (create, get by profile+meal, list by profile, delete)
* ✅ Service layer with idempotent add and idempotent remove
* ✅ Router (`/favorites`) — add, list, remove (keyed by `meal_id`)
* ✅ Profile-ownership enforcement

**Flutter**

* ✅ `Favorite` entity / `FavoriteModel` / `FavoriteMealSummaryModel`
* ✅ Remote datasource (`FavoritesRemoteDatasource`)
* ✅ Repository (`FavoritesRepository`)
* ✅ Riverpod `FavoritesController`
* ✅ Optimistic add (instant UI update using known meal fields, confirmed/rolled back against the server response)
* ✅ Optimistic remove (instant UI update, rollback on failure)
* ✅ `FavoriteButton` widget — heart icon reflecting live favorite state
* ✅ Favorite button on `MealCard` (thumbnail overlay)
* ✅ Favorite button on `MealDetailScreen` (AppBar action)
* ✅ Favorites screen — list of favorited meals with empty state
* ✅ Standalone meal-detail route (`/meal-detail/:id`) for navigating from outside the bottom-nav shell
* ✅ Entry point from Home (AppBar action)

```text
Flutter
   ↓
FavoriteButton / FavoritesScreen
   ↓
FavoritesController
   ↓
FavoritesRepository
   ↓
FavoritesRemoteDatasource
   ↓
FastAPI (/favorites)
   ↓
PostgreSQL
```

### Notable fix: shell-nested route navigation

Tapping a favorited meal originally reused the shell-nested `/meals/:id` path (the same route used when browsing from the Meals tab). Pushing that path from a screen living *outside* `StatefulShellRoute` (Favorites, and potentially other future entry points) caused a `go_router` navigator key collision (`'!keyReservation.contains(key)'` assertion failure), since the shell's branch navigator and the root navigator both attempted to reserve the same route key.

This was resolved by adding a second, standalone route (`/meal-detail/:id`) pointing at the same `MealDetailScreen` widget. Browsing from the Meals tab continues to use the original nested path; any entry point outside the shell (Favorites today, potentially deep links or search later) uses the standalone path instead.

---

# ⚙️ Settings — ✅ Complete

The Settings screen exposes the light/dark/system theme preference that already existed at the `ThemeData` level, and relocates sign-out into a dedicated account section.

Implemented:

* ✅ `ThemeModeController` (Riverpod) — owns the active `ThemeMode`
* ✅ `ThemePreferencesService` — persists the selected mode via `SharedPreferences`
* ✅ Theme preference restored on app launch
* ✅ Light / Dark / System segmented toggle, applied instantly app-wide
* ✅ Settings screen (Appearance section + Account section)
* ✅ Edit Profile link (routes to existing Profile screen)
* ✅ Sign Out with confirmation dialog
* ✅ Sign Out reuses the existing `AuthController.signOut()` — no new sign-out logic, only a new UI location
* ✅ Sign Out routes back to Login afterward
* ✅ Settings entry point (Profile screen AppBar action)

```text
Flutter
   ↓
SettingsScreen
   ↓
┌─────────────────────┬─────────────────────┐
↓                      ↓
ThemeModeController    AuthController.signOut()
   ↓                      ↓
SharedPreferences      Supabase Auth
   ↓                      ↓
App-wide theme         Login
```

No new backend endpoints were required — this feature is UI-only, per the original scope (theming already existed at the `ThemeData` level; sign-out already existed in Authentication).

---

# 🛠️ Week 7 — Fixes First (Nearly Complete)

Week 7 focuses on fixes to existing features before Nutrition (Week 8): Meal Planner past-date/slot blocking, consistent peso formatting, cost-based recommendation sorting, cooking-skill scoring verification, meal-servings normalization, and — as the one genuinely new addition — a physical activity level field on Profile.

### Day 1 — Meal Planner: Past-Slot Guard ✅

* ✅ Backend guard on create + update — `400` with a clear message when a date/slot has already passed
* ✅ Cutoff constants centralized (`core/constants.py` backend; `core/constants/meal_planner_constants.dart` client)
* ✅ Date picker's `firstDate` clamped to today
* ✅ Past slot chips disabled/grayed for the currently selected day; auto-clears an already-selected slot if the picked date moves it into the past
* ✅ New `BadRequestException` (400) added to `ApiException` — previously any non-401/404/422 error fell through to a generic "Something went wrong" `ServerException`, hiding the backend's actual guard message
* ✅ `tzdata` added as a backend dependency (Windows' `zoneinfo` has no built-in tz database)

### Day 2 — Peso Formatting Sweep ✅

* ✅ Single `formatPeso()` utility (`core/utils/currency_utils.dart`) — zero/null always renders `₱0.00`, never blank or a bare `0`
* ✅ Swept: Profile (view + edit), Home budget summary, Meal cards, Meal detail, Recommendation cards, Meal Planner entries, Favorites, meal picker in Add/Edit Meal Plan Entry
* ✅ Removed the old per-model `displayCost` getter on `MealModel` in favor of the single shared formatter
* ✅ Backend: `estimated_cost_total` quantized to 2 decimal places server-side

### Day 3 — Recommendations Cost Sort + Cooking Skill Verification ✅

* ✅ Backend: `sort_by` query param (`score` default, `cost`) on `GET /api/v1/recommendations`
* ✅ Backend: affordability hard filter added — meals over the user's daily budget are now excluded from the response entirely (a stricter behavior than originally scoped; Budget Compatibility's 30% weight now only differentiates among affordable meals)
* ✅ Backend: fallback meals no longer excluded server-side — now returned, tiered after `adapt` meals under the default sort
* ✅ Flutter: floating "Best Match" / "Lowest Cost" sort toggle on the Recommendations screen
* ✅ Flutter: client-side re-sort architecture — recommendations fetched once, re-sorted in memory on toggle for instant, race-free switching
* ✅ Cooking skill scoring manually verified against all 20 seeded meals (Swagger + in-app), confirming smooth degradation, proportionate score gaps, and no penalty for Advanced users on any difficulty
* ✅ Confirmed all 20 seeded `Meal.difficulty` values are exactly `easy` / `medium` / `hard`, so none silently fall outside the skill-scoring compatibility table
* 🔲 No automated unit tests were written for `scoring.py` — verification was manual only

### Day 5 — Profile: Physical Activity Level ✅

* ✅ Backend: `physical_activity_level` column + enum (`sedentary`, `moderately_active`, `active`) on `Profile`
* ✅ Backend: Alembic migration (`aa4a5f458607`)
* ✅ Backend: required on `ProfileCreate`, optional on `ProfileUpdate`/`ProfileResponse` — a deliberate decision, not the originally-scoped "nullable until filled later"
* ✅ Flutter: `ProfileOptions` activity level list + display labels + hints
* ✅ Flutter: activity selector added to the shared `ProfileForm` (both Setup and Edit)
* ✅ Flutter: surfaced on the read-only Profile view
* ✅ Flutter: `ProfileCreateRequest` sends it as required; `ProfileUpdateRequest` sends it only if changed
* ⚪ Not yet used in recommendation scoring — this is intentional groundwork for Week 8's Nutrition feature, not a Week 7 recommendation change

### Remaining

* 🔲 Day 4 — Meal servings normalization (1-serving baseline across all 20 seeded meals — current data is still sample/unverified servings, ingredient quantities, cost, and calories)

---

# 🧭 Navigation — ✅ Complete

The application uses a bottom navigation shell containing:

```text
Home
Meals
Planner
Recommendations
Pantry
```

Profile and Settings remain accessible separately, off the shell.

Meal details use nested routing (within the Meals tab):

```text
/meals/:id
```

A standalone meal-detail route exists for entry points outside the shell (Favorites, etc.):

```text
/meal-detail/:id
```

Meal planner add/edit uses nested routing:

```text
/meal-planner/add
```

Grocery List, Favorites, and Settings are standalone pushed routes, launched from Meal Planner, Home, or Profile rather than bottom-nav tabs:

```text
/grocery-list
/favorites
/settings
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
 ↓         ↓                    ↓                  ↓
Details  Grocery List      Meal Details         Settings

Home ──→ Favorites ──→ Meal Details (standalone route)
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
* Grocery List
* Favorites

Note: `GET /meals/units` and `GET /meals/ingredients/suggestions` are intentionally **unauthenticated**, since they expose no user-specific data — just the set of units/ingredients used across the shared meal database.

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

The Recommendations feature is a partial exception as of Week 7: `RecommendationController` also owns in-memory sort state (`_rawRecommendations`, `_sortBy`) and re-sorts client-side on toggle, rather than every state change mapping 1:1 to a fresh network round-trip. This is a deliberate UX optimization (instant, race-free sort toggling), not a layering violation — the controller still goes through `RecommendationRepository` → `RecommendationsRemoteDatasource` → FastAPI for the actual fetch.

Settings is a partial exception to this layering — it has no `data/` or `domain/` layer of its own, since it doesn't call any dedicated backend endpoint. It composes `ThemeModeController` (in `core/`, since theme is an app-wide concern rather than feature-specific) with the existing `AuthController`.

---

# 📁 Project Structure

```text
lib/
├── app/
│   ├── app.dart
│   ├── colors.dart
│   ├── routes.dart
│   ├── router.dart
│   └── theme.dart
│
├── core/
│   ├── constants/
│   │   ├── profile_options.dart
│   │   └── meal_planner_constants.dart
│   ├── errors/
│   │   └── api_exception.dart
│   ├── extensions/
│   │   └── context_extension.dart
│   ├── networks/
│   ├── providers/
│   │   └── theme_mode_provider.dart
│   ├── services/
│   │   └── theme_preferences_service.dart
│   ├── utils/
│   │   ├── date_utils.dart
│   │   └── currency_utils.dart
│   └── widgets/
│       └── confirm_dialog.dart
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
│   ├── recommendations/
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
│   ├── grocery_list/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   ├── repositories/
│   │   │   ├── grocery_list_dependencies.dart
│   │   │   └── grocery_checklist_storage.dart
│   │   ├── domain/
│   │   │   └── repositories/
│   │   └── presentation/
│   │       ├── providers/
│   │       ├── screens/
│   │       └── widgets/
│   │
│   ├── favorites/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── favorites_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── favorite_model.dart
│   │   │   ├── repositories/
│   │   │   │   └── favorites_repository_impl.dart
│   │   │   └── favorites_dependencies.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── favorite.dart
│   │   │   └── repositories/
│   │   │       └── favorites_repository.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── favorites_provider.dart
│   │       ├── screens/
│   │       │   └── favorites_screen.dart
│   │       └── widgets/
│   │           ├── favorite_button.dart
│   │           └── favorite_meal_card.dart
│   │
│   └── settings/
│       └── presentation/
│           └── screens/
│               └── settings_screen.dart
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
* ✅ System theme (follows device setting)
* ✅ User-selectable theme preference, persisted across restarts
* ✅ Poppins typography
* ✅ Food-inspired visual identity
* ✅ Burnt-orange primary accents
* ✅ Rounded Material cards
* ✅ Consistent input styling
* ✅ Cached network images
* ✅ Loading states
* ✅ Error states
* ✅ Empty states
* ✅ Snackbar feedback (with FAB-aware bottom margin on screens with a floating action button)
* ✅ Shared confirmation dialog widget for destructive actions
* ✅ Consistent ₱0.00-style peso formatting across every money display (Week 7)
* ✅ Floating pill-style sort toggle on Recommendations (Week 7)

### Brand Colors

The primary visual identity uses warm food-inspired colors:

* Orange
* Burnt Orange
* Cream
* Olive Green
* Green

The authentication, profile, pantry, meals, meal planner, recommendations, grocery list, favorites, settings, and home screens have been styled to maintain a consistent visual language.

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
├── Recommendations
│
├── Grocery List
│
└── Favorites
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

Settings does not call any dedicated backend endpoint — the theme preference lives entirely client-side (`SharedPreferences`), and sign-out reuses the existing Supabase Auth flow already used by Authentication.

---

# 📊 Week 6 Application Flow

```text
Login
  ↓
Profile Check
  ↓
Home
  ↓
┌───────────────┬────────────┬─────────┬────────────────┐
│               │            │         │                │
↓               ↓            ↓         ↓                ↓
Meals        Planner       Pantry  Recommendations   Favorites
│               │            │
↓               ↓            ↓
Meal Details  Add/Edit    Available Ingredients
   ↑           Entry              │
   │              ↓                ↓
   │         Grocery List   Recommendations
   │                                │
   └────────────────────────────────┘
                                     ↓
                              Meal Details
                                     ↑
                              (Favorites tap-through,
                               standalone route)

Profile ──→ Settings ──→ Sign Out ──→ Login
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

Grocery List is derived using:

```text
Meal Planner (date range)
+
Pantry
      ↓
Required − Available
      ↓
Grocery List
```

Favorites is independent of the planning pipeline — a meal can be favorited without ever being scheduled:

```text
Meal Card / Meal Details
      ↓
Favorite Toggle
      ↓
Favorites Screen
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
* ✅ Meal planner past-date/slot guard (backend 400 + client-side disabled dates/slots)
* ✅ Ingredient-unit auto-detection (single-unit case)
* ✅ Grocery list empty state (no meals planned)
* ✅ Grocery list checklist persistence across screen re-entry
* ✅ Grocery list checklist isolation across different weeks
* ✅ Dialog scroll/overflow fix (unit chip list in AddPantryItemDialog)
* ✅ Home empty-recommendations layout overflow fix
* ✅ Favorites: add idempotency (favoriting an already-favorited meal doesn't error)
* ✅ Favorites: remove idempotency (un-favoriting an already-removed meal doesn't error)
* ✅ Favorites: optimistic add/remove with rollback on API failure
* ✅ Favorites: state consistency across meal cards, meal detail, and the Favorites screen
* ✅ Favorites: navigation-key collision fix (standalone `/meal-detail/:id` route)
* ✅ Settings: theme toggle applies instantly app-wide
* ✅ Settings: theme preference persists across app restart
* ✅ Settings: sign out clears session and routes to Login
* ✅ Recommendations: "Best Match" / "Lowest Cost" sort toggle (Week 7)
* ✅ Recommendations: affordability filter — meals over the daily budget are excluded (Week 7)
* ✅ Consistent peso formatting across all money displays (Week 7)
* ✅ Profile Setup and Edit both require a physical activity level (Week 7)

### Not yet verified

* 🔲 Ingredient-unit auto-detection for the ambiguous case (an ingredient used with 2+ different units across meals) — not yet exercised against real seed data
* 🔲 Grocery list correctness against a fully populated week (multiple meals/slots, overlapping ingredients)
* 🔲 Favorites behavior when the underlying meal is deleted from the catalog (cascade is implemented backend-side but not exercised end-to-end from the app)
* 🔲 Automated unit tests for `scoring.py` — cooking-skill scoring was verified manually only (Swagger + in-app)
* 🔲 Meal servings, ingredient quantities, cost, and calories normalized to a 1-serving baseline (Week 7, Day 4)

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

The `shared_preferences` package is required for both the theme-preference (Settings) and grocery-checklist persistence features. Confirm it is listed in `pubspec.yaml`.

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

## Phase 7 — Grocery List ✅

* [x] `GroceryListItem` / `GroceryListResponse` schemas
* [x] Required-ingredient aggregation across a date range
* [x] Pantry-quantity aggregation
* [x] Required-minus-available calculation, per `(ingredient, unit)`
* [x] Router (`/grocery-list`) with default-week logic
* [x] `start_date`/`end_date` validation
* [x] Flutter model, datasource, repository
* [x] Riverpod `GroceryListController`
* [x] Grocery List screen with checklist UI
* [x] `SharedPreferences`-backed checklist persistence, keyed per week
* [x] Stale-checklist cleanup on app launch
* [x] Entry points from Meal Planner and Home

## Phase 8 — Ingredient/Unit Matching ✅

* [x] Identified exact-string `(ingredient, unit)` matching as a shared fragility across Recommendations, Pantry, and Grocery List
* [x] `GET /meals/units` endpoint — backend-sourced canonical unit list
* [x] `GET /meals/ingredients/suggestions` extended to return per-ingredient known units, not just names
* [x] Pantry dialog: unit selection constrained to `ChoiceChip`s instead of free text
* [x] Single-unit ingredients auto-select their unit on suggestion pick
* [x] Multi-unit ingredients narrow the picker to only their known units
* [x] Fallback to full unit list for unmatched/new ingredients

## Phase 9 — Favorites & Settings ✅

* [x] `Favorite` backend model with unique `(profile_id, meal_id)` constraint
* [x] Cascading deletion on both `profile_id` and `meal_id`
* [x] Idempotent add/remove service logic
* [x] Router (`/favorites`) — add, list, remove
* [x] Alembic migration for `favorites`
* [x] Flutter entity/model, datasource, repository
* [x] Riverpod `FavoritesController` with optimistic add/remove
* [x] `FavoriteButton` widget (meal cards + meal detail)
* [x] Favorites screen with empty state
* [x] Standalone meal-detail route (shell-navigation key-collision fix)
* [x] `ThemeModeController` + `SharedPreferences`-backed persistence
* [x] Light/Dark/System theme toggle, applied instantly
* [x] Settings screen (Appearance + Account sections)
* [x] Edit Profile link
* [x] Sign Out with confirmation dialog, relocated into Settings
* [x] Settings and Favorites entry points wired into Profile/Home

## Phase 10 — Week 7 Fixes 🚧 (Day 4 outstanding)

* [x] Meal Planner past-date/slot guard (backend `400` + client-side disabled dates/slots)
* [x] Centralized meal-planner cutoff constants (backend + client)
* [x] `BadRequestException` so the backend's guard message reaches the UI
* [x] Single shared `formatPeso()` utility, swept across every money display
* [x] `sort_by` (`score` / `cost`) on `GET /api/v1/recommendations`
* [x] Affordability hard filter (meals over the daily budget excluded)
* [x] Fallback meals returned by the backend, tiered after `adapt` meals
* [x] Floating "Best Match" / "Lowest Cost" sort toggle
* [x] Client-side re-sort architecture in `RecommendationController`
* [x] Cooking skill scoring manually verified against all 20 seeded meals
* [x] `physical_activity_level` on Profile — backend enum + migration, required on create
* [x] Physical activity level in Flutter (`ProfileOptions`, shared `ProfileForm`, create/update requests, Profile view)
* [ ] Meal servings normalization — 1-serving baseline across all 20 seeded meals (ingredient quantities, cost, calories)

---

# 🚧 Future / Not Yet Implemented Features

The following features are **not yet implemented**.

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

### 🥗 Nutrition Information — 🔲 Not Yet Implemented (Planned: Week 8)

* [ ] PDRI-based caloric bracket calculation (builds on the physical activity level field added to Profile in Week 7)
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

### 🔄 Grocery Checklist Cloud Sync — 🔲 Not Yet Implemented

* [ ] Persist checklist state server-side instead of `SharedPreferences`
* [ ] Sync checklist across multiple devices

### 📏 Multi-Unit Ingredient Auto-Detection — 🔲 Not Yet Verified

* [ ] Exercise the ambiguous case (an ingredient used with 2+ different units across meals) against real seed data

---

# 📌 Project Status

> **Current milestone: Week 6 Complete 🎉 — Week 7 Nearly Complete (Day 4 outstanding)**

TipidMeal now has a working core application flow consisting of:

```text
Authentication
      ↓
Profile ──→ Settings
      ↓
Home ──→ Favorites
      ↓
Meals
      ↓
Meal Planner
      ↓
Grocery List
      ↓
Pantry
      ↓
Deterministic Recommendations
      ↓
Meal Details
```

Completed in Week 7:

* ✅ Meal Planner past-date/slot guard (backend + client)
* ✅ `BadRequestException` — backend guard messages now surface clearly in the UI
* ✅ Consistent `₱0.00`-style peso formatting via a single shared formatter
* ✅ Cost-based recommendation sorting (`sort_by=cost`) with a floating "Best Match" / "Lowest Cost" toggle
* ✅ Client-side re-sort for instant, race-free toggling
* ✅ Affordability hard filter — meals over the daily budget are excluded
* ✅ Fallback meals now returned by the backend and tiered after `adapt` meals
* ✅ Cooking skill scoring manually verified against all 20 seeded meals
* ✅ Physical activity level on Profile (required at setup, editable later) — groundwork for Week 8's Nutrition feature

Completed in Week 6:

* ✅ Favorites (backend + Flutter, full add/list/remove loop)
* ✅ Idempotent favorite add/remove
* ✅ Optimistic UI for favorite toggling, with rollback
* ✅ Favorite button on meal cards and meal detail screen
* ✅ Dedicated Favorites screen
* ✅ Standalone meal-detail route (fixed `go_router` navigator key collision when navigating from outside the bottom-nav shell)
* ✅ Settings screen (Appearance + Account)
* ✅ Light/Dark/System theme toggle, persisted via `SharedPreferences`
* ✅ Sign Out relocated into Settings, with confirmation dialog
* ✅ Settings and Favorites entry points wired into existing screens

Completed in earlier weeks (carried forward):

* ✅ Meal Planner (backend + Flutter, full CRUD)
* ✅ Grocery List (backend + Flutter, derived from Meal Planner + Pantry)
* ✅ Ingredient/unit matching fix
* ✅ Consistent snackbar/dialog UX across all CRUD-style features

### Current Limitations / Remaining Work

* 🔲 Meal servings normalization to a 1-serving baseline (Week 7, Day 4) — seeded servings, quantities, cost, and calories are still sample data
* 🔲 Automated unit tests for `scoring.py` (cooking-skill scoring verified manually only)
* 🔲 Food categories
* 🔲 Advanced meal filtering
* 🔲 Full nutrition information (planned: Week 8)
* 🔲 Notifications
* 🔲 AI-assisted recommendations
* 🔲 Admin functionality
* 🔲 Multi-unit ingredient auto-detection — not yet exercised against real ambiguous data
* 🔲 Grocery checklist cloud sync (currently local-only via `SharedPreferences`)
* 🔲 Favorites behavior on meal deletion — not yet exercised end-to-end from the app

These remain the primary targets for subsequent phases.

---

## 📄 License

This project is currently under development as part of an undergraduate thesis.