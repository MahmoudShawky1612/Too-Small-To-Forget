# Too Small To Forget

A Flutter app for capturing and organizing small moments you do not want to lose: memories with optional photos, categories, search, and scheduled local reminders on **iOS** and **Android**. Data stays on the device in a local SQLite database.

---

## Screenshots

Add your own images (recommended folder: `docs/screenshots/`). Replace the paths below or drop files with matching names.

| | |
|:--:|:--:|
| ![Home — memory list, search, category chips](docs/screenshots/01-home.png) | ![New memory — title, details, date, reminder, category, photo](docs/screenshots/02-add-memory.png) |
| *Home: list, search, filters* | *New memory form* |

| | |
|:--:|:--:|
| ![Memory detail — bottom sheet](docs/screenshots/03-memory-detail.png) | ![Reminder notification](docs/screenshots/04-notification.png) |
| *Memory detail (tap a card)* | *Reminder notification (OS)* |

**Suggested screenshot checklist**

1. Home screen with at least one memory (with and without photo).
2. Add memory screen with a reminder set (shows date + time + “Remove reminder”).
3. Memory detail bottom sheet (photo, dates, category, full text).
4. Category chips (optional: long-press delete confirmation).
5. Empty state (no memories yet).
6. OS notification for a due reminder (Android and/or iOS).

---

## Overview

**Too Small To Forget** lets you:

- Save a **title**, **details**, **when it happened** (memory date), optional **reminder** (date + time for a local notification), optional **category**, and optional **photo** (camera or gallery).
- Browse memories on a **home** screen with **search** and **category** filters.
- Open a **detail** view (tap a card) for full information.
- **Swipe** a card away to delete (with confirmation).
- **Long-press** a category chip to **delete** that category (memories remain; they are uncategorized).

Reminders use the device timezone, are rescheduled when the app starts after install/upgrade, and are cancelled when a memory is deleted or a reminder is removed.

---

## Features

### Memories

- **Create**: FAB → form with validation on title.
- **Read**: Scrollable list with relative time on the card, category pill, thumbnail if a photo exists, reminder icon when a reminder exists.
- **Detail**: Tap a card → draggable bottom sheet with title, optional image, memory date, reminder (if any), category, and full details text.
- **Delete**: Swipe card left → confirm → memory removed and any scheduled notification cancelled.

### Categories

- **Add**: `+` chip next to category row → name in dialog.
- **Filter**: Tap a category chip (or “All”) to filter the list; search works with the active filter.
- **Delete**: **Long-press** a category chip → confirm → category removed; memories that used it keep their row in the database with `categoryId` cleared (no data loss).

### Reminders

- Set when **creating** a memory (date + time pickers).  
- **Remove before save**: “Remove reminder” under the reminder row on the add screen.  
- **Remove after save**: “Remove reminder” in the memory detail sheet → confirm → DB updated, notification cancelled.

### Notifications

- Local notifications via `flutter_local_notifications` (exact schedule mode on Android where configured).
- Permission prompts on first launch (iOS/Android); Android 13+ notification permission and **exact alarms** where required for precise timing.
- On startup, future reminders from the database are **rescheduled** so they survive app updates and device restarts (subject to OS battery/optimization policies).

### Search

- Filters memories by title or details text (case-insensitive `LIKE` in SQLite).

---

## Tech stack

| Area | Choice |
|------|--------|
| Framework | [Flutter](https://flutter.dev) (Dart SDK ^3.11.3) |
| UI scaling | [flutter_screenutil](https://pub.dev/packages/flutter_screenutil) (design size 375×812) |
| Local DB | [sqflite](https://pub.dev/packages/sqflite) |
| Paths | [path_provider](https://pub.dev/packages/path_provider) |
| Photos | [image_picker](https://pub.dev/packages/image_picker) |
| Notifications | [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) |
| Timezones | [timezone](https://pub.dev/packages/timezone) + [flutter_timezone](https://pub.dev/packages/flutter_timezone) (device zone for scheduling) |

---

## Project structure

```
lib/
├── main.dart                 # App entry: init, notifications, reschedule, theme, home
├── models/
│   ├── memory.dart           # Memory entity + map serialization
│   └── category.dart         # Category entity
├── screens/
│   ├── home_screen.dart      # List, search, chips, FAB, detail sheet, delete flows
│   └── add_memory_screen.dart
├── widgets/
│   └── memory_card.dart      # Card UI, dismissible delete, tap
├── helpers/
│   ├── home_screen_helper.dart
│   └── add_memory_helper.dart
├── services/
│   ├── database_helper.dart  # SQLite singleton, schema, CRUD
│   └── notification_service.dart
└── theme/
    ├── app_colors.dart
    └── app_theme.dart
```

**Pattern**: Screens own `StatefulWidget` state; helpers hold shared logic and call `refresh` / `setState` patterns to sync UI. `DatabaseHelper` and `NotificationService` are singleton-style facades.

---

## Data model

### SQLite (`memories.db`)

**`categories`**

| Column | Type   | Notes        |
|--------|--------|--------------|
| `id`   | INTEGER PK AUTOINCREMENT | |
| `name` | TEXT NOT NULL UNIQUE | |

**`memories`**

| Column       | Type    | Notes |
|--------------|---------|--------|
| `id`         | INTEGER PK AUTOINCREMENT | |
| `title`      | TEXT NOT NULL | |
| `details`    | TEXT NOT NULL | |
| `date`       | TEXT NOT NULL | ISO 8601 |
| `categoryId` | INTEGER | Nullable FK |
| `reminder`   | TEXT | Nullable ISO 8601 |
| `photoPath`  | TEXT | Nullable app documents path |

**Schema version**: `2` (see `database_helper.dart` `_onCreate` / `_onUpgrade`).

### Notification IDs

Scheduled notifications use the memory’s **`id`** as the notification `id` so scheduling, cancelling, and rescheduling stay aligned.

---

## Getting started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel recommended)
- Xcode (for iOS simulator/device) and/or Android Studio / SDK (for Android emulator/device)
- A device or emulator with camera/gallery if you want to test photos

### Install

```bash
git clone <your-repo-url>
cd toosmalltoforget
flutter pub get
```

### Run

```bash
flutter run
```

Pick a device with `flutter devices`.

### Analyze & tests

```bash
dart analyze
flutter test
```

---

## Building for release

### Android

```bash
flutter build apk   # or appbundle for Play Store
```

Review `android/app/build.gradle.kts` (application ID, signing for release). The manifest includes permissions for camera, storage (as applicable), exact alarms, boot completed, and receivers required by `flutter_local_notifications` for scheduled notifications.

### iOS

```bash
flutter build ios
```

Open `ios/Runner.xcworkspace` in Xcode for signing, capabilities, and App Store upload. Ensure notification permissions are accepted in **Settings** on device if reminders do not appear.

---

## Platform notes

### Android

- **Notification permission** (Android 13+): requested at startup via the plugin.
- **Exact alarms** (Android 12+ / 14+): requested when needed for precise reminder times; users may need to allow alarms in system settings.
- **Receivers** in `AndroidManifest.xml`: `ScheduledNotificationReceiver`, `ScheduledNotificationBootReceiver` (plus `RECEIVE_BOOT_COMPLETED`) so scheduled notifications can fire and be restored after reboot/update.

### iOS

- Local notifications use the standard permission flow; the user must allow alerts for reminders to show.
- `Info.plist` includes usage strings for camera and photo library (required for `image_picker`).

### Photos

- Images are copied into the app documents directory and the path is stored in SQLite. If a file is missing, the UI shows a broken-image placeholder where applicable.

---

## App branding & icons

The project uses [flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons) (see `pubspec.yaml`) with `assets/icon/app_icon2.png` for Android and iOS launcher icons. Regenerate icons after changing the source asset:

```bash
dart run flutter_launcher_icons
```

---

## Troubleshooting

| Issue | What to check |
|-------|----------------|
| Reminders never fire | OS notification permission; Android “Alarms & reminders” / exact alarm; battery optimization not killing the app; reminder time in the future |
| Reminder shows wrong time | Device timezone; app uses `flutter_timezone` + `timezone` package for scheduling |
| Category deleted but memories “missing” | Memories are filtered by category; switch to **All** or search |
| Photo not loading | File was deleted outside the app; path in DB is invalid |

---

## License

Specify your license here (e.g. MIT, proprietary). This template does not include a license file by default.

---

## Acknowledgments

Built with Flutter and the open-source packages listed in [pubspec.yaml](pubspec.yaml). UI theme uses warm dark surfaces and terracotta accents (`lib/theme/app_colors.dart`).
