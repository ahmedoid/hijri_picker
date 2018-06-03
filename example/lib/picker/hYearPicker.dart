import 'package:example/picker/hijri/umm_alqura_calendar.dart';
import 'package:flutter/material.dart';

/// A scrollable list of years to allow picking a year.
///
/// The year picker widget is rarely used directly. Instead, consider using
/// [showDatePicker], which creates a date picker dialog.
///
/// Requires one of its ancestors to be a [Material] widget.
///
/// See also:
///
///  * [showDatePicker]
///  * <https://material.google.com/components/pickers.html#pickers-date-pickers>
class hYearPicker extends StatefulWidget {
  /// Creates a year picker.
  ///
  /// The [selectedDate] and [onChanged] arguments must not be null. The
  /// [lastDate] must be after the [firstDate].
  ///
  /// Rarely used directly. Instead, typically used as part of the dialog shown
  /// by [showDatePicker].
  hYearPicker({
    Key key,
    @required this.selectedDate,
    @required this.onChanged,
    @required this.firstDate,
    @required this.lastDate,
  })  : assert(selectedDate != null),
        assert(onChanged != null),
        assert(
            !firstDate.isAfter(lastDate.hYear, lastDate.hMonth, lastDate.hDay)),
        super(key: key);

  /// The currently selected date.
  ///
  /// This date is highlighted in the picker.
  final ummAlquraCalendar selectedDate;

  /// Called when the user picks a year.
  final ValueChanged<ummAlquraCalendar> onChanged;

  /// The earliest date the user is permitted to pick.
  final ummAlquraCalendar firstDate;

  /// The latest date the user is permitted to pick.
  final ummAlquraCalendar lastDate;

  @override
  _hYearPickerState createState() => new _hYearPickerState();
}

class _hYearPickerState extends State<hYearPicker> {
  static const double _itemExtent = 50.0;
  ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    scrollController = new ScrollController(
      // Move the initial scroll position to the currently selected date's year.
      initialScrollOffset:
          (widget.selectedDate.hYear - widget.firstDate.hYear) * _itemExtent,
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));
    final ThemeData themeData = Theme.of(context);
    final TextStyle style = themeData.textTheme.body1;
    return new ListView.builder(
      controller: scrollController,
      itemExtent: _itemExtent,
      itemCount: widget.lastDate.hYear - widget.firstDate.hYear + 1,
      itemBuilder: (BuildContext context, int index) {
        final int year = widget.firstDate.hYear + index;
        final bool isSelected = year == widget.selectedDate.hYear;
        final TextStyle itemStyle = isSelected
            ? themeData.textTheme.headline
                .copyWith(color: themeData.accentColor)
            : style;
        return new InkWell(
          key: new ValueKey<int>(year),
          onTap: () {
            // year, widget.selectedDate.hMonth, widget.selectedDate.hMonth
            widget.onChanged(new ummAlquraCalendar()
              ..hYear = year
              ..hMonth = widget.selectedDate.hMonth
              ..hDay = widget.selectedDate.hDay);
          },
          child: new Center(
            child: new Semantics(
              selected: isSelected,
              child: new Text(year.toString(), style: itemStyle),
            ),
          ),
        );
      },
    );
  }
}
