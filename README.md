# circadia

A Flutter app that turns a flight into a personal circadian plan — light and
sleep windows, in-flight hydration and movement reminders, a layover and
time-zone planner, and an arrival-readiness checklist. The planning tools work
fully offline.

## Getting started

```
flutter pub get
flutter run --dart-define-from-file=dart_defines.json
```

Configuration values (backend URL, anon key and integration ids) are supplied
through `dart_defines.json` at build time and are never committed.
