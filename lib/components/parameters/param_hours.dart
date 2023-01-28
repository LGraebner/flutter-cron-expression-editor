import 'package:cron_expression_editor/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../cron/cron_modes.dart';
import '../../helper/button_factory.dart';
import '../../state/cron_expression_model.dart';
import '../../state/cron_expression_notifier.dart';
import '../../state/state_providers.dart';

class ParamHours extends ConsumerStatefulWidget {
  const ParamHours({super.key});

  @override
  _ParamHoursState createState() => _ParamHoursState();
}

class _ParamHoursState extends ConsumerState<ParamHours> {
  late String _cronHoursExpression;
  late CronHoursMode _cronHoursMode;

  late double _n_hour_value;
  late List<bool> _selected_hours;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cronExpressionProvider) as CronExpressionModel;
    _cronMinutesExpression = state.cronExpression.split(" ")[0];
    _cronMinutesMode = getCronMinutesMode(_cronMinutesExpression);
    _n_minute_value =
        getEveryNMinutesValue(_cronMinutesMode, _cronMinutesExpression);
    _selected_minutes =
        getSelectedMinutesValues(_cronMinutesMode, _cronMinutesExpression);

    return createMinutesSelector(context, state, ref);
  }

  Widget createMinutesSelector(
      BuildContext context, CronExpressionModel state, WidgetRef ref) {
    var t = AppLocalizations.of(context);

    return DefaultTabController(
        length: 3,
        child: Column(
          children: [
            const SizedBox(height: 10),
            Row(
              children: [
                createSubCronExpressionLabel('${state.minutes}', COLOR_MINUTES)
              ],
            ),
            SizedBox(
              height: 10,
            ),
            TabBar(
              labelColor: Colors.black,
              tabs: [
                Tab(text: t!.every_minute),
                Tab(text: t!.every_n_minutes),
                Tab(text: t!.selected_minutes),
              ],
            ),
            Expanded(
                child: TabBarView(children: [
                  createEveryMinuteContent(),
                  createEveryNMinuteContent(),
                  createSelectedMinutesContent()
                ]))
          ],
        ));
  }

  Widget createEveryMinuteContent() {
    var t = AppLocalizations.of(context);
    final notifier = ref.read(cronExpressionProvider.notifier);

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
                      t!.every_minute,
                      style: TextStyle(fontSize: 18.0),
                    ),
                    style: ButtonStyle(
                      backgroundColor:
                      MaterialStateProperty.resolveWith<Color?>(
                            (Set<MaterialState> states) {
                          if (_cronMinutesMode ==
                              CronMinutesMode.EVERY_MINUTE) {
                            return COLOR_PARAM_MODE_ACTIVE_BUTTON_BACKGROUND;
                          }
                          return COLOR_PARAM_MODE_INACTIVE_BUTTON_BACKGROUND; // defer to the defaults
                        },
                      ),
                      foregroundColor:
                      MaterialStateProperty.resolveWith<Color?>(
                              (Set<MaterialState> states) {
                            if (_cronMinutesMode == CronMinutesMode.EVERY_MINUTE) {
                              return COLOR_PARAM_MODE_ACTIVE_BUTTON_FOREGROUND;
                            }
                            return COLOR_PARAM_MODE_INACTIVE_BUTTON_FOREGROUND; // defer to the defaults
                          }),
                    ),
                    onPressed: () {
                      setState(() {
                        _cronMinutesMode = CronMinutesMode.EVERY_MINUTE;
                        calculateCronMinutesExpression();
                        notifier.setMinutes(_cronMinutesExpression);
                        resetOtherModes();
                      });
                    },
                  ),
                ),
              ],
            )),
      ],
    );
  }

  Widget createEveryNMinuteContent() {
    final notifier = ref.read(cronExpressionProvider.notifier);

    return Column(children: [
      const SizedBox(height: 10),
      Container(
        padding: const EdgeInsets.all(10.0),
        child: Row(children: [
          Expanded(
            child: Slider(
              value: _n_minute_value,
              min: CRON_MINUTES_SLIDER_MIN,
              max: CRON_MINUTES_SLIDER_MAX,
              divisions: CRON_MINUTES_SLIDER_DIVISIONS,
              label: _n_minute_value.round().toString(),
              onChanged: (double value) {
                setState(() {
                  _n_minute_value = value;
                  _cronMinutesMode = CronMinutesMode.EVERY_N_MINUTES;
                  calculateCronMinutesExpression();
                  resetOtherModes();
                  notifier.setMinutes(_cronMinutesExpression);
                });
              },
              inactiveColor: _cronMinutesMode == CronMinutesMode.EVERY_N_MINUTES
                  ? COLOR_PARAM_MODE_ACTIVE_GENERAL
                  : COLOR_PARAM_MODE_INACTIVE_GENERAL,
              activeColor: _cronMinutesMode == CronMinutesMode.EVERY_N_MINUTES
                  ? COLOR_PARAM_MODE_ACTIVE_GENERAL
                  : COLOR_PARAM_MODE_INACTIVE_GENERAL,
              thumbColor: _cronMinutesMode == CronMinutesMode.EVERY_N_MINUTES
                  ? COLOR_PARAM_MODE_ACTIVE_GENERAL
                  : COLOR_PARAM_MODE_INACTIVE_GENERAL,
            ),
          ),
        ]),
      )
    ]);
  }

  Widget createSelectedMinutesContent() {
    final notifier = ref.read(cronExpressionProvider.notifier);

    return Column(children: [
      const SizedBox(height: 10),
      Container(
          padding: const EdgeInsets.all(10.0),
          child: new Align(
              alignment: Alignment.topLeft,
              child: Wrap(
                direction: Axis.vertical,
                spacing: 10,
                children: generateMinuteSelection(notifier),
              )))
    ]);
  }

  List<Widget> generateMinuteSelection(CronExpressionNotifier notifier) {
    List<Widget> rows = [];

    for (var i = 0; i < 6; i++) {
      List<Widget> minuteButtons = [];
      for (var j = 0; j < 10; j++) {
        int minuteValue = i * 10 + j;
        OutlinedButton minuteButton = new OutlinedButton(
          child: Text(
            minuteValue.toString(),
            style: TextStyle(fontSize: 16.0),
          ),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                    (Set<MaterialState> states) {
                  if (_selected_minutes[minuteValue]) {
                    return COLOR_PARAM_MODE_ACTIVE_BUTTON_BACKGROUND;
                  }
                  return COLOR_PARAM_MODE_INACTIVE_BUTTON_BACKGROUND; // defer to the defaults
                },
              ), foregroundColor: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                if (_selected_minutes[minuteValue]) {
                  return COLOR_PARAM_MODE_ACTIVE_BUTTON_FOREGROUND;
                }
                return COLOR_PARAM_MODE_INACTIVE_BUTTON_FOREGROUND; // defer to the defaults
              })),
          onPressed: () {
            setState(() {
              _selected_minutes[minuteValue] = !_selected_minutes[minuteValue];
              _cronMinutesMode = CronMinutesMode.SELECTED_MINUTES;
              calculateCronMinutesExpression();
              notifier.setMinutes(_cronMinutesExpression);

              resetOtherModes();
            });
          },
        );
        minuteButtons.add(minuteButton);
      }
      rows.add(new Wrap(
          direction: Axis.horizontal,
          alignment: WrapAlignment.start,
          spacing: 10,
          children: minuteButtons));
    }

    return rows;
  }

  void calculateCronMinutesExpression() {
    switch (_cronMinutesMode) {
      case CronMinutesMode.EVERY_MINUTE:
        _cronMinutesExpression = '*';
        break;
      case CronMinutesMode.EVERY_N_MINUTES:
        _cronMinutesExpression = '*/' + _n_minute_value.round().toString();
        break;
      case CronMinutesMode.SELECTED_MINUTES:
        String tmpString = '';
        bool firstValue = true;
        for (var i = 0; i < 60; i++) {
          if (_selected_minutes[i] == true) {
            if (firstValue) {
              firstValue = false;
            } else {
              tmpString += ',';
            }
            tmpString += i.toString();
          }
        }
        if (!tmpString.isEmpty) {
          _cronMinutesExpression = tmpString;
        } else {
          _cronMinutesMode = CronMinutesMode.EVERY_MINUTE;
          calculateCronMinutesExpression();
        }
    }
  }

  void resetOtherModes() {
    if (_cronMinutesMode != CronMinutesMode.SELECTED_MINUTES) {
      for (var i = 0; i < _selected_minutes.length; i++) {
        _selected_minutes[i] = false;
      }
    }
    if (_cronMinutesMode != CronMinutesMode.EVERY_N_MINUTES) {
      _n_minute_value = 0;
    }
  }
}


CronMinutesMode getCronMinutesMode(String cronMinutesExpression) {
  if (cronMinutesExpression == '*') {
    return CronMinutesMode.EVERY_MINUTE;
  }
  if (cronMinutesExpression.contains('*/')) {
    return CronMinutesMode.EVERY_N_MINUTES;
  }

  return CronMinutesMode.SELECTED_MINUTES;
}

double getEveryNMinutesValue(
    CronMinutesMode cronMinutesMode, String cronMinutesExpression) {
  if (cronMinutesMode == CronMinutesMode.EVERY_N_MINUTES) {
    return double.parse(cronMinutesExpression.split("*/")[1]);
  } else {
    return 1;
  }
}

List<bool> getSelectedMinutesValues(
    CronMinutesMode cronMinutesMode, String cronMinutesExpression) {
  List<bool> selectedMinutes = [];
  for (var i = 0; i < 60; i++) {
    selectedMinutes.add(false);
  }

  if (cronMinutesMode == CronMinutesMode.SELECTED_MINUTES) {
    List<int> minutes =
    cronMinutesExpression.split(',').map((e) => int.parse(e)).toList();
    for (var i in minutes) {
      selectedMinutes[i] = true;
    }
  }

  return selectedMinutes;
}
