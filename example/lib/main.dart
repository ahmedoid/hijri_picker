import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hijri/umm_alqura_calendar.dart';
import 'package:hijri_picker/hijri_picker.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'Flutter Demo',
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [
          //     const Locale('en', 'USA'),
          const Locale('ar', 'SA'),
        ],
        debugShowCheckedModeBanner: false,
        theme: new ThemeData(
          primaryColor: Colors.brown,
          accentColor: Colors.green,
          brightness: Brightness.dark,
        ),
        home: MyHomePage(title: "Umm Alqura Calendar"));
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  UmmAlquraCalendar selectedDate = new UmmAlquraCalendar.now();

  @override
  Widget build(BuildContext context) {
    UmmAlquraCalendar.setLocal(Localizations.localeOf(context).languageCode);
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Padding(
        padding: const EdgeInsets.all(8.0),
        child: new Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            //   crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              new Text(
                '${selectedDate.toString()}',
                style: Theme.of(context).textTheme.headline,
              ),
              new Text(
                '${selectedDate.fullDate()}',
                style: Theme.of(context).textTheme.headline,
              ),

            ],
          ),
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: () => _selectDate(context),
        tooltip: 'Pick Date',
        child: new Icon(Icons.event),
      ),
    );
  }

  Future<Null> _selectDate(BuildContext context) async {
    final UmmAlquraCalendar picked = await showHijriDatePicker(
      context: context,
      initialDate: selectedDate,

      lastDate: new UmmAlquraCalendar()
        ..hYear = 1445
        ..hMonth = 9
        ..hDay = 25,
      firstDate: new UmmAlquraCalendar()
        ..hYear = 1438
        ..hMonth = 12
        ..hDay = 25,
      initialDatePickerMode: DatePickerMode.day,
    );
    print(picked);
    if (picked != null)
      setState(() {
        selectedDate = picked;
      });
  }
}
