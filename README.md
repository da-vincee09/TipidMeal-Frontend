# TipidMeal 🍽️

A budget-friendly meal recommendation app designed to help users discover practical, affordable meals based on their budget, cooking skills, dietary restrictions, ingredient preferences, and available pantry ingredients — and to see how nutritionally adequate each meal is for them.

> **Project status:** 🚧 In Development — **Week 6 Complete, Week 7 Nearly Complete (Day 4 outstanding), Week 8 (Nutrition) Built — results pending final data verification**

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
* ✅ Password strength enforcement (see below)

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

### Password Security

Registration now enforces a defined password strength policy client-side, with a live visual checklist rather than a single pass/fail error shown only after submit.

* ✅ `PasswordValidator` (`core/utils/password_validator.dart`) — single source of truth for the rule set:
  * At least 8 characters
  * At least one uppercase letter
  * At least one lowercase letter
  * At least one number
  * At least one symbol (from the set Supabase accepts: `` !@#$%^&*()_+-=[]{};'\:"|<>?,./`~ ``)
* ✅ `PasswordRule` — pairs a human-readable label with its own `isMet(password)` check, so the rule set is data-driven rather than a hardcoded if/else chain
* ✅ `PasswordValidator.isValid()` / `unmetLabels()` — used both for the live checklist and for the final submit-time check
* ✅ `PasswordRequirements` (`core/widgets/password_requirements.dart`) — live checklist widget shown under the password field on Register:
  * Each rule renders as a pill that turns olive with a check as it's satisfied
  * Once every rule is met, the checklist holds briefly (so the last tick is visible), then fades out and collapses
  * Reappears automatically if the password becomes invalid again (e.g. user backspaces)
  * Visible while the password field is focused or has text; hidden otherwise
* ✅ `RegisterScreen` — blocks submission with a snackbar listing unmet rules (`PasswordValidator.unmetLabels()`) if the password doesn't satisfy every rule, and separately checks the confirm-password field matches
* ✅ **Password reset** is handled by Supabase's own hosted reset-link flow (the app only triggers sending the email); the same password requirements are configured directly in the Supabase Auth dashboard, so a password rejected by the client-side checklist on Register is never silently accepted through the reset-password link, and vice versa

```text
Password field (Register)
      ↓
PasswordValidator.rules
      ↓
Live checklist (PasswordRequirements)
      ↓
Submit → PasswordValidator.unmetLabels()
      ↓
 ┌─────────────┬──────────────────┐
 │ All met     │ Some unmet       │
 ↓             ↓                  │
Proceed    Snackbar listing       │
           unmet rules            │
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
* ✅ Budget per meal (renamed from Daily Budget — see below)
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

### Budget Per Meal (renamed from Daily Budget)

The backend renamed `daily_budget` → `budget_per_meal` (a plain column rename, no behavior change — the value was always compared against a single meal's cost, so the old name was misleading). The Flutter side has been updated to match end-to-end:

* ✅ `ProfileModel.budgetPerMeal` — parses `budget_per_meal` from `GET /profiles/me`
* ✅ `ProfileCreateRequest.budgetPerMeal` / `ProfileUpdateRequest.budgetPerMeal` — both send `budget_per_meal` as the JSON key
* ✅ `ProfileForm` — field label reads "Budget Per Meal", validation message reads "Please enter a valid budget per meal"
* ✅ Read-only Profile view — row label reads "Budget Per Meal"
* ✅ Home screen summary card — label reads "Budget Per Meal"
* ✅ `formatPeso()` used consistently wherever the value is displayed

No `dailyBudget` field name remains anywhere in the Flutter codebase — the rename is complete on both client and server, so their JSON keys agree.

### Physical Activity Level (Week 7)

Added in Week 7 as groundwork for the Nutrition feature. As of Week 8 the backend uses it, together with date of birth and sex, to determine each user's daily caloric requirement, which drives the nutrition results shown in Meal Detail and on recommendation cards. It is **not** used in recommendation scoring.

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
* ✅ Budget per meal display
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
 ├── Budget Per Meal
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
* ✅ Nutrition section on Meal Detail (Week 8 — see Nutrition below)
* ✅ Cached network images
* ✅ Graceful handling of meals without images
* ✅ Seeded meal database
* ✅ Favorite button on meal cards and meal detail screen

Current seeded meals (20 total, confirmed Week 7):

* Sinigang na Baboy, Tortang Talong, Ginisang Ampalaya, Pinakbet, Bicol Express, Ukoy, Vegetable Lumpia, Chicken Adobo, Chop Suey, Beef Tapa, Beef Caldereta, Ginisang Sardinas, Chicken Tinola, Garlic Fried Rice, Pancit Bihon, Corned Beef Guisado, Pork Menudo, Ginataang Gulay, Ginisang Munggo, Filipino Chicken Curry

> ⚠️ **Known gap (Week 7, Day 4 — not yet done):** `servings` and the associated ingredient quantities/cost/calories for these seeded meals are still **sample data**, not yet normalized to represent exactly 1 serving. The Meal Detail screen currently shows whatever `servings` value the seed data has, not a guaranteed "1 serving." The Nutrition caloric check compares each meal's `calories` to a per-serving bracket, so nutrition results should be treated as provisional until this is done.

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
  ├── Nutrition (Week 8)
  ├── Ingredients
  ├── Instructions
  └── Favorite toggle
```

---

# ⭐ Recommendations — ✅ Complete (Week 6), Extended (Week 7), Nutrition Badge (Week 8)

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

**Week 7 change:** any meal whose `estimated_cost` exceeds the user's `budget_per_meal` is now excluded entirely, before scoring runs, rather than only being scored down by the 30%-weighted Budget Compatibility factor. The 30% weight still applies among the meals that pass this filter.

Meals containing allergies are excluded (unchanged, hard filter).

Available substitutes and optional ingredients can allow a meal to remain recommendable.

**Week 8:** nutritional adequacy is shown alongside each recommendation but is **informational** — it does not change the hybrid score weights or the ranking.

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
* Nutrition badge (Week 8)

Pantry changes automatically trigger a recommendation refresh.

This is important because the Flutter application uses a persistent `StatefulShellRoute`, meaning screens can remain alive while the user switches tabs.

---

# 🥗 Nutrition — ✅ Built (Week 8), Results Pending Final Data Verification

The Nutrition feature tells the user whether a meal is **nutritionally adequate for them**, using Philippine dietary standards. It appears in two places:

* **Meal Detail** — a Nutrition section for the opened meal.
* **Recommendation cards** — a compact nutrition badge.

All nutrition logic runs on the FastAPI backend; the Flutter client only requests and displays the result. The backend combines the user's profile (date of birth, sex, physical activity level) with the meal (calories and ingredients) and applies:

* **Caloric adequacy** — the meal's calories vs. a per-meal bracket derived from PDRI 2015 (FNRI-DOST), scaled for activity level with FAO/WHO/UNU PAL ratios.
* **Food-group adequacy** — the meal's Grow/Glow balance vs. Pinggang Pinoy (FNRI-DOST 2016) bands.

A meal is nutritionally adequate only when **both** checks pass. Seeded meals are single ulam dishes (rice is its own meal), so the backend scales both checks to an ulam rather than a full plate; the methodology and its limitations are documented in the backend README.

Implemented (Flutter):

* ✅ `ApiConstants.mealNutritionAdequacy(id)` → `/meals/$id/nutrition-adequacy`
* ✅ Nutrition section on the Meal Detail screen, showing the server's adequacy result for the signed-in user
* ✅ Nutrition badge on recommendation cards, fed by the extended `/recommendations` response (no extra request per card)
* ✅ Nutrition results follow the user's profile — updating physical activity level, date of birth, or sex changes the verdict

```text
Flutter
   ↓
Meal Detail (Nutrition section)              Recommendation Card (badge)
   ↓                                                ↓
GET /meals/{id}/nutrition-adequacy           GET /recommendations
   ↓                                                ↓
FastAPI Nutrition Service  ←── Profile + Meal ──→  (nutrition result per meal)
   ↓
Caloric adequacy + Food-group adequacy
   ↓
Nutritional adequacy
```

### What the server returns

| Field | Values | Meaning |
|-------|--------|---------|
| `caloric_adequacy` | `within` \| `below` \| `above` \| `unavailable` | Meal calories vs. the user's per-meal bracket |
| `food_group_proportions` | `{go, grow, glow}` \| `null` | Meal's Go/Grow/Glow split by mass (%) |
| `food_group_adequate` | `true` \| `false` \| `null` | Grow/Glow balance verdict |
| `nutritionally_adequate` | `true` \| `false` \| `null` | Both checks pass; `null` if either half is unavailable |
| `is_staple` | `true` \| `false` | Staple meal (e.g. Garlic Fried Rice), not judged as an ulam |

### States the UI must handle

A result can be **unavailable** rather than adequate/inadequate, and the client should never present that as a failure:

* Physical activity level not set, or a sex value with no PDRI row → `caloric_adequacy: unavailable`
* Meal has no calories value, or no classifiable ingredients → `null` verdicts
* Staple meal → `is_staple: true`, no verdict

### Known limitations

* 🔲 **Staple meals:** the backend now returns `is_staple` for Garlic Fried Rice. Showing a dedicated "staple" state in the client (instead of a generic "unavailable"), plus a short note that the Go group is supplied by rice, is not yet implemented.
* Results are provisional until the Week 7 Day 4 servings/calories normalization is done and the evaluation is rerun (see the note under Meals).
* Detailed nutrient metrics (protein, carbohydrates, fat) are not part of this feature — see Future features.

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

# 🛒 Grocery List — ✅ Complete (Pricing Added)

The Grocery List feature generates a shopping list from the user's planned meals for a given date range, offset against what's already in their pantry — and, where price data is available, estimates the cost of buying it.

The grocery list is **fully derived** — there is no dedicated database table for it. It is computed on request from `meal_plan_entries`, `pantry_items`, and (as of this update) `ingredient_prices`.

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
* ✅ Per-item `estimated_cost`, looked up from `ingredient_prices` by exact `(ingredient, unit)` match
* ✅ `total_estimated_cost` — sum of every priced item; `null` if nothing in the list could be priced (never a misleading `₱0.00`)

**Flutter**

* ✅ `GroceryListItemModel` / `GroceryListResponseModel` — including `estimatedCost` per item and `totalEstimatedCost` on the response
* ✅ Remote datasource (`GroceryListRemoteDatasource`)
* ✅ Repository (`GroceryListRepository`)
* ✅ Riverpod `GroceryListController`
* ✅ Grocery List screen with per-item required/pantry/to-buy quantities
* ✅ **Estimated total** shown at the top of the list (`Estimated total: ₱XXX.XX`), only rendered when at least one item has a known price
* ✅ Per-item estimated cost shown on each `GroceryListItemCard`, right-aligned under the quantity-to-buy pill
* ✅ Redesigned `GroceryListItemCard`: circular check indicator (fills orange with a checkmark instead of a stock `Checkbox`), colored left accent stripe (orange active / muted gray checked), whole-card opacity dim when checked, ingredient names auto-formatted from snake_case (e.g. `beef_sirloin` → "Beef Sirloin"), pantry-status line with a contextual icon (cart-with-slash when none on hand, kitchen icon otherwise)
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
PostgreSQL (meal_plan_entries + pantry_items + ingredient_prices)
```

### Known limitations

* Checklist state is local-only (`SharedPreferences`) and does not sync across devices.
* Grocery list matching uses the same exact `(ingredient, unit)` matching as Recommendations — see Pantry's "Ingredient/unit matching" section above.
* Quantities shown reflect current (not-yet-normalized) seed data servings — see the Week 7 servings gap noted under Meals above.
* **Prices are placeholder/estimated data**, not sourced from official price monitoring (e.g. DTI) — see the backend README's pricing seed-data caveat. An ingredient with no price entry for its exact unit shows no cost line and is silently excluded from the total, rather than guessed.

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

Week 7 focuses on fixes to existing features before Nutrition (Week 8): Meal Planner past-date/slot blocking, consistent peso formatting, cost-based recommendation sorting, cooking-skill scoring verification, meal-servings normalization, password strength enforcement, the daily-budget → budget-per-meal rename, and — as the one genuinely new addition — a physical activity level field on Profile.

### Day 1 — Meal Planner: Past-Slot Guard ✅

* ✅ Backend guard on create + update — `400` with a clear message when a date/slot has already passed
* ✅ Cutoff constants centralized (`core/constants.py` backend; `core/constants/meal_planner_constants.dart` client)
* ✅ Date picker's `firstDate` clamped to today
* ✅ Past slot chips disabled/grayed for the currently selected day; auto-clears an already-selected slot if the picked date moves it into the past
* ✅ New `BadRequestException` (400) added to `ApiException` — previously any non-401/404/422 error fell through to a generic "Something went wrong" `ServerException`, hiding the backend's actual guard message
* ✅ `tzdata` added as a backend dependency (Windows' `zoneinfo` has no built-in tz database)

### Day 2 — Peso Formatting Sweep ✅

* ✅ Single `formatPeso()` utility (`core/utils/currency_utils.dart`) — zero/null always renders `₱0.00`, never blank or a bare `0`
* ✅ Swept: Profile (view + edit), Home budget summary, Meal cards, Meal detail, Recommendation cards, Meal Planner entries, Favorites, Grocery List (per-item cost + total), meal picker in Add/Edit Meal Plan Entry
* ✅ Removed the old per-model `displayCost` getter on `MealModel` in favor of the single shared formatter
* ✅ Backend: `estimated_cost_total` quantized to 2 decimal places server-side

### Day 3 — Recommendations Cost Sort + Cooking Skill Verification ✅

* ✅ Backend: `sort_by` query param (`score` default, `cost`) on `GET /api/v1/recommendations`
* ✅ Backend: affordability hard filter added — meals over the user's budget per meal are now excluded from the response entirely (a stricter behavior than originally scoped; Budget Compatibility's 30% weight now only differentiates among affordable meals)
* ✅ Backend: fallback meals no longer excluded server-side — now returned, tiered after `adapt` meals under the default sort
* ✅ Flutter: floating "Best Match" / "Lowest Cost" sort toggle on the Recommendations screen
* ✅ Flutter: client-side re-sort architecture — recommendations fetched once, re-sorted in memory on toggle for instant, race-free switching
* ✅ Cooking skill scoring manually verified against all 20 seeded meals (Swagger + in-app), confirming smooth degradation, proportionate score gaps, and no penalty for Advanced users on any difficulty
* ✅ Confirmed all 20 seeded `Meal.difficulty` values are exactly `easy` / `medium` / `hard`, so none silently fall outside the skill-scoring compatibility table
* 🔲 No automated unit tests were written for `scoring.py` — verification was manual only

### Day 4 — Password Strength + Budget Rename ✅

* ✅ `PasswordValidator` and live `PasswordRequirements` checklist added to Register (see Password Security under Authentication above)
* ✅ Password rules kept in sync with the equivalent policy configured in the Supabase Auth dashboard, so Register (client-validated) and the Supabase-hosted password-reset link (server-validated) never disagree
* ✅ Backend `daily_budget` → `budget_per_meal` rename fully propagated to Flutter: `ProfileModel`, `ProfileCreateRequest`, `ProfileUpdateRequest`, `ProfileForm`, the read-only Profile view, and the Home summary card — no stale `dailyBudget` references remain
* ✅ Grocery List pricing — `estimated_cost` per item and `total_estimated_cost` surfaced in the Flutter models and UI (see Grocery List above)

### Day 5 — Profile: Physical Activity Level ✅

* ✅ Backend: `physical_activity_level` column + enum (`sedentary`, `moderately_active`, `active`) on `Profile`
* ✅ Backend: Alembic migration (`aa4a5f458607`)
* ✅ Backend: required on `ProfileCreate`, optional on `ProfileUpdate`/`ProfileResponse` — a deliberate decision, not the originally-scoped "nullable until filled later"
* ✅ Flutter: `ProfileOptions` activity level list + display labels + hints
* ✅ Flutter: activity selector added to the shared `ProfileForm` (both Setup and Edit)
* ✅ Flutter: surfaced on the read-only Profile view
* ✅ Flutter: `ProfileCreateRequest` sends it as required; `ProfileUpdateRequest` sends it only if changed
* ⚪ Not used in recommendation scoring — it feeds Week 8's Nutrition feature (see below), not the recommendation score

### Remaining

* 🔲 Meal servings normalization (1-serving baseline across all 20 seeded meals — current data is still sample/unverified servings, ingredient quantities, cost, and calories)

---

# 🥗 Week 8 — Nutrition (Built)

Week 8 adds the Nutrition feature: for each meal and user, whether the meal is nutritionally adequate against Philippine dietary standards (PDRI 2015 for energy, Pinggang Pinoy for food groups). It supports the thesis's Objective 4. Most of the work is backend; the Flutter side displays the result.

### Days 1–4 — Backend ✅

* ✅ **Day 1:** PDRI energy table and daily caloric requirement per profile (sex + age bracket, scaled for activity level)
* ✅ **Day 2:** `ingredient_food_groups` reference table (Go / Grow / Glow / other) and seed data
* ✅ **Day 3:** caloric adequacy, food-group proportions, and the combined adequacy result — verified by hand calculation
* ✅ **Day 4:** `GET /api/v1/meals/{meal_id}/nutrition-adequacy`, and the `/recommendations` response extended with each meal's nutrition result

### Day 5 — Flutter ✅

* ✅ `ApiConstants.mealNutritionAdequacy(id)` endpoint constant
* ✅ Nutrition section on the Meal Detail screen
* ✅ Nutrition badge on recommendation cards

### Day 6 — Evaluation harness ✅ (backend)

* ✅ `scripts/evaluate_nutrition_adequacy.py` runs the real adequacy logic over a 30-profile × meal test matrix (5 PDRI age brackets × 2 sexes × 3 activity levels) and reports the accuracy measure for Objective 4, with per-criterion and per-meal breakdowns
* ✅ `scripts/debug_food_group_exclusions.py` lists which ingredients are counted or silently dropped from each meal's food-group proportions
* ⚪ Results are provisional until Week 7 Day 4 (1-serving normalization) is complete and the evaluation is rerun

### Methodology refinements made during Week 8 (backend)

* ✅ **Ulam-only scaling:** seeded meals are single dishes and rice is its own meal, so the per-meal calorie bracket and the Pinggang Pinoy bands are scaled to an ulam rather than a full plate (`ULAM_ENERGY_SHARE`, ulam-only Grow/Glow bands)
* ✅ **Staple handling:** Garlic Fried Rice is reported as a staple (`is_staple`) instead of being judged as an ulam
* ✅ **Food-group data completed:** 21 ingredients that had no classification were added (migration `c2d3e4f5a6b7`) and gram conversions added for piece-counted ingredients (tomato, potato, sweet potato, radish, quail egg), so no ingredient in the seeded meals is silently dropped
* ✅ Details and limitations are documented in the backend README

### Remaining

* 🔲 Flutter display for staple meals (`is_staple`)
* 🔲 Final evaluation rerun after the servings/calories normalization

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

The Nutrition section lives inside Meal Details, so it is reachable from every route that opens a meal.

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
* Nutrition

Note: `GET /meals/units` and `GET /meals/ingredients/suggestions` are intentionally **unauthenticated**, since they expose no user-specific data — just the set of units/ingredients used across the shared meal database. `GET /meals/{id}/nutrition-adequacy` is authenticated, since the result depends on the caller's profile.

User-specific data is always associated with the authenticated user's profile. Password strength is enforced client-side at registration and server-side (via Supabase Auth configuration) for the reset-password link, so account credentials meet the same bar regardless of which path created or changed them.

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

Nutrition has no client-side calculation: the adequacy result is computed entirely by the backend and the client only requests and renders it.

`PasswordValidator` (`core/utils/`) is a similar app-wide utility rather than a feature-scoped one — it's consumed by Authentication's Register screen but doesn't belong to Authentication's `data/`/`domain/` layers, since it has no backend call of its own.

---

# 📁 Project Structure

```text
lib/
├── main.dart
│
├── app/
│   ├── app.dart
│   ├── colors.dart
│   ├── main_shell.dart
│   ├── page_transitions.dart
│   ├── routes.dart
│   ├── router.dart
│   └── theme.dart
│
├── core/
│   ├── constants/
│   │   ├── meal_planner_constants.dart
│   │   └── profile_options.dart
│   ├── errors/
│   │   └── api_exception.dart
│   ├── extensions/
│   │   └── context_extension.dart
│   ├── networks/
│   │   ├── api_constants.dart
│   │   ├── auth_interceptor.dart
│   │   ├── dio_client.dart
│   │   └── network_providers.dart
│   ├── providers/
│   │   └── theme_mode_provider.dart
│   ├── services/
│   │   └── theme_preferences_service.dart
│   ├── utils/
│   │   ├── currency_utils.dart
│   │   ├── date_utils.dart
│   │   └── password_validator.dart
│   └── widgets/
│       ├── confirm_dialog.dart
│       └── password_requirements.dart
│
├── features/
│   │
│   ├── authentication/
│   │   ├── data/
│   │   │   │   auth_dependencies.dart
│   │   │   ├── datasources/
│   │   │   │       auth_remote_datasource.dart
│   │   │   └── repositories/
│   │   │           auth_repository_impl.dart
│   │   ├── domain/
│   │   │   └── repositories/
│   │   │           auth_repository.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │       auth_provider.dart
│   │       ├── screens/
│   │       │       login_screen.dart
│   │       │       register_screen.dart
│   │       │       reset_password_screen.dart
│   │       │       splash_screen.dart
│   │       └── widgets/
│   │
│   ├── profile/
│   │   ├── data/
│   │   │   │   profile_dependencies.dart
│   │   │   ├── datasources/
│   │   │   │       profile_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │       disliked_ingredient_model.dart
│   │   │   │       food_allergy_model.dart
│   │   │   │       profile_create_request.dart
│   │   │   │       profile_model.dart
│   │   │   │       profile_update_request.dart
│   │   │   └── repositories/
│   │   │           profile_repository_impl.dart
│   │   ├── domain/
│   │   │   └── repositories/
│   │   │           profile_repository.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │       profile_provider.dart
│   │       ├── screens/
│   │       │       profile_screen.dart
│   │       │       profile_setup_screen.dart
│   │       └── widgets/
│   │               profile_form.dart
│   │
│   ├── home/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │       └── screens/
│   │               home_screen.dart
│   │
│   ├── pantry/
│   │   ├── data/
│   │   │   │   pantry_dependencies.dart
│   │   │   ├── datasources/
│   │   │   │       ingredient_suggestion_remote_datasource.dart
│   │   │   │       pantry_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │       ingredient_suggestion_model.dart
│   │   │   │       pantry_item_create_request.dart
│   │   │   │       pantry_item_model.dart
│   │   │   │       pantry_item_update_request.dart
│   │   │   └── repositories/
│   │   │           pantry_repository_impl.dart
│   │   ├── domain/
│   │   │   └── repositories/
│   │   │           pantry_repository.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │       pantry_provider.dart
│   │       ├── screens/
│   │       │       pantry_screen.dart
│   │       └── widgets/
│   │               add_pantry_item_dialog.dart
│   │               pantry_item_card.dart
│   │
│   ├── meals/
│   │   ├── data/
│   │   │   │   meal_dependencies.dart
│   │   │   ├── datasources/
│   │   │   │       meals_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │       meal_model.dart
│   │   │   └── repositories/
│   │   │           meal_repository_impl.dart
│   │   ├── domain/
│   │   │   └── repository/
│   │   │           meal_repository.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │       meal_provider.dart
│   │       ├── screens/
│   │       │       meals_screen.dart
│   │       │       meal_detail_screen.dart
│   │       └── widgets/
│   │               meal_card.dart
│   │
│   ├── meal_planner/
│   │   ├── data/
│   │   │   │   meal_planner_dependencies.dart
│   │   │   ├── datasources/
│   │   │   │       meal_planner_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │       meal_plan_entry_model.dart
│   │   │   │       meal_plan_entry_request.dart
│   │   │   └── repositories/
│   │   │           meal_planner_repository_impl.dart
│   │   ├── domain/
│   │   │   └── repositories/
│   │   │           meal_planner_repository.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │       meal_planner_provider.dart
│   │       ├── screens/
│   │       │       add_edit_meal_plan_entry_screen.dart
│   │       │       meal_planner_screen.dart
│   │       └── widgets/
│   │               day_stab_strip.dart
│   │               meal_plan_entry_card.dart
│   │
│   ├── recommendations/
│   │   ├── data/
│   │   │   │   recommendation_dependencies.dart
│   │   │   ├── datasources/
│   │   │   │       recommendation_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │       recommendation_model.dart
│   │   │   └── repositories/
│   │   │           recommendation_repository_impl.dart
│   │   ├── domain/
│   │   │   └── repositories/
│   │   │           recommendation_repository.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │       recommendation_provider.dart
│   │       ├── screens/
│   │       │       recommendations_screen.dart
│   │       └── widgets/
│   │               recommendation_card.dart
│   │
│   ├── nutrition/
│   │   ├── data/
│   │   │   └── models/
│   │   │           nutrition_adequacy_model.dart
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── grocery_list/
│   │   ├── data/
│   │   │   │   grocery_checklist_storage.dart
│   │   │   │   grocery_list_dependencies.dart
│   │   │   ├── datasources/
│   │   │   │       grocery_list_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │       grocery_list_model.dart
│   │   │   └── repositories/
│   │   │           grocery_list_repository_impl.dart
│   │   ├── domain/
│   │   │   └── repositories/
│   │   │           grocery_list_repository.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │       grocery_list_provider.dart
│   │       ├── screens/
│   │       │       grocery_list_screen.dart
│   │       └── widgets/
│   │               grocery_list_item_card.dart
│   │
│   ├── favorites/
│   │   ├── data/
│   │   │   │   favorites_dependencies.dart
│   │   │   ├── datasources/
│   │   │   │       favorites_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │       favorite_model.dart
│   │   │   └── repositories/
│   │   │           favorites_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │       favorite.dart
│   │   │   └── repositories/
│   │   │           favorites_repository.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │       favorites_provider.dart
│   │       ├── screens/
│   │       │       favorites_screen.dart
│   │       └── widgets/
│   │               favorite_button.dart
│   │               favorite_meal_card.dart
│   │
│   └── settings/
│       ├── data/
│       ├── domain/
│       └── presentation/
│           ├── providers/
│           ├── screens/
│           │       settings_screen.dart
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
* ✅ Nutrition section (Meal Detail) and nutrition badge (recommendation cards) (Week 8)
* ✅ Live password-strength checklist on Register, with animated pill ticks and auto-collapse on completion
* ✅ Redesigned Grocery List item cards — circular check indicator, colored accent stripe, per-item and total cost display

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
├── Favorites
│
└── Nutrition
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

Password-reset link handling also does not go through the FastAPI backend — it's a Supabase Auth-native flow (Supabase sends the email and hosts the reset page); the app only triggers `POST` to Supabase's reset-request endpoint via the Supabase Flutter SDK.

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
+
Ingredient Prices
      ↓
Required − Available (priced where known)
      ↓
Grocery List (+ estimated cost)
```

Favorites is independent of the planning pipeline — a meal can be favorited without ever being scheduled:

```text
Meal Card / Meal Details
      ↓
Favorite Toggle
      ↓
Favorites Screen
```

Nutrition (Week 8) is also independent of the planning pipeline — it is computed per meal for the signed-in user and shown wherever a meal is shown in detail or recommended:

```text
Profile (DOB, sex, activity level)
+
Meal (calories, ingredients)
      ↓
Nutritional Adequacy (server-computed)
      ↓
Meal Details section  /  Recommendation badge
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
* ✅ Grocery list per-item and total estimated cost render correctly against seeded price data
* ✅ Grocery list unpriced item shows no cost line and is excluded from the total
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
* ✅ Recommendations: affordability filter — meals over the budget per meal are excluded (Week 7)
* ✅ Consistent peso formatting across all money displays (Week 7)
* ✅ Profile Setup and Edit both require a physical activity level (Week 7)
* ✅ Budget-per-meal rename verified end-to-end — no stale `daily_budget`/`dailyBudget` references in requests or responses
* ✅ Password Register submit blocked with a listing of unmet rules until every password requirement is satisfied
* ✅ Password live checklist collapses after all rules are met, and reappears if the password is edited back to invalid
* ✅ Nutrition: backend adequacy logic verified by hand calculation and through the evaluation harness (Week 8)

### Not yet verified

* 🔲 Ingredient-unit auto-detection for the ambiguous case (an ingredient used with 2+ different units across meals) — not yet exercised against real seed data
* 🔲 Grocery list correctness against a fully populated week (multiple meals/slots, overlapping ingredients)
* 🔲 Favorites behavior when the underlying meal is deleted from the catalog (cascade is implemented backend-side but not exercised end-to-end from the app)
* 🔲 Automated unit tests for `scoring.py` — cooking-skill scoring was verified manually only (Swagger + in-app)
* 🔲 Meal servings, ingredient quantities, cost, and calories normalized to a 1-serving baseline (Week 7, Day 4)
* 🔲 Nutrition UI in the non-standard states: activity level not set, unavailable results, and staple meals (Garlic Fried Rice) — confirm end-to-end in the app
* 🔲 Automated tests for the Nutrition feature (backend and Flutter) — verification so far is manual
* 🔲 Automated tests for `PasswordValidator` — verification so far is manual, in-app only

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
* Supabase Auth password policy configured to match `PasswordValidator`'s rules (min 8 characters, upper/lowercase, number, symbol) — see Password Security above

The backend must have the required environment variables configured, including:

```text
DATABASE_URL
SUPABASE_URL
SUPABASE_SERVICE_ROLE_KEY
```

The service-role key is **server-side only** and must never be included in the Flutter application.

The backend database must be fully migrated (`alembic upgrade head`) — Nutrition depends on the `ingredient_food_groups` table and its seed data, and Grocery List pricing depends on `ingredient_prices` being seeded.

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
* [x] Password strength validator + live checklist (Week 7)

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
* [x] Budget per meal (renamed from daily budget)
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
* [x] `ingredient_prices` reference table + placeholder seed data
* [x] Per-item `estimated_cost` and response-level `total_estimated_cost`
* [x] Flutter models/UI updated to surface cost per item and total
* [x] Redesigned item card with circular check, accent stripe, capitalized ingredient names

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

## Phase 10 — Week 7 Fixes 🚧 (Day 4 [servings] outstanding)

* [x] Meal Planner past-date/slot guard (backend `400` + client-side disabled dates/slots)
* [x] Centralized meal-planner cutoff constants (backend + client)
* [x] `BadRequestException` so the backend's guard message reaches the UI
* [x] Single shared `formatPeso()` utility, swept across every money display
* [x] `sort_by` (`score` / `cost`) on `GET /api/v1/recommendations`
* [x] Affordability hard filter (meals over the budget per meal excluded)
* [x] Fallback meals returned by the backend, tiered after `adapt` meals
* [x] Floating "Best Match" / "Lowest Cost" sort toggle
* [x] Client-side re-sort architecture in `RecommendationController`
* [x] Cooking skill scoring manually verified against all 20 seeded meals
* [x] `physical_activity_level` on Profile — backend enum + migration, required on create
* [x] Physical activity level in Flutter (`ProfileOptions`, shared `ProfileForm`, create/update requests, Profile view)
* [x] `PasswordValidator` + live `PasswordRequirements` checklist on Register
* [x] Password reset policy synced with Supabase Auth dashboard configuration
* [x] `daily_budget` → `budget_per_meal` rename propagated through the entire Flutter codebase
* [x] Grocery List pricing surfaced in Flutter models and UI
* [ ] Meal servings normalization — 1-serving baseline across all 20 seeded meals (ingredient quantities, cost, calories)

## Phase 11 — Nutrition 🚧 (results pending final data verification)

* [x] PDRI 2015 energy table and daily caloric requirement (sex + age bracket, scaled for activity level)
* [x] `ingredient_food_groups` reference table and seed (Go / Grow / Glow / other)
* [x] Caloric adequacy against a per-meal bracket
* [x] Food-group proportions and Pinggang Pinoy adequacy
* [x] Combined nutritional adequacy result
* [x] Ulam-only scaling of the calorie bracket and food-group bands
* [x] Staple-meal handling in the backend (`is_staple`)
* [x] Missing ingredient classifications and gram conversions filled in
* [x] `GET /api/v1/meals/{meal_id}/nutrition-adequacy`
* [x] `/recommendations` response extended with nutrition results
* [x] Flutter `ApiConstants.mealNutritionAdequacy(id)`
* [x] Nutrition section on Meal Detail
* [x] Nutrition badge on recommendation cards
* [x] Evaluation harness for Objective 4 (`scripts/evaluate_nutrition_adequacy.py`)
* [ ] Flutter display for staple meals
* [ ] Final evaluation rerun after servings/calories normalization

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

### 🥗 Detailed Nutrition Metrics — 🔲 Not Yet Implemented

Caloric and food-group adequacy are implemented (see Nutrition above). Per-nutrient detail is not:

* [ ] Protein
* [ ] Carbohydrates
* [ ] Fat
* [ ] Other nutritional metrics

Basic calorie information is available for seeded meals.

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

### 💰 Sourced Grocery Prices — 🔲 Not Yet Implemented

* [ ] Replace placeholder/estimated `ingredient_prices` data with real, sourced pricing (e.g. DTI price monitoring)

---

# 📌 Project Status

> **Current milestone: Week 6 Complete 🎉 — Week 7 Nearly Complete (Day 4 [servings] outstanding) — Week 8 (Nutrition) Built, results pending final data verification**

TipidMeal now has a working core application flow consisting of:

```text
Authentication
      ↓
Profile ──→ Settings
      ↓
Home ──→ Favorites
      ↓
Meals ──→ Nutrition
      ↓
Meal Planner
      ↓
Grocery List
      ↓
Pantry
      ↓
Deterministic Recommendations (+ Nutrition badge)
      ↓
Meal Details
```

Completed in Week 8:

* ✅ Daily caloric requirement per profile (PDRI 2015, scaled for physical activity level)
* ✅ Ingredient food-group classification (Go / Grow / Glow / other)
* ✅ Caloric adequacy and Pinggang Pinoy food-group adequacy, combined into a nutritional-adequacy result
* ✅ Ulam-only scaling and staple handling to fit single-dish meal data
* ✅ `GET /meals/{id}/nutrition-adequacy` and nutrition results on `/recommendations`
* ✅ Nutrition section on Meal Detail and nutrition badge on recommendation cards
* ✅ Evaluation harness for the Objective 4 accuracy measure

Completed in Week 7:

* ✅ Meal Planner past-date/slot guard (backend + client)
* ✅ `BadRequestException` — backend guard messages now surface clearly in the UI
* ✅ Consistent `₱0.00`-style peso formatting via a single shared formatter
* ✅ Cost-based recommendation sorting (`sort_by=cost`) with a floating "Best Match" / "Lowest Cost" toggle
* ✅ Client-side re-sort for instant, race-free toggling
* ✅ Affordability hard filter — meals over the budget per meal are excluded
* ✅ Fallback meals now returned by the backend and tiered after `adapt` meals
* ✅ Cooking skill scoring manually verified against all 20 seeded meals
* ✅ Physical activity level on Profile (required at setup, editable later) — feeds Week 8's Nutrition feature
* ✅ Live password-strength checklist on Register, synced with Supabase Auth's password policy
* ✅ `daily_budget` → `budget_per_meal` rename, fully propagated through Flutter
* ✅ Grocery List pricing — per-item estimated cost and running total, redesigned item card

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

* 🔲 Meal servings normalization to a 1-serving baseline (Week 7, Day 4) — seeded servings, quantities, cost, and calories are still sample data, so nutrition results are provisional
* 🔲 Final Objective 4 evaluation rerun once the servings/calories data is normalized
* 🔲 Flutter display for staple meals (`is_staple`)
* 🔲 Automated unit tests for `scoring.py`, `PasswordValidator`, and for the Nutrition feature (all verified manually only)
* 🔲 Food categories
* 🔲 Advanced meal filtering
* 🔲 Detailed nutrition metrics (protein, carbohydrates, fat)
* 🔲 Notifications
* 🔲 AI-assisted recommendations
* 🔲 Admin functionality
* 🔲 Multi-unit ingredient auto-detection — not yet exercised against real ambiguous data
* 🔲 Grocery checklist cloud sync (currently local-only via `SharedPreferences`)
* 🔲 Favorites behavior on meal deletion — not yet exercised end-to-end from the app
* 🔲 Sourced (non-placeholder) grocery ingredient prices

These remain the primary targets for subsequent phases.

---

## 📄 License

This project is currently under development as part of an undergraduate thesis.