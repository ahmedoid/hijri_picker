
Hijri Date Picker
-
Hijri calender to pick umm alqura dates support max & min dates


Simple Usage
-
```dart in html
 final HijriCalendar picked = await showHijriDatePicker(
       context: context,
       initialDate: selectedDate,
       lastDate: new HijriCalendar()
         ..hYear = 1442
         ..hMonth = 9
         ..hDay = 25,
       firstDate: new HijriCalendar()
         ..hYear = 1438
         ..hMonth = 12
         ..hDay = 25,
       initialDatePickerMode: DatePickerMode.day,
     );
```
About
-

screenshots
-
<p float="center">
  <img src="https://i.imgur.com/tSlypEG.png" width="300" />
  <img src="https://i.imgur.com/GIE51uo.png" width="300" /> 
</p>

by
-
Ahmed Aljoaid 👨🏻‍💻
