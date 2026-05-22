import 'package:hijri/hijri_calendar.dart';

/// A [DateTime] subclass whose [year], [month], and [day] fields hold Hijri
/// (Umm al-Qura / Islamic calendar) values rather than Gregorian ones.
///
/// Designed to plug into Flutter's [CalendarDelegate] API: pass instances of
/// this class wherever a [DateTime] is expected by `showDatePicker`,
/// `CalendarDatePicker`, etc., together with [HijriCalendarDelegate].
///
/// Range comparisons ([isBefore], [isAfter], `==`) work correctly because the
/// Hijri values are passed through to the [DateTime] super constructor, which
/// preserves their numerical ordering. Note that [weekday],
/// [millisecondsSinceEpoch], and other [DateTime] members that interpret the
/// underlying value as Gregorian are not meaningful on a [HijriDateTime].
class HijriDateTime extends DateTime {
  /// Constructs a Hijri date from explicit components.
  HijriDateTime(super.year, [super.month = 1, super.day = 1]);

  /// Returns the current Hijri date (no time component).
  factory HijriDateTime.now() {
    final HijriCalendar h = HijriCalendar.now();
    return HijriDateTime(h.hYear, h.hMonth, h.hDay);
  }

  /// Constructs a [HijriDateTime] from a [HijriCalendar] instance.
  factory HijriDateTime.fromHijriCalendar(HijriCalendar h) {
    return HijriDateTime(h.hYear, h.hMonth, h.hDay);
  }

  /// Constructs a [HijriDateTime] by converting a Gregorian [DateTime].
  factory HijriDateTime.fromGregorian(DateTime gregorian) {
    final HijriCalendar h = HijriCalendar.fromDate(gregorian);
    return HijriDateTime(h.hYear, h.hMonth, h.hDay);
  }

  /// Returns this Hijri date as a [HijriCalendar] from the `hijri` package.
  HijriCalendar toHijriCalendar() {
    return HijriCalendar()
      ..hYear = year
      ..hMonth = month
      ..hDay = day;
  }

  /// Converts this Hijri date to its Gregorian [DateTime] equivalent.
  DateTime toGregorian() {
    return toHijriCalendar().hijriToGregorian(year, month, day);
  }
}
