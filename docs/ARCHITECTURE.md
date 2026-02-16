# System Architecture

## Overview

**TheChat** is a local-first, privacy-focused chatbot application built with Flutter that leverages the Groq API for high-speed LLM inference. It features a modern, responsive UI with streaming responses and persistent local storage.

## Tech Stack

### Frontend (User Interface)

- **Framework**: Flutter (Dart)
- **Target Platforms**: Windows, Android (primary), Web/macOS/Linux (supported)
- **State Management**: Provider (ChangeNotifier pattern)
- **Networking**: `http` package (REST API calls with SSE streaming)
- **Local Storage**: Hive (NoSQL key-value database)

### Backend (Logic & Services)

- **API**: Groq Cloud API (`https://api.groq.com/openai/v1/chat/completions`)
- **Default Model**: `llama-3.3-70b-versatile`
- **Token Handling**: Client-side estimation & context window management
- **Data Persistence**: Local filesystem (via Hive boxes)

---

## Data Flow

1. **User Input**
   - User types a message in `HomeScreen`.
   - Input is validated and saved to local Hive storage.

2. **Context Optimization**
   - `TokenService` trims conversation history to fit within the model's context window.
   - System prompts are always preserved; only the most recent 20 messages are sent.

3. **API Request**
   - `GroqService` sends OpenAI-compatible messages payload to Groq's `/chat/completions` endpoint.
   - Request includes `stream: true` for real-time token-by-token feedback.

4. **Streaming Response**
   - App receives Server-Sent Events (SSE) via chunked HTTP response.
   - `ChatProvider` updates the UI incrementally as each text delta arrives.
   - A live "streaming bubble" shows the response as it's generated.

5. **Storage**
   - Completed assistant response saved to `messages` Hive box.
   - Conversation metadata (title, timestamp, message count) updated in `conversations` Hive box.

---

## Directory Structure

```
lib/
├── main.dart              # App entry point, service initialization, theme
├── models/                # Hive-annotated data classes
│   ├── app_settings.dart  # API key, selected model, dark mode toggle
│   ├── conversation.dart  # Conversation metadata (id, title, timestamps)
│   └── message.dart       # Individual message (role, content, timestamp)
├── providers/
│   └── chat_provider.dart # Core state management for chat interactions
├── services/
│   ├── groq_service.dart  # Groq API client with SSE streaming
│   ├── storage_service.dart # Hive CRUD operations for all data
│   └── token_service.dart # Context window trimming & token estimation
└── screens/
    ├── home_screen.dart   # Main chat UI + sidebar with conversation list
    └── settings_screen.dart # API key, model selection, theme toggle
```

## Security & Privacy

- **API Key Storage**: Stored in a local Hive box on the user's device.
- **Data Privacy**: All chat data resides locally. No external servers are contacted except Groq's inference API.
- **No Telemetry**: Zero analytics or tracking.
