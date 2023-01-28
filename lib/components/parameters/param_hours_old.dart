import 'package:cron_expression_editor/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../helper/button_factory.dart';
import '../../state/cron_expression_model.dart';
import '../../state/state_providers.dart';

final int MAX_HOURS = 23;

class ParamHours extends StatefulWidget {
  const ParamHours({super.key});

  @override
  State<ParamHours> createState() => _ParamHoursState();
}

class _ParamHoursState extends State<ParamHours> {

  String _cronHoursExpression = '*';
  CronHoursMode _cronHoursMode = CronHoursMode.EVERY_HOUR;

  double _n_hour_value = 20;
  List<bool> _selected_hours = createSelectedHoursValues();



  final cronMinutesExpressionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return createMinutesSelector(context);
  }

  Widget createMinutesSelector(BuildContext context) {
    var t = AppLocalizations.of(context);

    return DefaultTabController(
        length: 3,
        child: Column(
          children: [
            const SizedBox(height: 10),
            Row(
              children: [
                Consumer(builder: (_, WidgetRef ref, __) {
                  final state =
                  ref.watch(cronExpressionProvider) as CronExpressionModel;
                  return createSubCronExpressionLabel('${state.hours}', COLOR_HOURS);
                }),
              ],
            ),
            TabBar(
              labelColor: Colors.black,
              tabs: [
                Tab(text: t!.every_hour),
                Tab(text: t!.every_n_hours),
                Tab(text: t!.selected_hours),
              ],
            ),
            Expanded(
                child: TabBarView(children: [
                  createEveryHourContent(),
                  createEveryNHourContent(),
                  createSelectedHoursContent()
                ]))
          ],
        ));
  }

  Widget createEveryHourContent() {
    var t = AppLocalizations.of(context);

    return Column(
      children: [
        const SizedBox(height: 10),
        Container(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                    child: OutlinedButton(
                      child: Text(
                        t!.every_hour,
                        style: TextStyle(fontSize: 18.0),
                      ),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                              (Set<MaterialState> states) {
                            if (_cronHoursMode == CronHoursMode.EVERY_HOUR) {
                              return Colors.blueAccent;
                            }
                            return Colors.white; // defer to the defaults
                          },
                        ),
                        foregroundColor: MaterialStateProperty.resolveWith<Color?>(
                                (Set<MaterialState> states) {
                              if (_cronHoursMode == CronHoursMode.EVERY_HOUR) {
                                return Colors.white;
                              }
                              return Colors.black54; // defer to the defaults
                            }),
                      ),
                      onPressed: () {
                        setState(() {
                          _cronHoursMode = CronHoursMode.EVERY_HOUR;
                          calculateCronHoursExpression();
                          resetOtherModes();
                        });
                      },
                    )),
              ],
            )),
      ],
    );
  }

  Widget createEveryNHourContent() {
    return Column(children: [
      const SizedBox(height: 10),
      Container(
        padding: const EdgeInsets.all(10.0),
        child: Row(children: [
          Expanded(
            child: Slider(

              value: _n_hour_value,
              max: 59,
              divisions: 60,
              label: _n_hour_value.round().toString(),
              onChanged: (double value) {
                setState(() {
                  _n_hour_value = value;
                  _cronHoursMode = CronHoursMode.EVERY_N_HOURS;
                  calculateCronHoursExpression();
                  resetOtherModes();
                });
              },
              inactiveColor: _cronHoursMode == CronHoursMode.EVERY_N_HOURS ? Colors.blueAccent : Colors.grey,
              activeColor: _cronHoursMode == CronHoursMode.EVERY_N_HOURS ? Colors.blueAccent : Colors.grey,
              thumbColor: _cronHoursMode == CronHoursMode.EVERY_N_HOURS ? Colors.blueAccent : Colors.grey,
            ),
          ),
        ]),
      ),
    ]);
  }

  Widget createSelectedHoursContent() {
    return Column(children: [
      const SizedBox(height: 10),
      Container(
          padding: const EdgeInsets.all(10.0),
          child: new Align(
              alignment: Alignment.topLeft,
              child: Wrap(
                direction: Axis.vertical,
                spacing: 10,
                children: generateHourSelection(),
              )))
    ]);
  }

  List<Widget> generateHourSelection() {
    List<Widget> rows = [];

    int hourCount = 0;
    for (var i = 0; i < 3; i++) {
      List<Widget> minuteButtons = [];
      for (var j = 0; j < 10 && hourCount <= MAX_HOURS; j++) {

        int hourValue = i * 10 + j;
        OutlinedButton minuteButton = new OutlinedButton(
          child: Text(
            hourValue.toString(),
            style: TextStyle(fontSize: 16.0),
          ),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                    (Set<MaterialState> states) {
                  if (_selected_hours[hourValue]) {
                    return Colors.blueAccent;
                  }
                  return Colors.white; // defer to the defaults
                },
              ), foregroundColor: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                if (_selected_hours[hourValue]) {
                  return Colors.white;
                }
                return Colors.black54; // defer to the defaults
              })),
          onPressed: () {
            setState(() {
              _selected_hours[hourValue] = !_selected_hours[hourValue];
              _cronHoursMode = CronHoursMode.SELECTED_HOURS;
              calculateCronHoursExpression();
              resetOtherModes();
            });
          },
        );
        minuteButtons.add(minuteButton);
        hourCount++;
      }
      rows.add(new Wrap(
          direction: Axis.horizontal,
          alignment: WrapAlignment.start,
          spacing: 10,
          children: minuteButtons));
    }

    return rows;
  }

  void calculateCronHoursExpression() {
    switch (_cronHoursMode) {
      case CronHoursMode.EVERY_HOUR:
        _cronHoursExpression = '*';
        break;
      case CronHoursMode.EVERY_N_HOURS:
        _cronHoursExpression = '*/' + _n_hour_value.round().toString();
        break;
      case CronHoursMode.SELECTED_HOURS:
        String tmpString = '';
        bool firstValue = true;
        for (var i=0; i<=MAX_HOURS; i++) {
          if (_selected_hours[i] == true) {
            if (firstValue) {
              firstValue = false;
            } else {
              tmpString += ',';
            }
            tmpString += i.toString();
          }
        }
        if (!tmpString.isEmpty) {
          _cronHoursExpression = tmpString;
        } else {
          _cronHoursMode = CronHoursMode.EVERY_HOUR;
          calculateCronHoursExpression();
        }
    }
  }

  void resetOtherModes() {
    if (_cronHoursMode != CronHoursMode.SELECTED_HOURS) {
      for (var i=0; i < _selected_hours.length; i++) {
        _selected_hours[i] = false;
      }
    }
    if (_cronHoursMode != CronHoursMode.EVERY_N_HOURS) {
      _n_hour_value = 0;
    }
  }
}

List<bool> createSelectedHoursValues() {
  List<bool> selectedHours = [];
  for (var i = 0; i <= MAX_HOURS; i++) {
    selectedHours.add(false);
  }

  return selectedHours;
}

enum CronHoursMode {
  EVERY_HOUR,
  EVERY_N_HOURS,
  SELECTED_HOURS
}
