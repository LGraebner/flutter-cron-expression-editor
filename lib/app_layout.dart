import 'package:cron_expression_editor/components/cron_expression.dart';
import 'package:cron_expression_editor/components/parameters/param_caroussel.dart';
import 'package:cron_expression_editor/helper/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'components/cron_schedule.dart';

class AppLayout extends StatefulWidget {
  const AppLayout({super.key, required this.title});

  final String title;

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
            appBar: AppBar(
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
            title: Text(widget.title),
                actions: [

                PopupMenuButton(
            icon: Icon(Icons.more_vert, color: Colors.white, size: 35,),

                // add icon, by default "3 dot" icon
                // icon: Icon(Icons.book)

                itemBuilder: (context){
    return [
    PopupMenuItem<int>(
    value: 0,
    child: Text("My Account"),
    ),

    PopupMenuItem<int>(
    value: 1,
    child: Text("Settings"),
    ),

    PopupMenuItem<int>(
    value: 2,
    child: Text("Logout"),
    ),
    ];
    },
        onSelected:(value){
          if(value == 0){
            print("My account menu is selected.");
          }else if(value == 1){
            print("Settings menu is selected.");
          }else if(value == 2){
            print("Logout menu is selected.");
          }
        }
    )],
        ),
        body: Row(children: [
      Expanded(
          flex: 7,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            createHeading('Cron Expression', Icons.auto_awesome, CronExpressionDisplay()),
            createHeading('Parameters', Icons.tune, ParamCaroussel())
          ])),
      Expanded(
          flex: 3,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [createHeading('Schedule', Icons.schedule, CronSchedule())]))
    ]));
  }
}
