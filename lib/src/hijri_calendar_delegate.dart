import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';

import 'hijri_date_time.dart';

/// A [CalendarDelegate] for the Hijri (Umm al-Qura / Islamic) calendar.
///
/// Pass an instance to Flutter's [showDatePicker], [CalendarDatePicker],
/// [DatePickerDialog], or [InputDatePickerFormField] via their
/// `calendarDelegate` parameter, together with [HijriDateTime] values for
/// `initialDate`, `firstDate`, `lastDate`, and `currentDate`.
///
/// {@tool snippet}
/// ```dart
/// final HijriDateTime? picked = await showDatePicker(
///   context: context,
///   initialDate: HijriDateTime.now(),
///   firstDate: HijriDateTime(1440, 1, 1),
///   lastDate: HijriDateTime(1455, 12, 30),
///   calendarDelegate: const HijriCalendarDelegate(),
/// ) as HijriDateTime?;
/// ```
/// {@end-tool}
class HijriCalendarDelegate extends CalendarDelegate<HijriDateTime> {
  /// Creates a Hijri calendar delegate.
  ///
  /// [language] selects the Hijri locale used for month and weekday names.
  /// Must be one of the codes registered with the `hijri` package
  /// (built-in: `'en'`, `'ar'`, `'tr'`; consumers can register more via
  /// `HijriCalendar.addLocale`). If null, formatting uses whatever language
  /// is currently set on [HijriCalendar].
  const HijriCalendarDelegate({this.language});

  /// Hijri locale code used for Hijri month/weekday name formatting.
  final String? language;

  void _applyLanguage() {
    if (language != null) {
      try {
        HijriCalendar.setLocal(language!);
      } on ArgumentError {
        // Locale not registered with the hijri package; leave the current
        // setting in place rather than crashing the picker.
      }
    }
  }

  HijriCalendar _toHijriCalendar(HijriDateTime date) {
    return HijriCalendar()
      ..hYear = date.year
      ..hMonth = date.month
      ..hDay = date.day;
  }

  @override
  HijriDateTime now() => HijriDateTime.now();

  @override
  HijriDateTime dateOnly(HijriDateTime date) {
    return HijriDateTime(date.year, date.month, date.day);
  }

  @override
  int monthDelta(HijriDateTime startDate, HijriDateTime endDate) {
    return (endDate.year - startDate.year) * 12 +
        (endDate.month - startDate.month);
  }

  @override
  HijriDateTime addMonthsToMonthDate(
      HijriDateTime monthDate, int monthsToAdd) {
    final int totalMonths =
        monthDate.year * 12 + (monthDate.month - 1) + monthsToAdd;
    final int newYear = totalMonths ~/ 12;
    final int newMonth = (totalMonths % 12) + 1;
    return HijriDateTime(newYear, newMonth, 1);
  }

  @override
  HijriDateTime addDaysToDate(HijriDateTime date, int days) {
    final DateTime gregorian = date.toGregorian();
    final DateTime adjusted =
        DateTime(gregorian.year, gregorian.month, gregorian.day + days);
    return HijriDateTime.fromGregorian(adjusted);
  }

  @override
  int firstDayOffset(
      int year, int month, MaterialLocalizations localizations) {
    final DateTime gregorian = HijriCalendar().hijriToGregorian(year, month, 1);
    // DateTime.weekday: Monday = 1, Sunday = 7.
    final int weekdayFromMonday = gregorian.weekday - 1;
    // MaterialLocalizations.firstDayOfWeekIndex: Sunday = 0, Monday = 1, ...
    final int firstDayOfWeekFromMonday =
        (localizations.firstDayOfWeekIndex - 1) % 7;
    return (weekdayFromMonday - firstDayOfWeekFromMonday) % 7;
  }

  @override
  int getDaysInMonth(int year, int month) {
    return HijriCalendar().getDaysInMonth(year, month);
  }

  @override
  HijriDateTime getMonth(int year, int month) =>
      HijriDateTime(year, month, 1);

  @override
  HijriDateTime getDay(int year, int month, int day) =>
      HijriDateTime(year, month, day);

  @override
  String formatMonthYear(
      HijriDateTime date, MaterialLocalizations localizations) {
    _applyLanguage();
    return _toHijriCalendar(date).toFormat('MMMM yyyy');
  }

  @override
  String formatYear(int year, MaterialLocalizations localizations) {
    return year.toString();
  }

  @override
  String formatMediumDate(
      HijriDateTime date, MaterialLocalizations localizations) {
    _applyLanguage();
    return _toHijriCalendar(date).toFormat('DD, dd MM');
  }

  @override
  String formatShortMonthDay(
      HijriDateTime date, MaterialLocalizations localizations) {
    _applyLanguage();
    return _toHijriCalendar(date).toFormat('dd MM');
  }

  @override
  String formatShortDate(
      HijriDateTime date, MaterialLocalizations localizations) {
    _applyLanguage();
    return _toHijriCalendar(date).toFormat('dd MM yyyy');
  }

  @override
  String formatFullDate(
      HijriDateTime date, MaterialLocalizations localizations) {
    _applyLanguage();
    return _toHijriCalendar(date).toFormat('DDDD, dd MMMM yyyy');
  }

  @override
  String formatCompactDate(
      HijriDateTime date, MaterialLocalizations localizations) {
    // Delegate to MaterialLocalizations so the digit order (e.g. MM/DD/YYYY vs
    // DD/MM/YYYY) follows the active Material locale. The components are the
    // Hijri year/month/day exposed on the HijriDateTime.
    return localizations.formatCompactDate(date);
  }

  @override
  HijriDateTime? parseCompactDate(
      String? inputString, MaterialLocalizations localizations) {
    final DateTime? parsed = localizations.parseCompactDate(inputString);
    if (parsed == null) {
      return null;
    }
    if (parsed.month < 1 || parsed.month > 12) {
      return null;
    }
    if (parsed.day < 1 ||
        parsed.day > getDaysInMonth(parsed.year, parsed.month)) {
      return null;
    }
    return HijriDateTime(parsed.year, parsed.month, parsed.day);
  }

  @override
  String dateHelpText(MaterialLocalizations localizations) {
    return localizations.dateHelpText;
  }
}
