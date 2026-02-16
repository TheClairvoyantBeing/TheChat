# TheChat

A local-first, privacy-focused chatbot powered by the **Groq API** and built with **Flutter**.

## ✨ Features

- **Groq API Integration** — Blazing-fast LLM inference via Groq Cloud (Llama 3.3 70B, Llama 3.1 8B, Gemma 2, and more).
- **Streaming Responses** — Real-time token-by-token output using Server-Sent Events (SSE).
- **Cross-Platform** — Runs on Windows, Android, Web, macOS, and Linux.
- **Local Storage** — All conversations stored locally on-device using Hive (no server, no tracking).
- **Markdown Rendering** — Rich text formatting for code blocks, lists, bold, and more.
- **Dark Mode** — Toggle between light and dark themes.
- **Conversation Search** — Quickly find past chats by title.
- **Multi-Model Support** — Switch between available Groq models in Settings.

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.x+)
- A free [Groq API Key](https://console.groq.com/keys)
- (Windows only) Visual Studio Build Tools with C++ workload

### Install & Run

```bash
# Clone the repository
git clone https://github.com/TheClairvoyantBeing/TheChat.git
cd TheChat

# Install dependencies
flutter pub get

# Run on Windows Desktop
flutter run -d windows

# Run on Chrome (Web)
flutter run -d chrome

# Run on Android (connect device first)
flutter run -d <device-id>
```

### Configure

1. Launch the app.
2. Click the **Settings** icon (⚙️).
3. Paste your **Groq API Key** (`gsk_...`).
4. Choose your preferred model.
5. Click **Save & Close** — you're ready to chat!

## 🏗️ Build for Release

```bash
# Windows .exe → build\windows\x64\runner\Release\
flutter build windows

# Android APK → build\app\outputs\flutter-apk\app-release.apk
flutter build apk

# Web → build\web\
flutter build web
```

> **Windows note:** Copy the entire `Release\` folder when distributing — it includes required DLLs and assets.

## 📂 Project Structure

```
lib/
├── main.dart              # App entry point & theme configuration
├── models/                # Hive data models (Conversation, Message, AppSettings)
├── providers/             # State management (ChatProvider)
├── services/              # Business logic
│   ├── groq_service.dart  # Groq API client (streaming chat completions)
│   ├── storage_service.dart # Hive local persistence
│   └── token_service.dart # Context window management
└── screens/               # UI screens (Home, Settings)
```

## 📖 Documentation

- [Setup Guide](docs/SETUP.md) — Installation and prerequisites
- [Architecture](docs/ARCHITECTURE.md) — System design and data flow
- [Build Guide](docs/BUILD.md) — Release build instructions

## 🔒 Privacy

- Your API key is stored **locally** on your device only.
- All chat history lives in local Hive databases — nothing is sent to any server except Groq's API for inference.
- No analytics, no tracking, no telemetry.

## License

MIT
