# Setup & Installation Guide

## Prerequisites

1.  **Developer Mode (Windows only)**:
    - Go to Settings -> Privacy & Security -> For Developers (or run `start ms-settings:developers`).
    - Turn **On** "Developer Mode". This is required for Flutter to create symlinks for plugins.

2.  **Visual Studio Build Tools (Windows only)**:
    - Install Visual Studio 2022 Community or Build Tools.
    - During installation, select the **"Desktop development with C++"** workload.
    - This is required to compile Windows desktop apps.

3.  **Flutter SDK**: The core framework for the app.
    - Download from [flutter.dev](https://flutter.dev/docs/get-started/install/windows) or run `git clone https://github.com/flutter/flutter.git -b stable C:\path\to\flutter`.
    - Add Flutter to your PATH (search "Edit environment variables for your account" on Windows).
4.  **Groq API Key**: Sign up at [Groq Cloud](https://console.groq.com/keys) to get your free API key.
5.  **VS Code + Flutter Extension**: Recommended for the best development experience.

---

## Installation Steps

### 1. Clone & Dependencies

Clone the repository and install Flutter packages:

```bash
git clone https://github.com/TheClairvoyantBeing/TheChat.git
cd TheChat
flutter pub get
```

### 2. Configure Environment

Since this is a local app, API keys are managed in the UI, not in a `.env` file for the built app. However, during development, you can create a `lib/env.dart` if needed (optional).

### 3. Run the App

Launch on desktop (Windows) or your connected Android device:

```bash
# For Windows
flutter run -d windows

# For Android (connect device first)
flutter run -d <device-id>
```

---

## Troubleshooting

### "flutter command not found"

Ensure the flutter/bin directory is in your system PATH. Restart your terminal after adding it.

### Build Errors

Run `flutter doctor` to check for missing dependencies (like Visual Studio build tools for Windows desktop apps).

### API Errors

If you see connection errors, verify your internet connection and that your Groq API key is valid. Check `settings -> API Key` in the app.
