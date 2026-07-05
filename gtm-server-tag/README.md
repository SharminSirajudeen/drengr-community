# Drengr — GTM Server-Side Tag

Forwards every GA4-model event your server GTM container receives to Drengr,
so it shows up as a named event in your Drengr analysis layer. Zero client
SDK changes — this runs entirely in your server container.

## Install

1. In your server GTM container: **Templates → Tag Templates → New → Import**,
   pick `drengr.tpl`.
2. **Tags → New**, pick the Drengr tag type.
3. Paste your Drengr write key (`drengr_pk_...`, from the Drengr console under
   Settings → API Keys). Leave "Endpoint override" alone unless told otherwise.
4. Trigger: **All Events** (or scope it to whatever GA4 events you already
   route through this container).
5. Publish.

## What gets forwarded

Every event is reshaped into a Segment-spec `track` call and POSTed to
Drengr's ingest endpoint:

| GTM server event data | Drengr field |
|---|---|
| `event_name` | `event` (forwarded verbatim — Drengr normalizes event names on receipt) |
| `client_id` | `anonymousId` |
| `user_id` | `userId` (omitted if not set) |
| `timestamp` (if the event carries one) | `timestamp` (otherwise Drengr stamps receive-time) |
| `app_id` / `app_version` (Firebase/GA4-App events only) | `context.app.name` / `context.app.version` |
| `os_name` or `platform` / `os_version` | `context.os.name` / `context.os.version` |
| `device_model` or `device_brand` | `context.device.model` |
| everything else (`page_location`, `page_title`, `value`, `currency`, custom params, …) | `properties.*` |

## PII note

`user_data` — GA4's slot for hashed/raw email, phone, and address — is
**never forwarded**. It's dropped before the request body is built, full
stop. Keys prefixed `x-ga-` (GA4 client-internal plumbing) are dropped too.

## Permissions this tag requests

- `read_event_data` (any) — needed because we forward arbitrary/unknown
  event params, not a fixed field list.
- `send_http`, scoped to Drengr's ingest endpoint and `*.supabase.co` — no
  other destination is reachable from this tag.
- `logging`, scoped to debug/preview only — failures are logged to the GTM
  preview console, nothing is logged in production.

## Status

Hand-verified against the documented sandboxed-JS API surface
(`sendHttpRequest`, `getAllEventData`, `JSON`, `logToConsole`) and the
`.tpl` permission/parameter schema — not yet run against a live server GTM
container. Test before production use.
