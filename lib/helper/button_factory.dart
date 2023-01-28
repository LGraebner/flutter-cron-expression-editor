import 'dart:ui';

import 'package:cron_expression_editor/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Widget createMainButton(IconData iconData, void Function() pressFunction) {
  return Container(
      child: IconButton(
          onPressed: () => pressFunction, icon: Icon(iconData, size: 30)));
}

Widget createClipboardButton() {
  return Container(
      child: IconButton(
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: "your text"));
            // copied successfully
          },
          icon: Icon(Icons.content_copy, size: 30)));
}

Widget createMainCronExpressionLabel(String cronExpression, double fontSize) {
  List<String> cronItems = cronExpression.split(" ");
  List<Color> colors = [
    COLOR_MINUTES,
    COLOR_HOURS,
    COLOR_DAY_OF_MONTH,
    COLOR_MONTH,
    COLOR_DAY_OF_WEEK
  ];
  List<String> captions = [
    'Minutes',
    'Hours',
    'Day of Month',
    'Month',
    'Day of Week'
  ];

  List<Widget> cronValueFields = [];
  for (var i = 0; i < 5; i++) {
    cronValueFields
        .add(createMainCronValueField(captions[i], cronItems[i], colors[i]));
  }

  return Expanded(
      child: Container(
          padding: const EdgeInsets.all(10.0),
          margin: const EdgeInsets.only(top: 5.0),
          decoration: BoxDecoration(
            color: Colors.white70,
            border: Border.all(
              color: Colors.black12,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(5),
          ),
          child:

              Row(
                verticalDirection: VerticalDirection.down,
                children: cronValueFields,
              )
            ,
          ));
}

Widget createSubCronExpressionLabel(String subCronExpression, Color color) {
  return Expanded(
      child: Container(
          padding: const EdgeInsets.all(10.0),
          margin: const EdgeInsets.only(top: 5.0),
          decoration: BoxDecoration(
            color: Colors.white70,
            border: Border.all(
              color: Colors.blueAccent,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(5),
          ),
          child: createSubCronValueField(subCronExpression)));
}

Widget createMainCronValueField(String caption, String value, Color color) {
  return Container(
      margin: const EdgeInsets.only(left: 10.0),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 20, color: color, fontWeight: FontWeight.bold)),
          SizedBox(
            height: 7,
          ),
          Text(
            caption,
            style: TextStyle(
                fontSize: 10, color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ));
}

Widget createSubCronValueField(String value) {
  return Container(
    margin: const EdgeInsets.only(left: 10.0),
    child: Text(value,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
  );
}
