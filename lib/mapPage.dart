import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:location/location.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:path/path.dart';
import 'package:lugar_mobile/camera.dart';
import 'newReportPage.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'alert.dart';

class Maps extends StatefulWidget {
  @override
  _Maps createState() => _Maps();
}

class _Maps extends State<Maps> {
  Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = {};
  double zoomVal = 10;
  MarkerId chosenMarkerId;
  Timer timer;

  Map<String, double> userLocation;
  var location = new Location();

  Future<Map<String, double>> _getLocation() async {
    var currentLocation = <String, double>{};
    try {
      currentLocation = await location.getLocation();
    } catch (e) {
      currentLocation = null;
    }
    return currentLocation;
  }

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 5), (Timer t) => _getLocation());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _makeDetails(context) {
    if (chosenMarkerId != null) {
    } else {}
  }

  void _getAllMarkers() async {
    final response =
        await http.get("https://lugarapi.azurewebsites.net/api/reports/get");
    if (response.statusCode == 200) {
      var hash = json.decode(response.body);
      var newVersion = hash['dataVersion'];
      var reports = hash['reports'];
      _markers.clear();
      for (var report in reports) {
        try {
          setState(() {
            _markers.add(Marker(
              markerId: MarkerId(report['id'].toString()),
              position: new LatLng(report['latitude'], report['longitude']),
              infoWindow: InfoWindow(
                title: report['category'],
                snippet: report['description'],
              ),
              icon: BitmapDescriptor.defaultMarker,
              onTap: () {
                chosenMarkerId = MarkerId(report['id'].toString());
                _makeDetails(context);
              },
            ));
          });
        } catch (e) {}
      }
    } else {
      throw Exception('Error with Api Get');
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
    //const tic = const Duration(seconds: 3);
    //new Timer.periodic(tic, (Timer t) => _getAllMarkers());
    _getAllMarkers();
  }

  int findIndex() {}

  @override
  Widget build(BuildContext context) {
    _getLocation().then((value) {
      setState(() {
        userLocation = value;
      });
    });

    final newReportButton = Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(30.0),
        color: Colors.red,
        child: MaterialButton(
          textColor: Colors.white,
          padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
          onPressed: () async {
            final cameras = await availableCameras();
            final firstCamera = cameras.first;
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        TakePictureScreen(camera: firstCamera)));
          },
          child: Text(
            "New report",
            textAlign: TextAlign.center,
          ),
        ));

    return Scaffold(
        drawer: Drawer(
          child: ListView(
            children: <Widget>[
              ListTile(
                title: Text("Map"),
                onTap: () => Navigator.pushNamed(context, '/'),
                trailing: Icon(Icons.arrow_forward),
              ),
              ListTile(
                title: Text("History"),
                trailing: Icon(Icons.arrow_forward),
              ),
              ListTile(
                title: Text("Settings"),
                trailing: Icon(Icons.arrow_forward),
              ),
              ListTile(
                title: Text("Your Account"),
                trailing: Icon(Icons.arrow_forward),
              ),
              ListTile(
                title: Text("About"),
                trailing: Icon(Icons.arrow_forward),
              ),
            ],
          ),
        ),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: AppBar(
            title: Text('Lugar'),
            backgroundColor: Colors.red,
          ),
        ),
        body: Stack(
          children: <Widget>[
            GoogleMap(
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              onMapCreated: _onMapCreated,
              mapType: MapType.normal,
              markers: _markers,
              initialCameraPosition: CameraPosition(
                target: new LatLng(
                    userLocation["latitude"], userLocation["longitude"]),
                zoom: 9.0,
              ),
            ),
            _zoomminusfunction(),
            _zoomplusfunction(),
            // chosenMarkerId != null
            //     ? Container(
            //         alignment: Alignment.topCenter,
            //         width: MediaQuery.of(context).size.width * 0.8,
            //         height: MediaQuery.of(context).size.height * 0.3,
            //         padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
            //         child: Image.file(File.fromUri(Uri.parse("https://lugarapi.azurewebsites.net/images/" + chosenMarkerId.value)), fit: BoxFit.fill),
            //         //child: Text("asd"),
            //         )
            //     : Text(""),
            Padding(
                padding: EdgeInsets.only(bottom: 12.0),
                child: Container(
                  alignment: Alignment.bottomCenter,
                  child: newReportButton,
                ))
          ],
        ));
  }

  Widget _zoomminusfunction() {
    return Align(
      alignment: Alignment.topLeft,
      child: IconButton(
          icon: Icon(
            FontAwesomeIcons.searchMinus,
            color: Colors.red,
          ),
          onPressed: () {
            zoomVal--;
            _minus(zoomVal);
            _getAllMarkers();
          }),
    );
  }

  Widget _zoomplusfunction() {
    return Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: EdgeInsets.only(top: 50.0),
          child: IconButton(
              icon: Icon(
                FontAwesomeIcons.searchPlus,
                color: Colors.red,
              ),
              onPressed: () {
                zoomVal++;
                _plus(zoomVal);
                _getAllMarkers();
              }),
        ));
  }

  Future<void> _minus(double zoomVal) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: new LatLng(userLocation["latitude"], userLocation["longitude"]),
        zoom: zoomVal)));
  }

  Future<void> _plus(double zoomVal) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: new LatLng(userLocation["latitude"], userLocation["longitude"]),
        zoom: zoomVal)));
  }
}
