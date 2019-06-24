import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Maps extends StatefulWidget {
  @override
  _Maps createState() => _Maps();
}

class _Maps extends State<Maps> {
  Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = {};

  static const LatLng _center = const LatLng(45.521563, -122.677433);

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
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
      home: Scaffold(
        appBar: AppBar(
          title: Text('Maps Sample App'),
          backgroundColor: Colors.red,
        ),
        body: GoogleMap(
          onMapCreated: _onMapCreated,
          mapType: MapType.normal,
          markers: _markers,
          initialCameraPosition: CameraPosition(
            target: _center,
            zoom: 11.0,
          ),
        ),
      ),
    );
  }
}