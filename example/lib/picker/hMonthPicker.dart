import 'dart:async';

import 'package:example/picker/DayPicker.dart';
import 'package:example/picker/hijri/umm_alqura_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';


typedef bool SelectableDayPredicate(ummAlquraCalendar day);

const Duration _kMonthScrollDuration = const Duration(milliseconds: 200);
const double _kMonthPickerPortraitWidth = 330.0;
const double _kDayPickerRowHeight = 42.0;
const int _kMaxDayPickerRowCount = 6; // A 31 day month that starts on Saturday.
// Two extra rows: one for the day-of-week header and one for the month header.
const double _kMaxDayPickerHeight =
    _kDayPickerRowHeight * (_kMaxDayPickerRowCount + 2);

class hMonthPicker extends StatefulWidget {
  /// Creates a month picker.
  ///
  /// Rarely used directly. Instead, typically used as part of the dialog shown
  /// by [showDatePicker].
  hMonthPicker({
    Key key,
    @required this.selectedDate,
    @required this.onChanged,
    @required this.firstDate,
    @required this.lastDate,
    this.selectableDayPredicate,
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

  /// Called when the user picks a month.
  final ValueChanged<ummAlquraCalendar> onChanged;

  /// The earliest date the user is permitted to pick.
  final ummAlquraCalendar firstDate;

  /// The latest date the user is permitted to pick.
  final ummAlquraCalendar lastDate;

  /// Optional user supplied predicate function to customize selectable days.
  final SelectableDayPredicate selectableDayPredicate;

  @override
  _hMonthPickerState createState() => new _hMonthPickerState();
}

class _hMonthPickerState extends State<hMonthPicker> {
  @override
  void initState() {
    super.initState();
    // Initially display the pre-selected date.
    final int monthPage = _monthDelta(widget.firstDate, widget.selectedDate);
    _dayPickerController = new PageController(initialPage: monthPage);
    _handleMonthPageChanged(monthPage);
    _updateCurrentDate();
  }

  @override
  void didUpdateWidget(hMonthPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    print("dates is equal : ${widget.selectedDate != oldWidget.selectedDate}");
    if (!widget.selectedDate.isAtSameMomentAs(oldWidget.selectedDate.hYear,
        oldWidget.selectedDate.hMonth, oldWidget.selectedDate.hDay)) {
      final int monthPage = _monthDelta(widget.firstDate, widget.selectedDate);
      _dayPickerController = new PageController(initialPage: monthPage);
      _handleMonthPageChanged(monthPage);
    }
  }

  MaterialLocalizations localizations;
  TextDirection textDirection;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizations = MaterialLocalizations.of(context);
    textDirection = Directionality.of(context);
  }

  ummAlquraCalendar _todayDate;
  ummAlquraCalendar _currentDisplayedMonthDate;
  Timer _timer;
  PageController _dayPickerController;

  void _updateCurrentDate() {
    _todayDate = new ummAlquraCalendar.now();
    final ummAlquraCalendar tomorrow = new ummAlquraCalendar()
      ..hYear = _todayDate.hYear
      ..hMonth = _todayDate.hMonth
      ..hDay = _todayDate.hDay + 1;
    Duration timeUntilTomorrow = tomorrow
        .hijriToGregorian(tomorrow.hYear, tomorrow.hMonth, tomorrow.hDay)
        .difference(_todayDate.hijriToGregorian(
            _todayDate.hYear,
            _todayDate.hMonth,
            _todayDate.hDay)); //tomorrow.difference(_todayDate);
    timeUntilTomorrow +=
        const Duration(seconds: 1); // so we don't miss it by rounding
    _timer?.cancel();
    _timer = new Timer(timeUntilTomorrow, () {
      setState(() {
        _updateCurrentDate();
      });
    });
  }

  static int _monthDelta(
      ummAlquraCalendar startDate, ummAlquraCalendar endDate) {
    return (endDate.hYear - startDate.hYear) * 12 +
        endDate.hMonth -
        startDate.hMonth;
  }

  /// Add months to a month truncated date.
  ummAlquraCalendar _addMonthsToMonthDate(
      ummAlquraCalendar monthDate, int monthsToAdd) {
    var x = new ummAlquraCalendar.addMonth(
        monthDate.hYear + (monthDate.hMonth + monthsToAdd) ~/ 12,
        monthDate.hMonth + monthsToAdd % 12);
    return x;
  }

  Widget _buildItems(BuildContext context, int index) {
    final month = _addMonthsToMonthDate(widget.firstDate, index);
    return new hDayPicker(
      key: new ValueKey<ummAlquraCalendar>(month),
      selectedDate: widget.selectedDate,
      currentDate: _todayDate,
      onChanged: widget.onChanged,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      displayedMonth: month,
      selectableDayPredicate: widget.selectableDayPredicate,
    );
  }

  void _handleNextMonth() {
    if (!_isDisplayingLastMonth) {
      SemanticsService.announce(
          (_nextMonthDate.hMonth.toString()), textDirection);
      _dayPickerController.nextPage(
          duration: _kMonthScrollDuration, curve: Curves.ease);
    }
  }

  void _handlePreviousMonth() {
    if (!_isDisplayingFirstMonth) {
      SemanticsService.announce(
          (_previousMonthDate.hMonth.toString()), textDirection);
      _dayPickerController.previousPage(
          duration: _kMonthScrollDuration, curve: Curves.ease);
    }
  }

  /// True if the earliest allowable month is displayed.
  bool get _isDisplayingFirstMonth {
    return !_currentDisplayedMonthDate.isAfter(
        widget.firstDate.hYear, widget.firstDate.hMonth, widget.firstDate.hDay);
  }

  /// True if the latest allowable month is displayed.
  bool get _isDisplayingLastMonth {
    return !_currentDisplayedMonthDate.isBefore(
        widget.lastDate.hYear, widget.lastDate.hMonth, widget.lastDate.hDay);
  }

  ummAlquraCalendar _previousMonthDate;
  ummAlquraCalendar _nextMonthDate;

  void _handleMonthPageChanged(int monthPage) {
    setState(() {
      _previousMonthDate =
          _addMonthsToMonthDate(widget.firstDate, monthPage - 1);
      _currentDisplayedMonthDate =
          _addMonthsToMonthDate(widget.firstDate, monthPage);
      _nextMonthDate = _addMonthsToMonthDate(widget.firstDate, monthPage + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return new SizedBox(
      width: _kMonthPickerPortraitWidth,
      height: _kMaxDayPickerHeight,
      child: new Stack(
        children: <Widget>[
          new Semantics(
            sortKey: _MonthPickerSortKey.calendar,
            child: new PageView.builder(
              key: new ValueKey<ummAlquraCalendar>(widget.selectedDate),
              controller: _dayPickerController,
              scrollDirection: Axis.horizontal,
              itemCount: _monthDelta(widget.firstDate, widget.lastDate) + 1,
              itemBuilder: _buildItems,
              onPageChanged: _handleMonthPageChanged,
            ),
          ),
          new PositionedDirectional(
            top: 0.0,
            start: 8.0,
            child: new Semantics(
              sortKey: _MonthPickerSortKey.previousMonth,
              child: new IconButton(
                icon: const Icon(Icons.chevron_left),
                tooltip: _isDisplayingFirstMonth
                    ? null
                    : '${localizations
                    .previousMonthTooltip} ${
                    _previousMonthDate.toString()}',
                onPressed:
                    _isDisplayingFirstMonth ? null : _handlePreviousMonth,
              ),
            ),
          ),
          new PositionedDirectional(
            top: 0.0,
            end: 8.0,
            child: new Semantics(
              sortKey: _MonthPickerSortKey.nextMonth,
              child: new IconButton(
                icon: const Icon(Icons.chevron_right),
                tooltip: _isDisplayingLastMonth
                    ? null
                    : '${localizations
                    .nextMonthTooltip} ${
                    _nextMonthDate.toString()}',
                onPressed: _isDisplayingLastMonth ? null : _handleNextMonth,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _dayPickerController?.dispose();
    super.dispose();
  }
}

// Defines semantic traversal order of the top-level widgets inside the month
// picker.
class _MonthPickerSortKey extends OrdinalSortKey {
  static const _MonthPickerSortKey previousMonth =
      const _MonthPickerSortKey(1.0);
  static const _MonthPickerSortKey nextMonth = const _MonthPickerSortKey(2.0);
  static const _MonthPickerSortKey calendar = const _MonthPickerSortKey(3.0);

  const _MonthPickerSortKey(double order) : super(order);
}
