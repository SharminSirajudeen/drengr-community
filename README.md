# Drengr

**Eyes and hands for AI agents on mobile devices.**

Drengr is an MCP server that gives AI agents (Claude, GPT, Gemini) the ability to see, tap, type, and navigate mobile apps — Android and iOS.

---

## Install

```bash
npm install -g drengr
```

Or run without installing:

```bash
npx drengr
```

Or via shell script:

```bash
curl -fsSL https://drengr.dev/install.sh | bash
```

---

## Quick Setup

```bash
# Check your system
drengr doctor

# Configure your MCP client (Claude Desktop, Claude Code, Cursor, etc.)
drengr setup
```

## Add to Claude Desktop

Add to `~/Library/Application Support/Claude/claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "drengr": {
      "command": "drengr",
      "args": ["mcp"]
    }
  }
}
```

## Add to Claude Code

```bash
claude mcp add drengr -- drengr mcp
```

## Add to Cursor

Add to `.cursor/mcp.json` in your project:

```json
{
  "mcpServers": {
    "drengr": {
      "command": "drengr",
      "args": ["mcp"]
    }
  }
}
```

---

## What Drengr does

- **3 MCP tools**: `drengr_look` (observe screen), `drengr_do` (take action), `drengr_query` (ask questions)
- **Android & iOS** — ADB for Android, simctl for iOS, Appium for cloud devices
- **Vision-first** — sees your app like a human via annotated screenshots
- **Text mode** — ~300 tokens per screen instead of 100KB images
- **Situation reports** — after every action: what changed, what's new, is it stuck?
- **Screen exploration** — auto-maps your app's navigation graph
- **Network capture** — sees HTTP calls during each action

---

## In-app SDKs

Zero-code, in-process network capture: one call records every HTTP request/response
with secret/PII redaction applied before anything leaves the device. No `track()`
calls, no changes to your networking code. Available for Flutter, Web/React
Native/Electron, iOS, and Android. Apache-2.0 — the SDKs are open; the rest of
Drengr (the MCP server / CLI above) is proprietary.

### Flutter

[`drengr_flutter_sdk`](https://pub.dev/packages/drengr_flutter_sdk) on pub.dev.

```yaml
dependencies:
  drengr_flutter_sdk: ^0.1.1
```

Source, changelog, and docs in [`flutter/`](flutter/).

### Web (Web, React Native, Electron)

```bash
npm install drengr-js
```

```ts
import { Drengr } from 'drengr-js';

Drengr.start({
  ingestUrl: 'https://<ref>.supabase.co/functions/v1/ingest',
  publishableKey: 'drengr_pk_…',
  appPackage: 'com.example.app',
});
```

Source and docs in [`js/`](js/).

### iOS (Swift Package Manager)

Xcode: **File → Add Package Dependencies…** and enter:

```
https://github.com/SharminSirajudeen/drengr-community.git
```

Or in `Package.swift`:

```swift
.package(url: "https://github.com/SharminSirajudeen/drengr-community.git", from: "0.11.0")
```

then add `"Drengr"` to your target's dependencies. CocoaPods is also available
(`pod 'Drengr'`, spec at [`ios/Drengr.podspec`](ios/Drengr.podspec)). Source and
docs in [`ios/`](ios/).

### Android (JitPack)

`settings.gradle.kts`:

```kotlin
dependencyResolutionManagement {
    repositories {
        google(); mavenCentral()
        maven("https://jitpack.io")
    }
}
```

`app/build.gradle.kts` — this repo publishes the `:drengr` module out of a
multi-module Gradle build (root project `drengr-android` + subproject `:drengr`),
so JitPack's per-module coordinate applies (`com.github.User.Repo:module:Tag`,
**not** the single-artifact `com.github.User:Repo:Tag` form):

```kotlin
dependencies {
    implementation("com.github.SharminSirajudeen:drengr-community:v0.11.0")
}
```

Build config: [`jitpack.yml`](jitpack.yml). Source and docs in [`android/`](android/).

---

## Supported platforms

| Platform | Architecture | Supported |
|----------|-------------|-----------|
| macOS    | arm64 (M1+) | ✓         |
| macOS    | x64         | ✓         |
| Linux    | x64         | ✓         |
| Linux    | arm64       | ✓         |

---

## Documentation

Full documentation at [drengr.dev](https://drengr.dev)

## License

Proprietary — © 2026 Drengr. All rights reserved.
See [LICENSE](LICENSE) for details.

