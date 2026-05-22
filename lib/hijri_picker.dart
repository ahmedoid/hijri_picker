/// Hijri (Umm al-Qura / Islamic calendar) date picker for Flutter.
///
/// This package plugs into Flutter's built-in date picker UI via
/// [HijriCalendarDelegate] (a [CalendarDelegate]). Use either Flutter's
/// `showDatePicker` directly with `calendarDelegate: const HijriCalendarDelegate()`,
/// or the convenience [showHijriDatePicker] function exported from this library
/// for a typed `HijriDateTime?` return value.
library hijri_picker;

import 'package:flutter/material.dart';

import 'src/hijri_calendar_delegate.dart';
import 'src/hijri_date_time.dart';

export 'src/hijri_calendar_delegate.dart';
export 'src/hijri_date_time.dart';

/// Shows a Hijri date picker dialog.
///
/// Mirrors Flutter's [showDatePicker] but is typed for [HijriDateTime] and
/// installs [HijriCalendarDelegate] automatically. See [showDatePicker] for
/// detailed parameter documentation; the behaviour is identical except that
/// every [DateTime] is interpreted as a Hijri date.
///
/// [hijriLanguage] selects the locale used for Hijri month and weekday names
/// in the picker header (`'en'`, `'ar'`, `'tr'`, or any locale registered via
/// `HijriCalendar.addLocale`). When null, formatting falls back to whatever
/// `HijriCalendar.language` is currently set to.
Future<HijriDateTime?> showHijriDatePicker({
  required BuildContext context,
  HijriDateTime? initialDate,
  required HijriDateTime firstDate,
  required HijriDateTime lastDate,
  HijriDateTime? currentDate,
  DatePickerEntryMode initialEntryMode = DatePickerEntryMode.calendar,
  bool Function(HijriDateTime day)? selectableDayPredicate,
  String? helpText,
  String? cancelText,
  String? confirmText,
  Locale? locale,
  bool barrierDismissible = true,
  Color? barrierColor,
  String? barrierLabel,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
  TextDirection? textDirection,
  TransitionBuilder? builder,
  DatePickerMode initialDatePickerMode = DatePickerMode.day,
  String? errorFormatText,
  String? errorInvalidText,
  String? fieldHintText,
  String? fieldLabelText,
  TextInputType? keyboardType,
  Offset? anchorPoint,
  ValueChanged<DatePickerEntryMode>? onDatePickerModeChange,
  Icon? switchToInputEntryModeIcon,
  Icon? switchToCalendarEntryModeIcon,
  String? hijriLanguage,
}) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: lastDate,
    currentDate: currentDate,
    initialEntryMode: initialEntryMode,
    selectableDayPredicate: selectableDayPredicate == null
        ? null
        : (DateTime date) => selectableDayPredicate(date as HijriDateTime),
    helpText: helpText,
    cancelText: cancelText,
    confirmText: confirmText,
    locale: locale,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor,
    barrierLabel: barrierLabel,
    useRootNavigator: useRootNavigator,
    routeSettings: routeSettings,
    textDirection: textDirection,
    builder: builder,
    initialDatePickerMode: initialDatePickerMode,
    errorFormatText: errorFormatText,
    errorInvalidText: errorInvalidText,
    fieldHintText: fieldHintText,
    fieldLabelText: fieldLabelText,
    keyboardType: keyboardType,
    anchorPoint: anchorPoint,
    onDatePickerModeChange: onDatePickerModeChange,
    switchToInputEntryModeIcon: switchToInputEntryModeIcon,
    switchToCalendarEntryModeIcon: switchToCalendarEntryModeIcon,
    calendarDelegate: HijriCalendarDelegate(language: hijriLanguage),
  );
  return picked as HijriDateTime?;
}
