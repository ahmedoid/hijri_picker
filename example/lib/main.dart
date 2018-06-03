import 'dart:async';

import 'package:example/picker/_hDatePickerDialog.dart';
import 'package:example/picker/hijri/umm_alqura_calendar.dart';
import 'package:flutter/material.dart';
import 'package:hijri_picker/hijri_picker.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'Flutter Demo',
        theme: new ThemeData(
            // This is the theme of your application.
            //
            // Try running your application with "flutter run". You'll see the
            // application has a blue toolbar. Then, without quitting the app, try
            // changing the primarySwatch below to Colors.green and then invoke
            // "hot reload" (press "r" in the console where you ran "flutter run",
            // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
            // counter didn't reset back to zero; the application is not restarted.
            primarySwatch: Colors.purple,
            accentColor: Colors.amber),
        home:
            MyHomePage() /* new DatePickerDialog(
        initialDate: new ummAlquraCalendar.now(),
        lastDate: new ummAlquraCalendar.now()
          ..hYear = 1450
          ..hMonth = 12
          ..hDay = 20,
        firstDate: new ummAlquraCalendar.now(),
        initialDatePickerMode: DatePickerMode.day,
      ),*/
        );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  int i = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
      i = Calculator().addOne(i);
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("hh"),
      ),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new RawMaterialButton(onPressed: () {
              _selectDatea(context);
            }),
            new Text(
              'You have pushed the button this many times:',
            ),
            new Text(
              '$i',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: () => _selectDate(context),
        tooltip: 'Increment',
        child: new Icon(Icons.add),
      ), // T// his trailing comma makes auto-formatting nicer for build methods.
    );
  }

  //final ummAlquraCalendar selectedDate;

  Future<Null> _selectDate(BuildContext context) async {
    final ummAlquraCalendar picked = await hijriShowDatePicker(
      context: context,
      initialDate: new ummAlquraCalendar()
        ..hYear = 1439
        ..hMonth = 12
        ..hDay = 25,
      lastDate: new ummAlquraCalendar()
        ..hYear = 1442
        ..hMonth = 9
        ..hDay = 25,
      firstDate: new ummAlquraCalendar()
        ..hYear = 1439
        ..hMonth = 12
        ..hDay = 25,
      initialDatePickerMode: DatePickerMode.day,
    );
    if (picked != null) print(picked);
  }

  Future<Null> _selectDatea(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: new DateTime(2018),
      firstDate: new DateTime(2015, 8),
      lastDate: new DateTime(2101),
      initialDatePickerMode: DatePickerMode.day,
    );
    if (picked != null) print(picked);
  }
}
