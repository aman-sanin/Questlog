# Quest

---

## The core

| Layer         | Choice                                 | Why                                                                         |
| ------------- | -------------------------------------- | --------------------------------------------------------------------------- |
| Platform      | Android only                           | Your call, round 2                                                          |
| Framework     | Flutter (stable)                       | Your comfort + best size-to-smoothness ratio                                |
| State + DI    | **Riverpod**                           | Drift `watch()` → providers → reactive UI; no manual refresh anywhere       |
| Persistence   | **Drift** + sqlite3_flutter_libs       | Reactive queries, type converters (rule JSON ↔ sealed classes), migrations  |
| Navigation    | **go_router**                          | 3 tabs, sheets, `questlog://today` deep link                                |
| Notifications | flutter_local_notifications + timezone | Digest + reminders, reconciler model                                        |
| Home widget   | home_widget                            | Snapshot push + deep link                                                   |
| Time          | **clock**                              | Injected clock — the thing that makes streak/settlement tests deterministic |
| IDs           | uuid                                   | TEXT UUIDs — chosen so the sync door stays open                             |
| Icons         | material_symbols_icons (Outlined)      | Tree-shaken via const refs, FILL axis for toggles                           |
| Files/share   | share_plus, file_picker                | Recap PNG share, backup JSON import/export                                  |
| Utils         | path_provider, collection, intl        | intl = `DateFormat` for "Thu, Jun 12"                                       |

**~14 runtime packages.** Deliberately small — every one earns its line.

## pubspec sketch

```yaml
dependencies:
  flutter_riverpod:
  drift:
  sqlite3_flutter_libs:
  go_router:
  flutter_local_notifications:
  timezone:
  home_widget:
  clock:
  uuid:
  material_symbols_icons:
  share_plus:
  file_picker:
  path_provider:
  collection:
  intl: # date display formatting only
  audioplayers: # ← arch-doc omission: the 3 opt-in OGGs need a player

dev_dependencies:
  flutter_test:
  integration_test: # onboarding → L2 ceremony flow
  drift_dev:
  build_runner:
  flutter_launcher_icons: # rasterizes the 6 crest sigils for the adaptive icon
```

(Versions = latest stable at scaffold time. Two honest corrections to the architecture doc's list surfaced here: `intl` was implied but never listed, and the sounds had no player.)

## Fonts & assets

| Asset                     | Source                          | Size          |
| ------------------------- | ------------------------------- | ------------- |
| Space Grotesk (variable)  | OFL                             | ~150KB subset |
| Geist (variable)          | Vercel GitHub, bundled manually | ~200KB        |
| JetBrains Mono (variable) | OFL                             | ~150KB        |
| Material Symbols Outlined | tree-shaken subset              | ~100KB        |
| 6 sigil launcher PNGs     | generated from Path code        | ~50KB         |
| 3 OGG sounds              | opt-in                          | ~30KB         |

**No `google_fonts` package** — everything's bundled, zero runtime fetching. Sigils, burst, watermarks: code (Path painters). Raster assets in the UI: none.

## Android posture

- **No INTERNET permission** — the strongest possible "fully local" claim; the missing permission _is_ the privacy policy
- `allowBackup = true` — OS-level Drive backup of the SQLite file (the "survives reinstall on this device" promise)
- POST_NOTIFICATIONS (13+) · SCHEDULE_EXACT_ALARM (12+, inexact fallback)
- minSdk: Flutter's default works — nothing in the stack forces it higher

## Deliberately absent

No backend, no Firebase, no analytics, no crash reporting, no ML runtime, no Lottie/Rive, no google_fonts, no date-time library (dates are local `YYYY-MM-DD` strings by design — intl only _formats_ them), no network. If sync ever happens it's a v2+ PocketBase/Supabase bolt-on, and the UUID keys + append-only logs were chosen specifically to keep that door openable.

## Size budget

~12–16MB engine + ~2MB plugins + ~1MB assets ≈ **18–20MB APK** against the 70MB ceiling. CI gate: `flutter build appbundle --analyze-size` — warn at 25MB, fail at 35MB.

---

So: a Flutter app that is, structurally, _four moving parts_ — a Drift database, three pure-Dart engines, a Riverpod graph, and a theme. Everything else is screens. Ready to scaffold whenever you are — theme/token code and the data layer are step one, per the build order.
