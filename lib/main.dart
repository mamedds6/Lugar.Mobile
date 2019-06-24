import 'package:flutter/material.dart';
import 'newReportPage.dart';
import 'mapPage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/map': (context) => Maps(),
        '/report': (context) => ReportPage(),
      },
      title: 'Lugar Mobile',
      theme: ThemeData(
        primarySwatch: Colors.red,
        primaryColor: Colors.red,
      ),
      home: Maps(),
    );
  }
}