import 'dart:async';
import 'package:location/location.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'newReportPage.dart';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;

class Maps extends StatefulWidget {
  @override
  _Maps createState() => _Maps();
}

class _Maps extends State<Maps> {
  Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = {};

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

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  void _onAddMarkerButtonPressed() {
    setState(() {
      _markers.add(Marker(
        markerId: MarkerId(0.toString()),
        position: new LatLng(0, 0),
        infoWindow: InfoWindow(
          title: 'Some event',
          snippet: 'Some information about the event',
        ),
        icon: BitmapDescriptor.defaultMarker,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    _getLocation().then((value) {
      setState(() {
        userLocation = value;
      });
    });
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
                target: new LatLng(userLocation["latitude"], userLocation["longitude"]),
                zoom: 9.0,
              ),
            ),
            Container(
                alignment: Alignment.bottomCenter,
                child: FlatButton(
                  child: Text(
                    'Send',
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => ReportPage()));
                  },
                ))
          ],
        ));
  }
}

@override
Widget build(BuildContext context) {
  // TODO: implement build
  return null;
}
