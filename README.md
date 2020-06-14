
Hijri Date Picker
-
Hijri calender to pick umm alqura dates support max & min dates


Simple Usage
-
Add local to `MaterialApp`
```dart in html
 localizationsDelegates: [
           GlobalMaterialLocalizations.delegate,
           GlobalWidgetsLocalizations.delegate,
         ],
         supportedLocales: [
           const Locale('ar', 'SA'),
         ],
```
[Internationalizing Flutter apps](https://flutter.dev/docs/development/accessibility-and-localization/internationalization)



```dart in html
 final ummAlquraCalendar picked = await showHijriDatePicker(
       context: context,
       initialDate: selectedDate,
       lastDate: new ummAlquraCalendar()
         ..hYear = 1442
         ..hMonth = 9
         ..hDay = 25,
       firstDate: new ummAlquraCalendar()
         ..hYear = 1438
         ..hMonth = 12
         ..hDay = 25,
       initialDatePickerMode: DatePickerMode.day,
     );
```

## Screenshots
<img src="https://user-images.githubusercontent.com/3106973/84584392-92906a80-ae0c-11ea-9cf7-565b723eb4c9.png" width="23%"></img> <img src="https://user-images.githubusercontent.com/3106973/84584394-945a2e00-ae0c-11ea-9e01-260baf6debe1.png" width="23%"></img> <img src="https://user-images.githubusercontent.com/3106973/84584395-958b5b00-ae0c-11ea-84e7-616887705ce1.png" width="23%"></img> <img src="https://user-images.githubusercontent.com/3106973/84584396-9623f180-ae0c-11ea-87e7-01f8f6af02dc.png" width="23%"></img> <img src="https://user-images.githubusercontent.com/3106973/84584398-96bc8800-ae0c-11ea-8820-402a54870bfc.png" width="23%"></img> <img src="https://user-images.githubusercontent.com/3106973/84584399-97edb500-ae0c-11ea-8cea-9a21aa3d7b7c.png" width="23%"></img> <img src="https://user-images.githubusercontent.com/3106973/84584400-98864b80-ae0c-11ea-9f1b-33277b905953.png" width="23%"></img> <img src="https://user-images.githubusercontent.com/3106973/84584402-991ee200-ae0c-11ea-83e4-4b119066f5b8.png" width="23%"></img> 

by
-
Ahmed Aljoaid
