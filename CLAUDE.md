# House App — CLAUDE.md

## Project
Flutter app for house construction in Punjab, India. Android APK only.
- Flutter: `/home/navdeep/snap/flutter/common/flutter/bin/flutter`
- Package: `com.navdeep.house_app`

## Architecture
Feature-based under `lib/features/`. Each feature is self-contained:
```
lib/
├── core/theme/     app_theme.dart
├── core/router/    app_router.dart (go_router)
└── features/
    └── converter/  Unit converter (Feature 1)
```
State: Riverpod (`StateNotifierProvider`). Routing: go_router.

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
| Marla | 272.25 |
| Biswa | 544.5 |
| Kanal | 5,445 |
| Bigha | 10,890 |
| Acre | 43,560 |
| Murabba | 1,089,000 |

## Rules
- After each feature: update CLAUDE.md, commit, push to GitHub
- Use Gradle for builds (flutter CLI hangs on initialization — do not use)
- Keep CLAUDE.md minimal, no duplicates

## Features
- [x] Feature 1: Land unit converter (area ↔ area, L×B → area)
