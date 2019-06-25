import 'dart:async';
import 'dart:convert';
import 'dart:io' as Io;
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/rendering.dart';
import 'mapPage.dart';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'camera.dart';

class ReportPage extends StatefulWidget {
  String imagePath;

  ReportPage({
    Key key,
    this.title,
    @required this.imagePath,
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
  //String imagePath = "";
  bool descriptionVisible = true;

  Future<Map<String, double>> _getLocation() async {
    var currentLocation = <String, double>{};
    try {
      currentLocation = await location.getLocation();
    } catch (e) {
      currentLocation = null;
    }
    userLocation = currentLocation;

    if (widget.imagePath != "") {
      File imageFile = new File(widget.imagePath);
      List<int> imageBytes = imageFile.readAsBytesSync(); //working but huge
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
        'Longitude': userLocation["longitude"].toString(),
        'Latitude': userLocation["latitude"].toString(),
        'UserId': 'a76f467e-7373-454b-27d8-08d6f8c36bad',
        'Category': "ios",
        "Photo": base64Image,
      });

      var url = 'https://lugarapi.azurewebsites.net/api/reports/add';
      http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: data,
      );
      Navigator.pushReplacementNamed(context, '/map');
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

    widget.imagePath = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => TakePictureScreen(camera: firstCamera)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            //child: Text("camera"),
            child: new Image.file(File(widget.imagePath), fit: BoxFit.fill),
          ),
          Positioned.fill(
              child: Flex(
            direction: Axis.vertical,
            children: <Widget>[
              // FloatingActionButton(
              //   tooltip: 'Add Photo',
              //   child: Text(
              //     'Send',
              //   ),
              //   onPressed: () {
              //     _getLocation().then((value) {
              //       setState(() {
              //         userLocation = value;
              //       });
              //     });
              //     FocusScope.of(context).detach();
              //     //Navigator.of(context).pop();
              //   },
              // ),
              // Align(
              //         alignment: Alignment.bottomRight,
              //       ),
              Expanded(
                child: Opacity(
                  opacity: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextField(),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: descriptionVisible == false
                    ? null
                    : AnimatedOpacity(
                        opacity:
                            0.5, //nie animuje si� oczywi�cie, bo nie jest 0 wczejsniej tylko nie isntije
                        duration: new Duration(seconds: 3),
                        child: Stack(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(30.0),
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
                                  fillColor: Color.fromARGB(255, 255, 255, 255),
                                  filled: true,
                                  helperText: "Description",
                                  helperStyle: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 0, 0, 0),
                                      shadows: [
                                        Shadow(
                                            // bottomLeft
                                            offset: Offset(-1.5, -1.5),
                                            color: Colors.white),
                                        Shadow(
                                            // bottomRight
                                            offset: Offset(1.5, -1.5),
                                            color: Colors.white),
                                        Shadow(
                                            // topRight
                                            offset: Offset(1.5, 1.5),
                                            color: Colors.white),
                                        Shadow(
                                            // topLeft
                                            offset: Offset(-1.5, 1.5),
                                            color: Colors.white),
                                      ]),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              //   Stack(
                              //   children: <Widget>[
                              //     Positioned.fill(
                              //       child: TextField()
                              //     )
                              //   ],
                              // )
                            ),
                          ],
                        ),
                      ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: RaisedButton(
                  onPressed: () {
                    makePhoto();
                  },
                  color: Colors.red,
                  child: Text(
                    "Retake photo",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              )
            ],
          )),
        ],
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
      // floatingActionButton: FloatingActionButton(
      //     child: Text("photo"),
      //     onPressed: () {
      //       setState(() {
      //         descriptionVisible = true;
      //       });
      //     }),
    );
  }
}
/*
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
                child: widget.imagePath == ""
                    ? Text(
                        'Provide photo            ',
                      )
                    : Image.file(File(widget.imagePath), fit: BoxFit.fill),
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
*/
