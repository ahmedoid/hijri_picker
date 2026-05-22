# Changelog
## 5.0.0

Breaking rewrite. The package now plugs into Flutter's built-in date picker
UI via the `CalendarDelegate` API (introduced in Flutter 3.32) instead of
shipping its own widgets. Result: Material 3 styling, input-text mode,
semantics, theming via `DatePickerThemeData`, and future Flutter date-picker
improvements come for free.

### Requirements

- Flutter `>=3.32.0`
- Dart `^3.8.0`

### Added

- `HijriDateTime` — a `DateTime` subclass whose `year`/`month`/`day` hold
  Hijri values, with `.toHijriCalendar()` / `.toGregorian()` interop.
- `HijriCalendarDelegate` — a `CalendarDelegate<HijriDateTime>` that plugs
  into any Flutter date-picker entry point.
- `showHijriDatePicker(...)` rewritten as a thin, typed wrapper around
  Flutter's `showDatePicker` — full parameter parity, including
  `helpText`, `cancelText`, `confirmText`, `initialEntryMode`,
  `errorFormatText`, `errorInvalidText`, `fieldHintText`, `fieldLabelText`,
  `keyboardType`, `anchorPoint`, `onDatePickerModeChange`,
  `switchToInputEntryModeIcon`, `switchToCalendarEntryModeIcon`,
  `barrierColor`/`barrierLabel`/`barrierDismissible`, `useRootNavigator`,
  `routeSettings`, `textDirection`, `builder`.
- New `hijriLanguage` parameter on `showHijriDatePicker` for selecting the
  Hijri month/weekday-name locale.

### Removed (breaking)

- `HijriMonthPicker`, `HijriDayPicker`, `HijriYearPicker`, `HijriDatePickerDialog`
  widgets — Flutter's `CalendarDatePicker` / `DatePickerDialog` are used
  directly with a delegate.
- `HijriCalendarBuilders` (custom day/weekday widget builders) —
  customization now flows through `DatePickerThemeData`.
- The `HijriCalendar`-based `showHijriDatePicker` signature; pass
  `HijriDateTime` values now.

### Migration

See the README "Migration from 4.x" section for a side-by-side table.

## 4.0.0

- Upgrade to Dart 3.

## 3.1.0

- Added custom builders for days and weekdays in `HijriMonthPicker()`

- Added custom builders for days and weekdays in `HijriMonthPicker()`

## 3.0.0

- Migrated to null safety

## 2.0.0

- Update hijri package to last

## 1.0.3

- Update flutter to last
- Add example for a widget usages

## 1.0.1

- Edit text size for header
- Update Hijri Package to 1.0.1

## 1.0.0

- Support Local
- Update Hijri Package

## 0.0.1

- Initial version
