import 'umm_alqura_array.dart';

class ummAlquraCalendar {
  String currentLocale = 'en';
  int lengthOfMonth;
  int hDay;
  int hMonth;
  int hYear;
  int wkDay;
  String longMonthName;
  String shortMonthName;
  String dayWeName;

  static Map<String, Map> _local = {
    'en': {
      'long': monthNames,
      'short': monthShortNames,
      'days': wdNames,
      'short_days': shortWdNames
    },
    'ar': {
      'long': arMonthNames,
      'short': arMonthShortNames,
      'days': arWkNames,
      'short_days': shortWdNames
    },
  };

  ummAlquraCalendar();

  ummAlquraCalendar.fromDate(DateTime date) {
    gregorianToHijri(date.year, date.month, date.day);
  }

  ummAlquraCalendar.now() {
    this._now();
  }

  _now() {
    var today = new DateTime.now();
    gregorianToHijri(today.year, today.month, today.day);
  }

  int getDaysInMonth(int year, int month) {
    int i = _getNewMoonMJDNIndex(year, month);
    return _ummalquraDataIndex(i) - _ummalquraDataIndex(i - 1);
  }

  _gMod(int n, int m) {
    // generalized modulo function (n mod m) also valid for negative values of n
    return ((n % m) + m) % m;
  }

  _getNewMoonMJDNIndex(int hy, int hm) {
    int cYears = hy - 1, totalMonths = (cYears * 12) + 1 + (hm - 1);
    return totalMonths - 16260;
  }

  int lengthOfYear({int year = 0}) {
    int total = 0;
    if (year == 0) year = this.hYear;
    for (int m = 0; m <= 11; m++) {
      total += getDaysInMonth(year, m);
    }
    return total;
  }

  hijriToGregorian(year, month, day) {
    var iy = year;
    var im = month;
    var id = day;
    var ii = iy - 1;
    var iln = (ii * 12) + 1 + (im - 1);
    var i = iln - 16260;
    var mcjdn = id + _ummalquraDataIndex(i - 1) - 1;
    var cjdn = mcjdn + 2400000;
    return julianToGregorian(cjdn);
  }

  DateTime julianToGregorian(julianDate) {
    //source from: http://keith-wood.name/calendars.html
    var z = (julianDate + 0.5).floor();
    var a = ((z - 1867216.25) / 36524.25).floor();
    a = z + 1 + a - (a / 4).floor();
    var b = a + 1524;
    var c = ((b - 122.1) / 365.25).floor();
    var d = (365.25 * c).floor();
    var e = ((b - d) / 30.6001).floor();
    var day = b - d - (e * 30.6001).floor();
    var wd = _gMod(julianDate + 1, 7) + 1;

    var month = e - (e > 13.5 ? 13 : 1);
    var year = c - (month > 2.5 ? 4716 : 4715);
    if (year <= 0) {
      year--;
    } // No year zero
    return new DateTime(year, (month), day);
  }

  gregorianToHijri(pYear, pMonth, pDay) {
    //This code the modified version of R.H. van Gent Code, it can be found at http://www.staff.science.uu.nl/~gent0113/islam/ummalqura.htm
    // read calendar data

    var day = (pDay);
    var month =
        (pMonth); // -1; // Here we enter the Index of the month (which starts with Zero)
    var year = (pYear);

    var m = month;
    var y = year;

    // append January and February to the previous year (i.e. regard March as
    // the first month of the year in order to simplify leapday corrections)

    if (m < 3) {
      y -= 1;
      m += 12;
    }

    // determine offset between Julian and Gregorian calendar

    var a = (y / 100).floor();
    var jgc = a - (a / 4.0).floor() - 2;

    // compute Chronological Julian Day Number (CJDN)

    var cjdn = (365.25 * (y + 4716)).floor() +
        (30.6001 * (m + 1)).floor() +
        day -
        jgc -
        1524;

    a = ((cjdn - 1867216.25) / 36524.25).floor();
    jgc = a - (a / 4.0).floor() + 1;
    var b = cjdn + jgc + 1524;
    var c = ((b - 122.1) / 365.25).floor();
    var d = (365.25 * c).floor();
    month = ((b - d) / 30.6001).floor();
    day = (b - d) - (30.6001 * month).floor();

    if (month > 13) {
      c += 1;
      month -= 12;
    }

    month -= 1;
    year = c - 4716;

    // compute Modified Chronological Julian Day Number (MCJDN)

    var mcjdn = cjdn - 2400000;

    // the MCJDN's of the start of the lunations in the Umm al-Qura calendar are stored in 'islamcalendar_dat.js'
    var i;
    for (i = 0; i < ummAlquraDateArray.length; i++) {
      if (_ummalquraDataIndex(i) > mcjdn) break;
    }

    // compute and output the Umm al-Qura calendar date

    var iln = i + 16260;
    var ii = ((iln - 1) / 12).floor();
    var iy = ii + 1;
    var im = iln - 12 * ii;
    var id = mcjdn - _ummalquraDataIndex(i - 1) + 1;
    var ml = _ummalquraDataIndex(i) - _ummalquraDataIndex(i - 1);
    lengthOfMonth = ml;
    int wd = this._gMod(cjdn + 1, 1);
    wkDay = wd == 0 ? 7 : wd;
    print(wd);
    return hDate(iy, im, id);
  }

  hDate(year, month, day) {
    this.hYear = year;
    this.hMonth = month;
    this.longMonthName = _local[currentLocale]['long'][month];
    this.dayWeName = _local[currentLocale]['days'][wkDay];
    this.shortMonthName = _local[currentLocale]['short'][month];
    this.hDay = day;
    format(this.hYear, this.hMonth, this.hDay, "dd/mm/yyyyH");
  }

  String toFormat(String format) {
    return this.format(this.hYear, this.hMonth, this.hDay, format);
  }

  format(year, month, day, format) {
    //  if (validateHijri(year, month, day)) {
    String newFormat = format;

    if (newFormat.indexOf("dd") != -1)
      newFormat =
          newFormat.replaceFirst("dd", day < 10 ? "0$day" : day.toString());
    else if (newFormat.indexOf("d") != -1)
      newFormat = newFormat.replaceFirst("d", day.toString());

    if (newFormat.indexOf("DDDD") != -1) {
      newFormat = newFormat.replaceFirst(
          "DDDD", "${_local[currentLocale]['days'][wkDay ?? wekDay()]}");
    } else if (newFormat.indexOf("DD") != -1) {
      newFormat = newFormat.replaceFirst(
          "DD", "${_local[currentLocale]['short_days'][wkDay ?? wekDay()]}");
    }

    if (newFormat.indexOf("mm") != -1)
      newFormat = newFormat.replaceFirst(
          "mm", month < 10 ? "0$month" : month.toString());
    else
      newFormat = newFormat.replaceFirst("m", month.toString());

    if (newFormat.indexOf("MMMM") != -1)
      newFormat =
          newFormat.replaceFirst("MMMM", _local[currentLocale]['long'][month]);
    else if (newFormat.indexOf("MM") != -1)
      newFormat =
          newFormat.replaceFirst("MM", _local[currentLocale]['short'][month]);

    if (newFormat.indexOf("yyyy") != -1)
      newFormat = newFormat.replaceFirst("yyyy", year.toString());
    else
      newFormat = newFormat.replaceFirst("yy", year.toString().substring(2, 4));
    return newFormat;
    // }
  }

  bool isBefore(int year, int month, int day) {
    return hijriToGregorian(hYear, hMonth, hDay).millisecondsSinceEpoch <
        hijriToGregorian(year, month, day).millisecondsSinceEpoch;
  }

  bool isAfter(int year, int month, int day) {
    return hijriToGregorian(hYear, hMonth, hDay).millisecondsSinceEpoch >
        hijriToGregorian(year, month, day).millisecondsSinceEpoch;
  }

  bool isAtSameMomentAs(int year, int month, int day) {
    return hijriToGregorian(hYear, hMonth, hDay).millisecondsSinceEpoch ==
        hijriToGregorian(year, month, day).millisecondsSinceEpoch;
  }

  int _ummalquraDataIndex(int index) {
    if (index < 0 || index >= ummAlquraDateArray.length) {
      throw new ArgumentError(
          "Valid date should be between 1356 AH (14 March 1937 CE) to 1500 AH (16 November 2077 CE)");
    }
    return ummAlquraDateArray[index];
  }

  int wekDay() {
    DateTime wkDay = hijriToGregorian(hYear, hMonth, hDay);
    return wkDay.weekday;
  }

  @override
  String toString() {
    return format(hYear, hMonth, hDay, "dd/mm/yyyyH");
  }

  List<int> toList() => [hYear, hMonth, hDay];

  String fullDate() {
    return format(hYear, hMonth, hDay, "DDDD, MMMM d, yyyy h");
  }

  ummAlquraCalendar.addMonth(int year, int month) {
    //print(month ~/ 12);
    print((month % 12 == 0 ? 12 : month % 12));
    hYear = month % 12 == 0 ? year - 1 : year;
    hMonth = month % 12 == 0 ? 12 : month % 12;
    hDay = 1;

    print("{$hYear - $hMonth - $hDay}");
    // return new ummAlquraCalendar()..hYear = this.hYear ..hMonth = this.hMonth ..hDay = this.hDay;
  }

  bool isValid() {
    // if (validateHijri(this.hYear, this.hMonth, this.hDay)) {
    if (this.hDay <= getDaysInMonth(this.hYear, this.hMonth)) {
      return true;
    } else {
      return false;
    }
//    } else {
//      return false;
//    }
  }

//  validateHijri(int year, int month, int day) {
//    if (month < 1 || month > 12) return false;
//
//    if (day < 1 || day > 30) return false;
//    return true;
//  }
}
