# Changelog

## 0.1.1

- Applied `dart format` and trimmed the pubspec description to pub.dev's length
  limit; published source is now in a verified repository. No functional changes.

## 0.1.0

Initial release.

- Zero-code in-process HTTP capture via a single `Drengr.start()`: installs an
  `HttpOverrides` beneath `dart:io`, capturing `HttpClient`, `package:http`, and
  Dio's default adapter with no per-request code.
- Captures method, URL, status, timing, sizes, headers, and size-capped
  request/response bodies — including failed (errored) and fire-and-forget
  requests.
- Secret/PII redaction by default: sensitive headers, URL secrets, and body
  fields (tokens, keys, cookies, card numbers) are masked before storage.
- Lifecycle and controls: `stop()`, `setEnabled()` (consent gate), `captureWhen`
  sampling, a custom `onEvent` sink, and `events` / `clear`.
- Chains any existing `HttpOverrides`; never alters, blocks, or fails the app's
  own requests or responses.
