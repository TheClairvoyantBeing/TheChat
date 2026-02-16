# TheChat

A local-first, privacy-focused chatbot powered by the Groq API and Flutter.

## Features

- **Groq API Integration**: Fast, high-quality responses using Llama-3.3-70b-versatile.
- **Flutter UI**: Responsive design for Desktop & Mobile.
- **Local Storage**: All chats saved locally (Hive).
- **Markdown Support**: Rich text rendering.
- **Dark Mode**: Theme toggle in settings.
- **Search**: Filter conversations easily.

## Getting Started

### Prerequisites

- Flutter SDK (included in `C:\Users\evion\tools\flutter` if you followed setup).
- Groq API Key.

### Run on Windows

```bash
flutter run -d windows
```

### Run on Web (Browser)

No additional setup required!

```bash
flutter run -d chrome
```

### Run on Android

Connect your device and enable USB debugging.

```bash
flutter run -d <device-id>
```

## Documentation

- [Setup Guide](docs/SETUP.md)
- [Architecture](docs/ARCHITECTURE.md)
- [Token Management](docs/TOKEN_MANAGEMENT.md)
- [Build Guide](docs/BUILD.md)
