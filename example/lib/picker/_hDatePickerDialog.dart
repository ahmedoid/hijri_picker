import 'dart:async';

import 'package:example/picker/hMonthPicker.dart';
import 'package:example/picker/hYearPicker.dart';
import 'package:example/picker/hijri/umm_alqura_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

const double _kMonthPickerPortraitWidth = 330.0;
const double _kMonthPickerLandscapeWidth = 344.0;
const double _kDatePickerHeaderPortraitHeight = 100.0;
const double _kDatePickerHeaderLandscapeWidth = 168.0;
const double _kDayPickerRowHeight = 42.0;
const int _kMaxDayPickerRowCount = 6; // A 31 day month that starts on Saturday.
const double _kDialogActionBarHeight = 52.0;
const double _kDatePickerLandscapeHeight =
    _kMaxDayPickerHeight + _kDialogActionBarHeight;
// Two extra rows: one for the day-of-week header and one for the month header.
const double _kMaxDayPickerHeight =
    _kDayPickerRowHeight * (_kMaxDayPickerRowCount + 2);

/// Signature for predicating dates for enabled date selections.
///
/// See [showDatePicker].
typedef bool SelectableDayPredicate(ummAlquraCalendar day);

class DatePickerDialog extends StatefulWidget {
  const DatePickerDialog({
    Key key,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.selectableDayPredicate,
    this.initialDatePickerMode,
  }) : super(key: key);

  final ummAlquraCalendar initialDate;
  final ummAlquraCalendar firstDate;
  final ummAlquraCalendar lastDate;
  final SelectableDayPredicate selectableDayPredicate;
  final DatePickerMode initialDatePickerMode;

  @override
  _DatePickerDialogState createState() => new _DatePickerDialogState();
}

class _DatePickerDialogState extends State<DatePickerDialog> {
  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _mode = widget.initialDatePickerMode;
  }

  bool _announcedInitialDate = false;

  MaterialLocalizations localizations;
  TextDirection textDirection;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizations = MaterialLocalizations.of(context);
    textDirection = Directionality.of(context);
    if (!_announcedInitialDate) {
      _announcedInitialDate = true;
      SemanticsService.announce(
        _selectedDate.toString(),
        textDirection,
      );
    }
  }

  ummAlquraCalendar _selectedDate;
  DatePickerMode _mode;
  final GlobalKey _pickerKey = new GlobalKey();

  void _vibrate() {
    switch (Theme.of(context).platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        HapticFeedback.vibrate();
        break;
      case TargetPlatform.iOS:
        break;
    }
  }

  void _handleModeChanged(DatePickerMode mode) {
    _vibrate();
    setState(() {
      _mode = mode;
      if (_mode == DatePickerMode.day) {
        SemanticsService.announce(_selectedDate.toString(), textDirection);
      } else {
        SemanticsService.announce(_selectedDate.toString(), textDirection);
      }
    });
  }

  void _handleYearChanged(ummAlquraCalendar value) {
    _vibrate();
    setState(() {
      _mode = DatePickerMode.day;
      _selectedDate = value;
    });
  }

  void _handleDayChanged(ummAlquraCalendar value) {
    _vibrate();
    setState(() {
      _selectedDate = value;
    });
  }

  void _handleCancel() {
    Navigator.pop(context);
  }

  void _handleOk() {
    Navigator.pop(context, _selectedDate);
  }

  Widget _buildPicker() {
    assert(_mode != null);
    switch (_mode) {
      case DatePickerMode.day:
        return new hMonthPicker(
          key: _pickerKey,
          selectedDate: _selectedDate,
          onChanged: _handleDayChanged,
          firstDate: widget.firstDate,
          lastDate: widget.lastDate,
          selectableDayPredicate: widget.selectableDayPredicate,
        );
      case DatePickerMode.year:
        return new hYearPicker(
          key: _pickerKey,
          selectedDate: _selectedDate,
          onChanged: _handleYearChanged,
          firstDate: widget.firstDate,
          lastDate: widget.lastDate,
        );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Widget picker = new Flexible(
      child: new SizedBox(
        height: _kMaxDayPickerHeight,
        child: _buildPicker(),
      ),
    );
    final Widget actions = new ButtonTheme.bar(
      child: new ButtonBar(
        children: <Widget>[
          new FlatButton(
            child: new Text(localizations.cancelButtonLabel),
            onPressed: _handleCancel,
          ),
          new FlatButton(
            child: new Text(localizations.okButtonLabel),
            onPressed: _handleOk,
          ),
        ],
      ),
    );
    final Dialog dialog = new Dialog(child: new OrientationBuilder(
        builder: (BuildContext context, Orientation orientation) {
      assert(orientation != null);
      final Widget header = new _DatePickerHeader(
        hSelectedDate: _selectedDate,
        mode: _mode,
        onModeChanged: _handleModeChanged,
        orientation: orientation,
      );
      switch (orientation) {
        case Orientation.portrait:
          return new SizedBox(
            width: _kMonthPickerPortraitWidth,
            child: new Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                header,
                new Container(
                  color: theme.dialogBackgroundColor,
                  child: new Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      picker,
                      actions,
                    ],
                  ),
                ),
              ],
            ),
          );
        case Orientation.landscape:
          return new SizedBox(
            height: _kDatePickerLandscapeHeight,
            child: new Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                header,
                new Flexible(
                  child: new Container(
                    width: _kMonthPickerLandscapeWidth,
                    color: theme.dialogBackgroundColor,
                    child: new Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[picker, actions],
                    ),
                  ),
                ),
              ],
            ),
          );
      }
      return null;
    }));

    return new Theme(
      data: theme.copyWith(
        dialogBackgroundColor: Colors.transparent,
      ),
      child: dialog,
    );
  }
}

// Shows the selected date in large font and toggles between year and day mode
class _DatePickerHeader extends StatelessWidget {
  const _DatePickerHeader({
    Key key,
    @required this.hSelectedDate,
    @required this.mode,
    @required this.onModeChanged,
    @required this.orientation,
  })  : assert(hSelectedDate != null),
        assert(mode != null),
        assert(orientation != null),
        super(key: key);

  final ummAlquraCalendar hSelectedDate;
  final DatePickerMode mode;
  final ValueChanged<DatePickerMode> onModeChanged;
  final Orientation orientation;

  void _handleChangeMode(DatePickerMode value) {
    if (value != mode) onModeChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    final ThemeData themeData = Theme.of(context);
    final TextTheme headerTextTheme = themeData.primaryTextTheme;
    Color dayColor;
    Color yearColor;
    switch (themeData.primaryColorBrightness) {
      case Brightness.light:
        dayColor = mode == DatePickerMode.day ? Colors.black87 : Colors.black54;
        yearColor =
            mode == DatePickerMode.year ? Colors.black87 : Colors.black54;
        break;
      case Brightness.dark:
        dayColor = mode == DatePickerMode.day ? Colors.white : Colors.white70;
        yearColor = mode == DatePickerMode.year ? Colors.white : Colors.white70;
        break;
    }
    final TextStyle dayStyle =
        headerTextTheme.display1.copyWith(color: dayColor, height: 1.4);
    final TextStyle yearStyle =
        headerTextTheme.subhead.copyWith(color: yearColor, height: 1.4);

    Color backgroundColor;
    switch (themeData.brightness) {
      case Brightness.light:
        backgroundColor = themeData.primaryColor;
        break;
      case Brightness.dark:
        backgroundColor = themeData.backgroundColor;
        break;
    }

    double width;
    double height;
    EdgeInsets padding;
    MainAxisAlignment mainAxisAlignment;
    switch (orientation) {
      case Orientation.portrait:
        height = _kDatePickerHeaderPortraitHeight;
        padding = const EdgeInsets.symmetric(horizontal: 16.0);
        mainAxisAlignment = MainAxisAlignment.center;
        break;
      case Orientation.landscape:
        width = _kDatePickerHeaderLandscapeWidth;
        padding = const EdgeInsets.all(8.0);
        mainAxisAlignment = MainAxisAlignment.start;
        break;
    }

    final Widget yearButton = new IgnorePointer(
      ignoring: mode != DatePickerMode.day,
      ignoringSemantics: false,
      child: new _DateHeaderButton(
        color: backgroundColor,
        onTap: Feedback.wrapForTap(
            () => _handleChangeMode(DatePickerMode.year), context),
        child: new Semantics(
          selected: mode == DatePickerMode.year,
          child: new Text("${hSelectedDate.hYear}", style: yearStyle),
        ),
      ),
    );

    final Widget dayButton = new IgnorePointer(
      ignoring: mode == DatePickerMode.day,
      ignoringSemantics: false,
      child: new _DateHeaderButton(
        color: backgroundColor,
        onTap: Feedback.wrapForTap(
            () => _handleChangeMode(DatePickerMode.day), context),
        child: new Semantics(
          selected: mode == DatePickerMode.day,
          child: new Text("${hSelectedDate?.toFormat("DD, MM dd")}",
              style: dayStyle),
        ),
      ),
    );

    return new Container(
      width: width,
      height: height,
      padding: padding,
      color: backgroundColor,
      child: new Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[yearButton, dayButton],
      ),
    );
  }
}

class _DateHeaderButton extends StatelessWidget {
  const _DateHeaderButton({
    Key key,
    this.onTap,
    this.color,
    this.child,
  }) : super(key: key);

  final VoidCallback onTap;
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return new Material(
      type: MaterialType.button,
      color: color,
      child: new InkWell(
        borderRadius: kMaterialEdges[MaterialType.button],
        highlightColor: theme.highlightColor,
        splashColor: theme.splashColor,
        onTap: onTap,
        child: new Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: child,
        ),
      ),
    );
  }
}

Future<ummAlquraCalendar> hijriShowDatePicker({
  @required BuildContext context,
  @required ummAlquraCalendar initialDate,
  @required ummAlquraCalendar firstDate,
  @required ummAlquraCalendar lastDate,
  SelectableDayPredicate selectableDayPredicate,
  DatePickerMode initialDatePickerMode: DatePickerMode.day,
  Locale locale,
  TextDirection textDirection,
}) async {
  assert(
      !initialDate.isBefore(firstDate.hYear, firstDate.hMonth, firstDate.hDay),
      'initialDate must be on or after firstDate');
  assert(!initialDate.isAfter(lastDate.hYear, lastDate.hMonth, lastDate.hDay),
      'initialDate must be on or before lastDate');
  assert(!firstDate.isAfter(lastDate.hYear, lastDate.hMonth, lastDate.hDay),
      'lastDate must be on or after firstDate');
  assert(selectableDayPredicate == null || selectableDayPredicate(initialDate),
      'Provided initialDate must satisfy provided selectableDayPredicate');
  assert(
      initialDatePickerMode != null, 'initialDatePickerMode must not be null');

  Widget child = new DatePickerDialog(
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: lastDate,
    selectableDayPredicate: selectableDayPredicate,
    initialDatePickerMode: initialDatePickerMode,
  );

  if (textDirection != null) {
    child = new Directionality(
      textDirection: textDirection,
      child: child,
    );
  }

  if (locale != null) {
    child = new Localizations.override(
      context: context,
      locale: locale,
      child: child,
    );
  }

  return await showDialog<ummAlquraCalendar>(
    context: context,
    builder: (BuildContext context) => child,
  );
}
