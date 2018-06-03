import 'package:example/picker/hijri/umm_alqura_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:math' as math;



const int daysPerWeek = 7;

/// Displays the days of a given month and allows choosing a day.
///
/// The days are arranged in a rectangular grid with one column for each day of
/// the week.
///
/// The day picker widget is rarely used directly. Instead, consider using
/// [showDatePicker], which creates a date picker dialog.
///
/// See also:
///
///  * [showDatePicker].
///  * <https://material.google.com/components/pickers.html#pickers-date-pickers>
///
///

const double _kDayPickerRowHeight = 42.0;
const int _kMaxDayPickerRowCount = 6; // A 31 day month that starts on Saturday.

class _hDayPickerGridDelegate extends SliverGridDelegate {
  const _hDayPickerGridDelegate();

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    const int columnCount = daysPerWeek;
    final double tileWidth = constraints.crossAxisExtent / columnCount;
    final double tileHeight = math.min(_kDayPickerRowHeight,
        constraints.viewportMainAxisExtent / (_kMaxDayPickerRowCount + 1));
    return new SliverGridRegularTileLayout(
      crossAxisCount: columnCount,
      mainAxisStride: tileHeight,
      crossAxisStride: tileWidth,
      childMainAxisExtent: tileHeight,
      childCrossAxisExtent: tileWidth,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(_hDayPickerGridDelegate oldDelegate) => false;
}

/// Signature for predicating dates for enabled date selections.
///
/// See [showDatePicker].
typedef bool SelectableDayPredicate(ummAlquraCalendar day);

const _hDayPickerGridDelegate _kDayPickerGridDelegate =
    const _hDayPickerGridDelegate();

class hDayPicker extends StatelessWidget {
  /// Creates a day picker.
  ///
  /// Rarely used directly. Instead, typically used as part of a [MonthPicker].
  hDayPicker({
    Key key,
    @required this.selectedDate,
    @required this.currentDate,
    @required this.onChanged,
    @required this.firstDate,
    @required this.lastDate,
    this.selectableDayPredicate,
    this.displayedMonth,
  })  : assert(selectedDate != null),
        assert(onChanged != null),
        assert(
            !firstDate.isAfter(lastDate.hYear, lastDate.hMonth, lastDate.hDay)),
        assert(selectedDate.isAfter(
                firstDate.hYear, firstDate.hMonth, firstDate.hDay) ||
            selectedDate.isAtSameMomentAs(
                firstDate.hYear, firstDate.hMonth, firstDate.hDay)),
        super(key: key);

  /// The currently selected date.
  ///
  /// This date is highlighted in the picker.
  final ummAlquraCalendar selectedDate;

  /// The current date at the time the picker is displayed.
  final ummAlquraCalendar currentDate;

  /// Called when the user picks a day.
  final ValueChanged<ummAlquraCalendar> onChanged;

  /// The earliest date the user is permitted to pick.
  final ummAlquraCalendar firstDate;

  /// The latest date the user is permitted to pick.
  final ummAlquraCalendar lastDate;

  /// The month whose days are displayed by this picker.
  final ummAlquraCalendar displayedMonth;

  /// Optional user supplied predicate function to customize selectable days.
  final SelectableDayPredicate selectableDayPredicate;

  /// Builds widgets showing abbreviated days of week. The first widget in the
  /// returned list corresponds to the first day of week for the current locale.
  ///
  /// Examples:
  ///
  /// ```
  /// ┌ Sunday is the first day of week in the US (en_US)
  /// |
  /// S M T W T F S  <-- the returned list contains these widgets
  /// _ _ _ _ _ 1 2
  /// 3 4 5 6 7 8 9
  ///
  /// ┌ But it's Monday in the UK (en_GB)
  /// |
  /// M T W T F S S  <-- the returned list contains these widgets
  /// _ _ _ _ 1 2 3
  /// 4 5 6 7 8 9 10
  /// ```
  List<Widget> _getDayHeaders(
      TextStyle headerStyle, MaterialLocalizations localizations) {
    final List<Widget> result = <Widget>[];
    for (int i = localizations.firstDayOfWeekIndex; true; i = (i + 1) % 7) {
      final String weekday = localizations.narrowWeekdays[i];
      result.add(new ExcludeSemantics(
        child: new Center(child: new Text(weekday, style: headerStyle)),
      ));
      if (i == (localizations.firstDayOfWeekIndex - 1) % 7) break;
    }
    return result;
  }

  /// Returns the number of days in a month, according to the proleptic
  /// Gregorian calendar.
  ///
  /// This applies the leap year logic introduced by the Gregorian reforms of
  /// 1582. It will not give valid results for dates prior to that time.
  static int getDaysInMonth(int year, int month) {
    return ummAlquraCalendar().getDaysInMonth(year, month);
  }

  /// Computes the offset from the first day of week that the first day of the
  /// [month] falls on.
  ///
  /// For example, September 1, 2017 falls on a Friday, which in the calendar
  /// localized for United States English appears as:
  ///
  /// ```
  /// S M T W T F S
  /// _ _ _ _ _ 1 2
  /// ```
  ///
  /// The offset for the first day of the months is the number of leading blanks
  /// in the calendar, i.e. 5.
  ///
  /// The same date localized for the Russian calendar has a different offset,
  /// because the first day of week is Monday rather than Sunday:
  ///
  /// ```
  /// M T W T F S S
  /// _ _ _ _ 1 2 3
  /// ```
  ///
  /// So the offset is 4, rather than 5.
  ///
  /// This code consolidates the following:
  ///
  /// - [ummAlquraCalendar.weekday] provides a 1-based index into days of week, with 1
  ///   falling on Monday.
  /// - [MaterialLocalizations.firstDayOfWeekIndex] provides a 0-based index
  ///   into the [MaterialLocalizations.narrowWeekdays] list.
  /// - [MaterialLocalizations.narrowWeekdays] list provides localized names of
  ///   days of week, always starting with Sunday and ending with Saturday.
  int _computeFirstDayOffset(int year, int month) {
    var convertDate = new ummAlquraCalendar();
    DateTime wkDay = convertDate.hijriToGregorian(year, month, 1);
    // 0-based day of week, with 0 representing Monday.
    final int weekdayFromMonday = wkDay.weekday - 1;
    // 0-based day of week, with 0 representing Sunday.
    final int firstDayOfWeekFromSunday = 0;
    // firstDayOfWeekFromSunday recomputed to be Monday-based
    final int firstDayOfWeekFromMonday = (firstDayOfWeekFromSunday - 1) % 7;
    // Number of days between the first day of week appearing on the calendar,
    // and the day corresponding to the 1-st of the month.
    return (weekdayFromMonday - firstDayOfWeekFromMonday) % 7;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    final int year = displayedMonth.hYear;
    final int month = displayedMonth.hMonth;
    final int daysInMonth = getDaysInMonth(year, month);
    final int firstDayOffset = _computeFirstDayOffset(year, month);
    final List<Widget> labels = <Widget>[];
    labels.addAll(_getDayHeaders(themeData.textTheme.caption, localizations));
    for (int i = 0; true; i += 1) {
      // 1-based day of month, e.g. 1-31 for January, and 1-29 for February on
      // a leap year.
      final int day = i - firstDayOffset + 1;
      if (day > daysInMonth) break;
      if (day < 1) {
        labels.add(new Container());
      } else {
        final ummAlquraCalendar dayToBuild = new ummAlquraCalendar()
          ..hYear = year
          ..hMonth = month
          ..hDay = day;
        final bool disabled = dayToBuild.isAfter(
                lastDate.hYear, lastDate.hMonth, lastDate.hDay) ||
            dayToBuild.isBefore(
                firstDate.hYear, firstDate.hMonth, firstDate.hDay) ||
            (selectableDayPredicate != null &&
                !selectableDayPredicate(dayToBuild));

        BoxDecoration decoration;
        TextStyle itemStyle = themeData.textTheme.body1;

        final bool isSelectedDay = selectedDate.hYear == year &&
            selectedDate.hMonth == month &&
            selectedDate.hDay == day;
        if (isSelectedDay) {
          // The selected day gets a circle background highlight, and a contrasting text color.
          itemStyle = themeData.accentTextTheme.body2;
          decoration = new BoxDecoration(
              color: themeData.accentColor, shape: BoxShape.circle);
        } else if (disabled) {
          itemStyle = themeData.textTheme.body1
              .copyWith(color: themeData.disabledColor);
        } else if (currentDate.hYear == year &&
            currentDate.hMonth == month &&
            currentDate.hDay == day) {
          // The current day gets a different text color.
          itemStyle =
              themeData.textTheme.body2.copyWith(color: themeData.accentColor);
        }

        Widget dayWidget = new Container(
          decoration: decoration,
          child: new Center(
            child: new Semantics(
              // We want the day of month to be spoken first irrespective of the
              // locale-specific preferences or TextDirection. This is because
              // an accessibility user is more likely to be interested in the
              // day of month before the rest of the date, as they are looking
              // for the day of month. To do that we prepend day of month to the
              // formatted full date.
              label: '${localizations.formatDecimal(day)}, ${dayToBuild
                  .toString()}',
              selected: isSelectedDay,
              child: new ExcludeSemantics(
                child: new Text(localizations.formatDecimal(day),
                    style: itemStyle),
              ),
            ),
          ),
        );

        if (!disabled) {
          dayWidget = new GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              onChanged(dayToBuild);
            },
            child: dayWidget,
          );
        }

        labels.add(dayWidget);
      }
    }

    return new Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: new Column(
        children: <Widget>[
          new Container(
            height: _kDayPickerRowHeight,
            child: new Center(
              child: new ExcludeSemantics(
                child: new Text(
                  "${displayedMonth.toFormat("MMMM")} ${displayedMonth.hYear}",
                  style: themeData.textTheme.subhead,
                ),
              ),
            ),
          ),
          new Flexible(
            child: new GridView.custom(
              gridDelegate: _kDayPickerGridDelegate,
              childrenDelegate: new SliverChildListDelegate(labels,
                  addRepaintBoundaries: false),
            ),
          ),
        ],
      ),
    );
  }
}
