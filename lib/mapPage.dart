import 'dart:async';
import 'package:location/location.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Maps extends StatefulWidget {
  @override
  
  _Maps createState() => _Maps();
}

class _Maps extends State<Maps> {
  Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = {};

  LatLng _center = LatLng(45.521563, -122.677433);
  var location = new Location();

  Future<LatLng> _getLocation() async {
    var currentLocation = <String, double>{};
    try {
      currentLocation = await location.getLocation();
    } catch (e) {
      currentLocation = null;
    }
    return new LatLng(currentLocation["latitude"],currentLocation["longitude"]);
  }
  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
    setState(() {
          _center = _getLocation() as LatLng;
          super.initState();
    });

  }

  void _onAddMarkerButtonPressed() {
    setState(() {
      _markers.add(Marker(
        markerId: MarkerId(0.toString()),
        position: new LatLng(0,0),
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
    return MaterialApp(
      home: Stack(
          children: <Widget>[
            GoogleMap(
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              onMapCreated: _onMapCreated,
              mapType: MapType.normal,
              markers: _markers,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 9.0,
              ),
            ),
            Container(
              alignment: Alignment.bottomCenter,

            )
          ],
        )
    );
  }
}

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return null;
  }