# Changelog

All notable changes to **Drengr** — the MCP server that gives AI agents eyes and
hands on mobile devices (Android + iOS).

The format is based on [Keep a Changelog](https://keepachangelog.com/).

## 0.7.14 — 2026-06-05

### Fixed
- A simulator left locked by a previous, abandoned session is now recovered
  automatically, with no manual intervention required.

## 0.7.13 — 2026-06-05

### Fixed
- The on-device test runner self-heals if it stops responding mid-session,
  re-establishing control instead of failing every subsequent action.
- The runner is now released promptly when the host application exits
  unexpectedly, preventing it from blocking the next session.

## 0.7.12 — 2026-06-05

### Fixed
- When another Drengr instance is already driving a simulator, the error is now
  clear and actionable rather than a silent cooldown.

## 0.7.10 — 2026-06-05

### Added
- Per-step performance timing, so slow steps can be measured and optimized.

## 0.7.9 — 2026-06-05

### Added
- iOS reads the foreground application's accessibility tree, restoring
  element-based actions on native apps.

### Changed
- Screenshots are roughly 5× smaller (downscaled JPEG) for faster transfers and
  lower token cost, with no loss of fidelity for the agent.
- Path drawing is smoother and more reliable across long gestures.

## 0.7.8 — 2026-06-05

### Added
- Coordinate tap, swipe, and long-press — control any screen by vision and
  pixel-touch, including framework-less interfaces (Flutter, games, in-app web,
  and HTML canvas) that expose no accessibility tree. A coordinate-grid overlay
  (`drengr_look(format='grid')`) helps the agent aim precisely.

## 0.7.7 — 2026-06-05

### Added
- Android: optional windowed emulator mode (`show_window`) to watch automation
  run live.

## 0.7.6 — 2026-06-05

### Added
- `set_orientation` to rotate the iOS device between portrait and landscape.

## 0.7.5 — 2026-06-05

### Added
- Reliable text input and Spotlight search on iOS.

### Fixed
- The runner survives transient failures instead of ending the session.

## 0.7.4 — 2026-06-04

### Added
- `grant_permission` to pre-authorize system permissions, so consent dialogs
  never interrupt an automated run.

## 0.7.3 — 2026-06-04

### Changed
- All device actions now perform real operations; fixed tapping of visible
  elements.

## 0.7.2 — 2026-06-03

### Added
- Expanded `drengr_do` action coverage and deeper scroll-to-find.

## 0.7.0 — 2026-06-03

### Added
- Granular driver diagnostics with precise error codes.

### Fixed
- Automatic cleanup of stale ("zombie") runners.

## 0.6.0 — 2026-05-26

### Changed
- New iOS driver running fully headless inside CoreSimulator via XCTest,
  replacing the previous WebDriverAgent-based approach.

## 0.4.1 — 2026-05-12

### Fixed
- Resolved an iOS crash loop and improved error capture.

## 0.2.1 — 2026-04-02

### Added
- Full iOS gesture support: tap, swipe, pinch-zoom, and long-press.

## 0.1.8 — 2026-03-19

### Added
- Ten additional MCP tools, binary hardening, and automatic updates.

## 0.1.5 — 2026-03-15

### Added
- Getting-started guide, an uninstall command, and automatic path detection.

## 0.1.1 — 2026-03-15

### Added
- Public landing page, documentation, legal pages, and GPG-signed release
  artifacts.

## 0.1.0 — 2026-03-12

### Added
- Initial public release: an MCP server giving AI agents eyes and hands on
  Android and iOS — screenshots, UI inspection, and actions (tap, type, swipe,
  and more) over ADB and `simctl`.
