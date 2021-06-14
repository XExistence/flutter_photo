import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Logo extends StatefulWidget {
  double width;
  double height;
  double padding = 20;
  Brightness brightness = Brightness.dark;
  Color color = Colors.white;

  Logo({this.width = 50, this.height = 50, this.padding = 20,this.brightness = Brightness.dark,this.color = Colors.white});

  @override
  _LogoState createState() => _LogoState();
}

class _LogoState extends State<Logo> {
  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: EdgeInsets.all(this.widget.padding),
      child: Container(
        width: this.widget.width,
        height: this.widget.height,
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: <Widget>[
            Center(
              child:
              Image.asset('assets/images/shadow1.png',
                  color: widget.brightness == Brightness.dark? Color.fromRGBO(0, 0, 0, 0.7) : Color.fromRGBO(0, 0, 0, 0.5)),
            ),

            Center(
              child: Image.asset('assets/images/base1.png',
                  color: widget.color),
            ),

            Center(
              child: Image.asset('assets/images/shadow2.png',
                  color: widget.brightness == Brightness.dark? Color.fromRGBO(0, 0, 0, 0.7) : Color.fromRGBO(0, 0, 0, 0.5)),
            ),

            Center(
              child: Image.asset('assets/images/base2.png',
                  color: Color.fromRGBO(
                      widget.color.red,
                      widget.color.green,
                      widget.color.blue,
                      0.6)),
            ),
          ],
        ),
      ),
    );
  }
}
