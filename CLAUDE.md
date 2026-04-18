# House App — CLAUDE.md

## Project
Flutter app for house construction in Punjab, India. Android APK only.
- Flutter: `/home/navdeep/snap/flutter/common/flutter/bin/flutter`
- Package: `com.navdeep.house_app`

## Architecture
Feature-based under `lib/features/`. Each feature is self-contained:
```
lib/
├── core/theme/           app_theme.dart
├── core/router/          app_router.dart (go_router)
├── core/presentation/    home_screen.dart (BottomNavigationBar shell)
└── features/
    ├── converter/         Unit converter (Feature 1)
    └── brick_calculator/  Brick calculator (Feature 2)
```
State: Riverpod (`StateNotifierProvider`). Routing: go_router. Navigation: `NavigationBar` (Material 3) in `HomeScreen`.

## Build
Use Gradle (NOT `flutter build apk` — gets stuck on initialization):
```bash
cd android && ./gradlew copyApkToProject
```
APK is auto-copied to `/home/navdeep/House/house-app.apk` after each build.

## Punjab Land Units (base = sq ft)
| Unit | Sq Ft |
|------|-------|
| Biswansi | 27.225 |
| Small Marla | 225.0 |
| Big Marla | 272.25 |
| Biswa | 544.5 |
| Kanal | 5,445 |
| Bigha | 10,890 |
| Acre | 43,560 |
| Murabba | 1,089,000 |

## Validation (after every feature)
1. Build: `cd android && ./gradlew copyApkToProject`
2. Install: `adb install -r /home/navdeep/House/house-app.apk`
3. Launch: `adb shell am start -n com.navdeep.house_app/.MainActivity`
4. Screenshot: `adb shell screencap -p /sdcard/s.png && adb pull /sdcard/s.png /tmp/s.png` — visually verify UI
5. Emulator: `NutriTrack_Pixel` — launch with `flutter emulators --launch NutriTrack_Pixel`

## Rules
- After each feature: build → validate on emulator → update CLAUDE.md → commit → push to GitHub
- Use Gradle for builds (flutter CLI hangs on initialization — do not use)
- Keep CLAUDE.md minimal, no duplicates
- `adb exec-out screencap -p > file.png` produces empty files — do not use
- Always add new features one at a time; keep architecture scalable

## Features
- [x] Feature 1: Land unit converter (area ↔ area, L×B → area)
- [x] Feature 2: Brick calculator — boundary wall bricks, wall height, cost estimate. Custom brick dimensions (default 9×4×4 inches), 2 parallel rows.
- [x] Feature 3: Cement & Sand calculator — mortar ratio (1:3/1:4/1:6), bags of cement + cft of sand for boundary wall, optional cost per bag/cft.
- [x] Feature 4: Cost Estimator — combines bricks + cement + sand + labor. Labor: mason & laborer day rates, dynamic per-day entry (variable headcount per day).
