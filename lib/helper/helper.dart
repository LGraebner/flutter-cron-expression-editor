import 'package:flutter/material.dart';

Widget createHeading(String title, IconData iconData, Widget child, [ double? height ]) {
  return Container(
      margin: const EdgeInsets.all(10.0),

      decoration: BoxDecoration(border: Border.all(color: Colors.blueAccent, width: 2), borderRadius: BorderRadius.circular(5)),
      child: Column(
        children: [
          Container(
              padding: const EdgeInsets.all(15.0),
              alignment: Alignment.topLeft,
              color: Colors.blueAccent,
              child: Row(children: [Icon(iconData, size: 25, color: Colors.white,), SizedBox(width: 15,), Text(
                title,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                    color: Colors.white),
              )],)),
          Container(
            padding: const EdgeInsets.all(15.0),
            height: height,
            child: child,
          )
        ],
      ));
}
