import 'dart:async';
import 'dart:convert';
import 'dart:io' as Io;
import 'dart:io';
import 'package:dio/dio.dart';
import 'mapPage.dart';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'camera.dart';

class ReportPage extends StatefulWidget {
  ReportPage({
    Key key,
    this.title,
  }) : super(key: key);
  final String title;

  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  String loc = "";
  var location = new Location();
  Map<String, double> userLocation;
  String description_text = "...";
  String imagePath = "";

  Future<Map<String, double>> _getLocation() async {
    var currentLocation = <String, double>{};
    try {
      currentLocation = await location.getLocation();
    } catch (e) {
      currentLocation = null;
    }
    userLocation = currentLocation;

    if (imagePath != "") {
    File imageFile = new File(imagePath);
    List<int> imageBytes = imageFile.readAsBytesSync();        //working but huge
    String base64Image = base64Encode(imageBytes);

      // img.Image bigImage = img.decodeImage(new Io.File(imagePath).readAsBytesSync());
      // img.Image smallImage = img.copyResize(bigImage, height: 120);
      // List<int> imageBytes = smallImage.getBytes();
      // String base64Image = base64Encode(imageBytes);

      // FormData formData = new FormData.from({
      //   'Description': description_text,
      //   'Longtitude': userLocation["latitude"].toString(),
      //   'Latitude': userLocation["longitude"].toString(),
      //   'UserId': '1f0b33ee-223c-4393-100a-08d6f80e19b2',
      //   'Category': "ios",
      //   'Image': new UploadFileInfo(new File(imagePath), imagePath)
      // });

      var data = jsonEncode({
        'Description': description_text,
        'Longtitude': userLocation["latitude"].toString(),
        'Latitude': userLocation["longitude"].toString(),
        'UserId': '1f0b33ee-223c-4393-100a-08d6f80e19b2',
        'Category': "ios",
        "Image": base64Image,
      });

      var url = 'http://192.168.43.70:5000/api/reports/add';
      http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: data,
      );
      Navigator.popAndPushNamed(context, '/map');
      _showDialog(true);
    } else {
      _showDialog(false);
    }

    return currentLocation;
  }

  void _showDialog(bool ifprovided) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: ifprovided
              ? new Text("Sending complete")
              : new Text("Sending failed"),
          content: ifprovided
              ? new Text("Thank you for your cooperation")
              : new Text("Please provide a photo"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Ok"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> makePhoto() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    imagePath = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => TakePictureScreen(camera: firstCamera)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.0),
        child: AppBar(
          title: Text('Lugar'),
          backgroundColor: Colors.red,
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Flexible(
              child: Container(
                margin: EdgeInsets.all(8.0),
                child: imagePath == ""
                    ? Text(
                        'Provide photo            ',
                      )
                    : Image.file(File(imagePath), fit: BoxFit.fill),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                maxLength: 100,
                minLines: 3,
                maxLines: 3,
                onChanged: (text) {
                  setState(() {
                    description_text = text;
                  });
                },
                decoration: InputDecoration(
                  helperText: "Description",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RaisedButton(
                    onPressed: () {
                      makePhoto();
                    },
                    color: Colors.red,
                    child: Text(
                      "Take a photo",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                )))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add Photo',
        child: Text(
          'Send',
        ),
        onPressed: () {
          _getLocation().then((value) {
            setState(() {
              userLocation = value;
            });
          });
          FocusScope.of(context).detach();
          //Navigator.of(context).pop();
        },
      ),
    );
  }
}
