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
          title: Text(widget.title),
        ),
        body: Row(
            children: [
              Expanded(
                  flex: 7,
                  child: ListView(
                      // crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        createHeading('Cron Expression', Icons.auto_awesome,
                            CronExpressionDisplay()),
                        createHeading('Parameters', Icons.tune, ParamCaroussel(), 770)
                      ])),
              Expanded(
                  flex: 3,
                  child: ListView(
                      // crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        createHeading('Schedule', Icons.schedule, CronSchedule(), 950)
                      ]))
            ])
    );
  }
}
