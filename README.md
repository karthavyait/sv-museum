# Viveka Anubhuti (Flutter) — Interactive Museum App

Offline-first museum prototype with Visitor and Admin modes. Admin content management is PIN-protected (PIN: 1201). Data is stored locally in SQLite with media copied into app storage for offline access.

## Getting Started

```bash
flutter pub get
flutter run
```

## Notes
- Visitor mode provides search, listing, and exhibit detail views.
- Admin mode allows CRUD operations with local media picking for images and audio.
- Architecture includes a stubbed remote data source to allow future server sync.
