import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';

class HijriCalendarBuilders {
  const HijriCalendarBuilders({
    this.weekdayBuilder,
    this.dayBuilder,
  });

  /// Weekdays builder (Sat, Sun, ..)
  final Widget Function(BuildContext context, String day)? weekdayBuilder;

  /// Days builder (1, 2, ..)
  final Widget Function(
      BuildContext context, HijriCalendar day, bool isSelected)? dayBuilder;
}
