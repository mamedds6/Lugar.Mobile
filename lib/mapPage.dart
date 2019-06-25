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

  void _makeDetails() {
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
                _makeDetails();
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
          //minWidth: MediaQuery.of(context).size.width,
          padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
          onPressed: () async {
            final cameras = await availableCameras();
            final firstCamera = cameras.first;
            Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => TakePictureScreen(camera: firstCamera)));
          },
          child: Text(
            "New report",
            textAlign: TextAlign.center,
            // textColor: Colors.white,
            //  fontWeight: FontWeight.bold),
          ),
        ));

    return Scaffold(
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
      alignment: Alignment.topRight,
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
    );
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
