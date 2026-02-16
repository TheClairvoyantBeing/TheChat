# System Architecture

## Overview

**TheChat** is a local-first, privacy-focused chatbot application built with Flutter that leverages the Groq API for high-speed LLM inference. It features a modern, Claude/Gemini-inspired UI and robust token management.

## Tech Stack

### Frontend (User Interface)

- **Framework**: Flutter (Dart)
- **Target Platforms**: Windows, Android (primary), macOS/Linux/Web (supported)
- **State Management**: Provider
- **Networking**: Dio (for robust HTTP requests)
- **Local Storage**: Hive (NoSQL key-value database)

### Backend (Logic & Services)

- **API**: Groq Cloud API (`llama-3.3-70b-versatile`)
- **Token Handling**: Client-side estimation & server-side reporting
- **Data Persistence**: Local filesystem (via Hive boxes)

---

## Data Flow

1. **User Input**
   - User types message in `ChatScreen`.
   - Input is validated and added to local state.

2. **Token Estimation**
   - `TokenService` estimates input tokens to ensure context window limits.
   - If context is too long, older messages are summarized or truncated (future optimization).

3. **API Request**
   - `GroqService` sends formatted messages to Groq API.
   - Request includes `stream: true` for real-time feedback.

4. **Streaming Response**
   - App receives Server-Sent Events (SSE).
   - `ChatProvider` updates the UI incrementally as chunks arrive.
   - Haptic feedback (optional) on completion.

5. **Storage & Analytics**
   - Full conversation history saved to `conversations` Hive box.
   - Final message + token usage stats saved to `messages` Hive box.
   - `TokenProvider` updates daily usage metrics.

---

## Directory Structure

```
lib/
├── components/          # Reusable UI widgets
│   ├── chat/            # Chat bubbles, input bar
│   └── sidebar/         # Navigation, conversation list
├── models/              # Data classes (Conversation, Message)
├── providers/           # State management logic
├── services/            # API, Storage, Token logic
├── screens/             # Main application screens
│   ├── home_screen.dart
│   └── settings_screen.dart
└── utils/               # Helpers (dates, formatting)
```

## Security Strategy

- **API Key Storage**: Stored securely in encrypted Hive box or system keychain.
- **Data Privacy**: All chat data resides locally on the user's device. No external servers (except Groq API).
