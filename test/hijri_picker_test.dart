import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:hijri_picker/hijri_picker.dart';

void main() {
  group('HijriDateTime', () {
    test('exposes Hijri components via DateTime fields', () {
      final d = HijriDateTime(1447, 9, 27);
      expect(d.year, 1447);
      expect(d.month, 9);
      expect(d.day, 27);
    });

    test('now() returns a date that matches HijriCalendar.now()', () {
      final actual = HijriDateTime.now();
      final expected = HijriCalendar.now();
      expect(actual.year, expected.hYear);
      expect(actual.month, expected.hMonth);
      expect(actual.day, expected.hDay);
    });

    test('round-trips through HijriCalendar', () {
      final original = HijriDateTime(1445, 6, 15);
      final viaCalendar = HijriDateTime.fromHijriCalendar(
        original.toHijriCalendar(),
      );
      expect(viaCalendar.year, original.year);
      expect(viaCalendar.month, original.month);
      expect(viaCalendar.day, original.day);
    });

    test('round-trips through Gregorian', () {
      final original = HijriDateTime(1445, 6, 15);
      final viaGregorian = HijriDateTime.fromGregorian(original.toGregorian());
      expect(viaGregorian.year, original.year);
      expect(viaGregorian.month, original.month);
      expect(viaGregorian.day, original.day);
    });

    test('preserves Hijri ordering via isBefore/isAfter', () {
      final earlier = HijriDateTime(1446, 12, 30);
      final later = HijriDateTime(1447, 1, 1);
      expect(earlier.isBefore(later), isTrue);
      expect(later.isAfter(earlier), isTrue);
      expect(earlier.isBefore(earlier), isFalse);
    });
  });

  group('HijriCalendarDelegate', () {
    const delegate = HijriCalendarDelegate(language: 'en');

    test('dateOnly preserves Hijri components', () {
      final stripped = delegate.dateOnly(HijriDateTime(1447, 5, 12));
      expect(stripped.year, 1447);
      expect(stripped.month, 5);
      expect(stripped.day, 12);
    });

    test('monthDelta is pure year/month arithmetic', () {
      expect(
        delegate.monthDelta(
          HijriDateTime(1447, 1, 1),
          HijriDateTime(1448, 6, 1),
        ),
        17,
      );
      expect(
        delegate.monthDelta(
          HijriDateTime(1447, 6, 1),
          HijriDateTime(1447, 6, 1),
        ),
        0,
      );
      expect(
        delegate.monthDelta(
          HijriDateTime(1448, 1, 1),
          HijriDateTime(1447, 12, 1),
        ),
        -1,
      );
    });

    test('addMonthsToMonthDate handles forward and backward wrap-around', () {
      final result = delegate.addMonthsToMonthDate(
        HijriDateTime(1447, 11, 1),
        15,
      );
      expect(result.year, 1449);
      expect(result.month, 2);
      expect(result.day, 1);

      final back = delegate.addMonthsToMonthDate(
        HijriDateTime(1447, 2, 1),
        -3,
      );
      expect(back.year, 1446);
      expect(back.month, 11);
      expect(back.day, 1);
    });

    test('addDaysToDate respects Hijri month lengths', () {
      // Add 30 days starting from 1 Ramadan 1446: should cross into Shawwal.
      final result =
          delegate.addDaysToDate(HijriDateTime(1446, 9, 1), 30);
      expect(result.month, isNot(9));
      // Specifically should land in month 10 (Shawwal) within the same year.
      expect(result.year, 1446);
      expect(result.month, 10);
    });

    test('getDaysInMonth returns a Hijri-valid count (29 or 30)', () {
      for (int m = 1; m <= 12; m++) {
        final days = delegate.getDaysInMonth(1446, m);
        expect(days, anyOf(29, 30),
            reason: 'month $m of 1446 returned $days');
      }
    });

    test('getMonth and getDay return HijriDateTime instances', () {
      final month = delegate.getMonth(1447, 3);
      expect(month, isA<HijriDateTime>());
      expect(month.year, 1447);
      expect(month.month, 3);
      expect(month.day, 1);

      final day = delegate.getDay(1447, 3, 17);
      expect(day, isA<HijriDateTime>());
      expect(day.day, 17);
    });

    testWidgets('firstDayOffset returns a value in 0-6',
        (WidgetTester tester) async {
      late MaterialLocalizations loc;
      await tester.pumpWidget(
        MaterialApp(
          supportedLocales: const [Locale('en')],
          home: Builder(builder: (ctx) {
            loc = MaterialLocalizations.of(ctx);
            return const Placeholder();
          }),
        ),
      );

      for (int m = 1; m <= 12; m++) {
        final offset = delegate.firstDayOffset(1447, m, loc);
        expect(offset, inInclusiveRange(0, 6),
            reason: 'month $m of 1447 returned offset $offset');
      }
    });

    testWidgets('parseCompactDate rejects invalid Hijri days',
        (WidgetTester tester) async {
      late MaterialLocalizations loc;
      await tester.pumpWidget(
        MaterialApp(
          supportedLocales: const [Locale('en')],
          home: Builder(builder: (ctx) {
            loc = MaterialLocalizations.of(ctx);
            return const Placeholder();
          }),
        ),
      );

      // Garbage input.
      expect(delegate.parseCompactDate('garbage', loc), isNull);
      // Day 31 — never valid in Hijri.
      expect(delegate.parseCompactDate('1/31/1447', loc), isNull);
      // Month 13.
      expect(delegate.parseCompactDate('13/1/1447', loc), isNull);
      // Valid date (en_US format is MM/DD/YYYY).
      final valid = delegate.parseCompactDate('1/15/1447', loc);
      expect(valid, isNotNull);
      expect(valid!.year, 1447);
      expect(valid.month, 1);
      expect(valid.day, 15);
    });

    testWidgets('formatMonthYear uses Hijri month names',
        (WidgetTester tester) async {
      late MaterialLocalizations loc;
      await tester.pumpWidget(
        MaterialApp(
          supportedLocales: const [Locale('en')],
          home: Builder(builder: (ctx) {
            loc = MaterialLocalizations.of(ctx);
            return const Placeholder();
          }),
        ),
      );

      final formatted =
          delegate.formatMonthYear(HijriDateTime(1447, 9, 1), loc);
      expect(formatted, contains('Ramadan'));
      expect(formatted, contains('1447'));
    });
  });

  group('showHijriDatePicker', () {
    testWidgets('returns a HijriDateTime when OK is tapped',
        (WidgetTester tester) async {
      HijriDateTime? picked;
      final initial = HijriDateTime(1447, 9, 15);

      await tester.pumpWidget(
        MaterialApp(
          supportedLocales: const [Locale('en')],
          home: Builder(
            builder: (ctx) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () async {
                    picked = await showHijriDatePicker(
                      context: ctx,
                      initialDate: initial,
                      firstDate: HijriDateTime(1446, 1, 1),
                      lastDate: HijriDateTime(1450, 12, 29),
                      hijriLanguage: 'en',
                    );
                  },
                  child: const Text('open'),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      // The dialog header should contain the initial Hijri month.
      expect(find.textContaining('Ramadan'), findsWidgets);

      // Tap OK without changing the selection.
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(picked, isNotNull);
      expect(picked!.year, initial.year);
      expect(picked!.month, initial.month);
      expect(picked!.day, initial.day);
    });

    testWidgets('returns null when Cancel is tapped',
        (WidgetTester tester) async {
      HijriDateTime? picked = HijriDateTime(1447, 1, 1); // sentinel non-null

      await tester.pumpWidget(
        MaterialApp(
          supportedLocales: const [Locale('en')],
          home: Builder(
            builder: (ctx) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () async {
                    picked = await showHijriDatePicker(
                      context: ctx,
                      initialDate: HijriDateTime(1447, 9, 15),
                      firstDate: HijriDateTime(1446, 1, 1),
                      lastDate: HijriDateTime(1450, 12, 29),
                    );
                  },
                  child: const Text('open'),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(picked, isNull);
    });
  });
}
