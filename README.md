# Context7 MCP - Up-to-date Code Docs For Any Prompt

[![Website](https://img.shields.io/badge/Website-context7.com-blue)](https://context7.com)

## ❌ Without Context7

LLMs rely on outdated or generic information about the libraries you use. You get:

- ❌ Code examples are outdated and based on year-old training data
- ❌ Hallucinated APIs that don't even exist
- ❌ Generic answers for old package versions

## ✅ With Context7

Context7 MCP pulls up-to-date, version-specific documentation and code examples straight from the source — and places them directly into your prompt.

Add `use context7` to your prompt in Cursor:

```txt
Create a Next.js middleware that checks for a valid JWT in cookies and redirects unauthenticated users to `/login`. use context7
```

```txt
Configure a Cloudflare Worker script to cache JSON API responses for five minutes. use context7
```

Context7 fetches up-to-date code examples and documentation right into your LLM's context.

- 1️⃣ Write your prompt naturally
- 2️⃣ Tell the LLM to `use context7`
- 3️⃣ Get working code answers

No tab-switching, no hallucinated APIs that don't exist, no outdated code generation.

## 🛠️ Installation

### Requirements

- macOS 13.0+ (for Swift implementation)
- Swift 6.0+ (Xcode 16+)
- Cursor, Claude Code, VSCode, Windsurf or another MCP Client
- Context7 API Key (Optional) for higher rate limits (Get yours at [context7.com/dashboard](https://context7.com/dashboard))

### Quick Start

1. **Clone and build:**
```bash
git clone https://github.com/upstash/context7.git
cd context7
swift build
```

2. **Run the server:**
```bash
swift run context7-mcp --api-key YOUR_API_KEY
```

3. **Configure your MCP client:**
```json
{
  "mcpServers": {
    "context7": {
      "command": "swift",
      "args": ["run", "context7-mcp", "--api-key", "YOUR_API_KEY"],
      "cwd": "/path/to/context7"
    }
  }
}
```

## 🔨 Available Tools

Context7 MCP provides the following tools that LLMs can use:

- `resolve-library-id`: Resolves a general library name into a Context7-compatible library ID.
  - `libraryName` (required): The name of the library to search for

- `get-library-docs`: Fetches documentation for a library using a Context7-compatible library ID.
  - `context7CompatibleLibraryID` (required): Exact Context7-compatible library ID (e.g., `/mongodb/docs`, `/vercel/next.js`)
  - `topic` (optional): Focus the docs on a specific topic (e.g., "routing", "hooks")
  - `tokens` (optional, default 5000): Max number of tokens to return. Values less than 1000 are automatically increased to 1000.

## 🛟 Tips

### Add a Rule

If you don't want to add `use context7` to every prompt, you can define a simple rule in your MCP client's rule section:

```txt
Always use context7 when I need code generation, setup or configuration steps, or
library/API documentation. This means you should automatically use the Context7 MCP
tools to resolve library id and get library docs without me having to explicitly ask.
```

### Use Library Id

If you already know exactly which library you want to use, add its Context7 ID to your prompt:

```txt
Implement basic authentication with Supabase. use library /supabase/supabase for API and docs.
```

The slash syntax tells the MCP tool exactly which library to load docs for.

## 💻 Development

### Swift Development

Clone the project and build:

```bash
swift build
```

Run tests:

```bash
swift test
```

Build for release:

```bash
swift build -c release
```

The executable will be available at `.build/release/context7-mcp`.

### CLI Arguments

`context7-mcp` accepts the following CLI flags:

- `--api-key <key>` – API key for authentication (or set `CONTEXT7_API_KEY` env var)

Example with API key:

```bash
swift run context7-mcp --api-key YOUR_API_KEY
```

### Environment Variables

You can use the `CONTEXT7_API_KEY` environment variable instead of passing the `--api-key` flag.

**Example with .env file:**

```bash
# .env
CONTEXT7_API_KEY=your_api_key_here
```

## 🚨 Troubleshooting

### Swift-Specific Issues

1. **Swift Version**: Ensure you're using Swift 6.0+ (Xcode 16+)
2. **macOS Version**: Requires macOS 13.0+ for full async/await support
3. **Build Issues**: Try `swift package clean` and rebuild

### General MCP Client Errors

1. Ensure you're using a compatible MCP client
2. Check that the Swift executable path is correct
3. Verify your API key is valid and starts with 'ctx7sk'

## ⚠️ Disclaimer

Context7 projects are community-contributed and while we strive to maintain high quality, we cannot guarantee the accuracy, completeness, or security of all library documentation. Projects listed in Context7 are developed and maintained by their respective owners, not by Context7. If you encounter any suspicious, inappropriate, or potentially harmful content, please use the "Report" button on the project page to notify us immediately. We take all reports seriously and will review flagged content promptly to maintain the integrity and safety of our platform. By using Context7, you acknowledge that you do so at your own discretion and risk.

## 🤝 Connect with Us

Stay updated and join our community:

- 📢 Follow us on [X](https://x.com/context7ai) for the latest news and updates
- 🌐 Visit our [Website](https://context7.com)
- 💬 Join our [Discord Community](https://upstash.com/discord)
