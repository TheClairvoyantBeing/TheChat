# Token Management & Optimization

## How It Works

TheChat uses advanced token estimation to keep usage within Groq's limits while maximizing conversation history.

### 1. Context Window Strategy

Groq's Llama-3.3-70b-versatile model has a large context window (128k tokens). We leverage this to provide long-term memory, but we need to prevent potential overflows or unnecessary costs.

**Strategy:**

- **Recent Messages**: Always send the last 20-30 exchanges verbatim.
- **Older Context**: Use summarized versions of older messages.
- **System Prompts**: Always included at the start (`roles: "system"`).
- **Pruning**: Automatically remove oldest messages from the API payload if total tokens exceed 80% of the limit.

### 2. Token Estimation

We use a lightweight local tokenizer (Tiktoken or similar Dart implementation) to estimate token usage _before_ sending a request. This prevents failed API calls due to context overflow.

### 3. Usage Tracking

Every API response from Groq includes actual usage metrics (`usage.total_tokens`, `usage.completion_tokens`, etc.). We store these locally to:

- calculate daily/monthly usage.
- estimate cost based on Groq's pricing (approx $0.70/1M input tokens).

## Optimization Tips

- **Concise Prompts**: Avoid overly verbose instructions.
- **Use "New Chat"**: Start fresh conversations for new topics to avoid carrying unnecessary context.
- **Model Selection**: Use smaller models (`llama-3-8b`) for simple tasks if available (future feature).
