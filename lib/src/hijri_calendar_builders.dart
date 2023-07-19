import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';

class HijriCalendarBuilders {
  const HijriCalendarBuilders({
    this.weekdayBuilder,
    this.dayBuilder,
  });

  /// Weekdays builder (day: Sun, Mon.., number: 0, 1..)
  final Widget Function(
      BuildContext context, String day, int number)? weekdayBuilder;

  /// Days builder (1, 2, ..)
  final Widget Function(
      BuildContext context, HijriCalendar day, bool isSelected)? dayBuilder;
}
