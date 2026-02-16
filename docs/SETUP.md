# Setup & Installation Guide

## Prerequisites

1. **Flutter SDK** (3.x or higher)
   - Download from [flutter.dev](https://flutter.dev/docs/get-started/install).
   - Add `flutter/bin` to your system PATH.

2. **Groq API Key** (free tier available)
   - Sign up at [console.groq.com](https://console.groq.com/keys).

3. **Windows-only requirements:**
   - **Developer Mode**: Settings → Privacy & Security → For Developers → enable.
   - **Visual Studio Build Tools**: Install Visual Studio 2022 with the **Desktop development with C++** workload.

4. **Recommended**: VS Code + Flutter extension for development.

---

## Installation

### 1. Clone & Install Dependencies

```bash
git clone https://github.com/TheClairvoyantBeing/TheChat.git
cd TheChat
flutter pub get
```

### 2. Run the App

```bash
# Windows Desktop
flutter run -d windows

# Chrome (Web)
flutter run -d chrome

# Android (connect device first)
flutter run -d <device-id>
```

### 3. Configure API Key

1. Open the app.
2. Click the **Settings** icon (⚙️).
3. Paste your Groq API key (`gsk_...`).
4. Select a model (default: Llama 3.3 70B).
5. Click **Save & Close**.

---

## Troubleshooting

### "flutter command not found"

Ensure `flutter/bin` is in your system PATH. Restart your terminal.

### Build errors on Windows

Run `flutter doctor` to check for missing dependencies (Visual Studio Build Tools).

### API errors

- Verify your internet connection.
- Check that your Groq API key is valid at [console.groq.com](https://console.groq.com).
- Open Settings in the app and confirm the key is saved.
