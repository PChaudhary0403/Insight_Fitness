# INSIGHT App — Update Changelog

> This document tracks all changes made to the app in each session. If a conversation hits token limits, resume from here.

---

## Session 3 — June 3, 2026

### Context
- Android build is broken: JDK 25 version string `25.0.1` can't be parsed by Kotlin compiler
- No notification system exists in the app
- Screen time monitoring uses 100% simulated/random data
- User wants: fix build → add real notifications → real screen monitoring → remove fake data

### Changes Made

#### 1. 🔧 Fix Android Build (JDK/Gradle Compatibility)
- **Problem:** `java.lang.IllegalArgumentException: 25.0.1` — Kotlin compiler's `JavaVersion.parse()` can't handle JDK 25
- **Fix:** Pin Kotlin to a version compatible with JDK 25, or set `JAVA_HOME` to JDK 21
- **Files changed:** `android/settings.gradle.kts` — downgraded Kotlin version
- **Status:** ⏳ In Progress

#### 2. 📢 Add Real Notification System
- **Package:** `flutter_local_notifications` added to `pubspec.yaml`
- **New file:** `lib/shared/services/notification_service.dart`
  - Singleton `NotificationService` with `init()`, `scheduleReminder()`, `cancelAll()`
  - Android notification channel: `insight_reminders`
  - Supports: hydration reminders, meal reminders, exercise breaks, screen time breaks
  - Periodic scheduling using `zonedSchedule()`
- **Android config:** Updated `AndroidManifest.xml` with notification permissions
- **Integration:** Called from `main.dart` on app startup
- **Status:** ⏳ In Progress

#### 3. 📱 Real Screen Time Monitoring (Android UsageStats)
- **New files:**
  - `android/app/src/main/kotlin/.../UsageStatsPlugin.kt` — Platform channel bridge
  - Updated `ScreenTimeService` to call platform channel on Android
- **Permission:** `PACKAGE_USAGE_STATS` added to AndroidManifest
- **Fallback:** On web/unsupported platforms, shows "Not available" message instead of fake data
- **Status:** ⏳ In Progress

#### 4. 🧹 Remove Simulated Data from Digital Wellbeing
- **Removed:** `_generateSimulatedData()` method from `ScreenTimeService`
- **Replaced with:** Real data from UsageStats API (Android) or empty state (web)
- **Fixed:** Hardcoded "You are most distracted between 9 PM–11 PM" insight
- **Status:** ⏳ In Progress

---

## Session 2 — May 22, 2026 (Later)

### Changes Made
- Added Health Assessment feature (4-step onboarding quiz → HealthProfile → scoring engine)
- Added Discipline Tracker feature (commitments, streaks, scoring)
- Added Quick Exercise feature (workout generator, session timer, calorie tracking)
- Added Daily Planner feature (task management, productivity scoring)
- Added Screen Time / Digital Wellness feature (simulated data, risk detection, wellness score)
- Added `UserDataService` singleton (persists all user data via SharedPreferences)
- Added `PlannerService` singleton (persists planner/tick-sheet data)
- Updated `routes.dart` with all new feature routes
- Updated `home_page.dart` to read from real `UserDataService` (no more hardcoded "Pankaj")
- Removed font asset declarations from `pubspec.yaml` (uses Google Fonts package instead)

### Key Files Added
```
lib/shared/services/user_data_service.dart
lib/shared/services/planner_service.dart
lib/features/health_assessment/ (6 files)
lib/features/discipline/ (4 files)
lib/features/quick_exercise/ (4 files)
lib/features/planner/ (3 files)
lib/features/screen_time/ (4 files)
```

---

## Session 1 — May 22, 2026 (Initial)

### Changes Made
- Created Flutter project scaffold with clean architecture
- Set up design system: `AppColors`, `AppTypography`, `AppTheme` (light + dark)
- Created `GoRouter` routing with shell navigation
- Built 14 pages: Welcome, Onboarding, Login, Register, Dashboard, Home, Analytics, Tick Sheet, AI Chat, Profile, Hydration, Diet, Activity, Goals
- Added all dependencies to `pubspec.yaml`
- Created 7 architecture artifacts (PRD, system arch, DB schema, API endpoints, folder structure, UI wireframes, roadmap)

### Key Architecture Decisions
- **State management:** BLoC pattern
- **Routing:** GoRouter with ShellRoute for bottom nav
- **Storage:** SharedPreferences (offline-first, synced later to PostgreSQL)
- **Theme:** Dark mode default, Material 3, glassmorphic aesthetic
- **Animations:** flutter_animate on every screen

---

## Project Location
- **Workspace:** `c:\Users\panka\Desktop\INSIGHT app`
- **Flutter:** 3.38.7 (stable)
- **Total Dart files:** ~46
- **Artifact docs:** `C:\Users\panka\.gemini\antigravity\brain\86d6f7e8-4159-4aa9-b3f9-0d327b93aa70\artifacts\`
