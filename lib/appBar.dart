import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ConstAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: AppBar(
            title: Text('Lugar'),
            backgroundColor: Colors.red,        
          ),
        );
  }
}