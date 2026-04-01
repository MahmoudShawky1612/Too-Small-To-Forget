# Too Small To Forget

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
# ScreenShots
![Screenshot_2026-04-01-21-04-27-66_8ab65562ba563704112171ec5a79fc71](https://github.com/user-attachments/assets/4125e5f0-0eec-44f7-bda3-28d108c2683b)![Screenshot_2026-04-01-21-04-30-36_8ab65562ba563704112171ec5a79fc71](https://github.com/user-attachments/assets/07f123ce-f0a2-4aea-8427-3338b85117e2)
![Screenshot_2026-04-01-21-04-51-03_8ab65562ba563704112171ec5a79fc71](https://github.com/user-attachments/assets/2b934824-bdb5-4187-ade6-f9724d895648)
![Screenshot_2026-04-01-21-04-59-82_8ab65562ba563704112171ec5a79fc71](https://github.com/user-attachments/assets/a1d45056-3235-413d-9e15-cd758c51edf4)


---

## Getting started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel recommended)
- Xcode (for iOS simulator/device) and/or Android Studio / SDK (for Android emulator/device)
- A device or emulator with camera/gallery if you want to test photos

### Install

```bash
git clone https://github.com/MahmoudShawky1612/Too-Small-To-Forget
cd toosmalltoforget
flutter pub get
```

### Run

```bash
flutter run
```

Pick a device with `flutter devices`.


## License

Specify your license here (e.g. MIT, proprietary). This template does not include a license file by default.

---

## Acknowledgments

Built with Flutter and the open-source packages listed in [pubspec.yaml](pubspec.yaml). UI theme uses warm dark surfaces and terracotta accents (`lib/theme/app_colors.dart`).
