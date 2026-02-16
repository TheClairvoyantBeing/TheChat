# Build Guide

How to build TheChat for distribution (Release mode).

## Prerequisites

- Flutter SDK (3.x+)
- Visual Studio Build Tools with **Desktop development with C++** workload (Windows only)
- Developer Mode enabled on Windows (Settings → Privacy & Security → For Developers)

## Windows Desktop

```powershell
flutter build windows
```

**Output:** `build\windows\x64\runner\Release\`

Copy the **entire** `Release\` folder to distribute. It contains `the_chat.exe` plus required DLLs and assets.

## Android APK

```powershell
flutter build apk
```

**Output:** `build\app\outputs\flutter-apk\app-release.apk`

Transfer to your phone and install (enable "Install from Unknown Sources" if needed).

## Web

```powershell
flutter build web
```

**Output:** `build\web\`

Deploy the contents to any static hosting service.

---

## Troubleshooting

**Clean build** (if you encounter weird errors):

```powershell
flutter clean
flutter pub get
```

**Regenerate Hive adapters** (if you modify data models):

```powershell
dart run build_runner build --delete-conflicting-outputs
```
