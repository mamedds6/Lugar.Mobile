import 'package:flutter/material.dart';
import 'newReportPage.dart';
import 'mapPage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lugar Mobile',
      theme: ThemeData(
        primarySwatch: Colors.red,
        primaryColor: Colors.red,
      ),
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(50.0),
              child: AppBar(
                bottom: TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.map)),
                  Tab(icon: Icon(Icons.report)),
                  Tab(icon: Icon(Icons.settings)),
                ],
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,          
            ),
            //title: Text('Lugar'),
              )
            ),
          body: TabBarView(
            children: [
              Icon(Icons.directions_transit),
              //Maps(),
              MyHomePage(title: 'Report New Incident',),
              Icon(Icons.settings),
            ],
          ),
        ),
      ),
    );
  }
}
