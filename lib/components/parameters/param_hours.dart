import 'package:cron_expression_editor/constants.dart';
import 'package:cron_expression_editor/cron/cron_helper.dart';
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
    _cronHoursExpression = state.cronExpression.split(" ")[1];
    _cronHoursMode = getCronHoursMode(_cronHoursExpression);
    _n_hour_value =
        getEveryNHoursValue(_cronHoursMode, _cronHoursExpression);
    _selected_hours =
        getSelectedHoursValues(_cronHoursMode, _cronHoursExpression);

    return createHoursSelector(context, state, ref);
  }

  Widget createHoursSelector(
      BuildContext context, CronExpressionModel state, WidgetRef ref) {
    var t = AppLocalizations.of(context);

    return DefaultTabController(
        length: 3,
        child: Column(
          children: [
            const SizedBox(height: 10),
            Row(
              children: [
                createSubCronExpressionLabel('${state.hours}', COLOR_HOURS)
              ],
            ),
            SizedBox(
              height: 10,
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
                      t!.every_hour,
                      style: TextStyle(fontSize: 18.0),
                    ),
                    style: ButtonStyle(
                      backgroundColor:
                      MaterialStateProperty.resolveWith<Color?>(
                            (Set<MaterialState> states) {
                          if (_cronHoursMode ==
                              CronHoursMode.EVERY_HOUR) {
                            return COLOR_PARAM_MODE_ACTIVE_BUTTON_BACKGROUND;
                          }
                          return COLOR_PARAM_MODE_INACTIVE_BUTTON_BACKGROUND; // defer to the defaults
                        },
                      ),
                      foregroundColor:
                      MaterialStateProperty.resolveWith<Color?>(
                              (Set<MaterialState> states) {
                            if (_cronHoursMode == CronHoursMode.EVERY_HOUR) {
                              return COLOR_PARAM_MODE_ACTIVE_BUTTON_FOREGROUND;
                            }
                            return COLOR_PARAM_MODE_INACTIVE_BUTTON_FOREGROUND; // defer to the defaults
                          }),
                    ),
                    onPressed: () {
                      setState(() {
                        _cronHoursMode = CronHoursMode.EVERY_HOUR;
                        calculateCronHoursExpression();
                        notifier.setHours(_cronHoursExpression);
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

  Widget createEveryNHourContent() {
    final notifier = ref.read(cronExpressionProvider.notifier);

    return Column(children: [
      const SizedBox(height: 10),
      Container(
        padding: const EdgeInsets.all(10.0),
        child: Row(children: [
          Expanded(
            child: Slider(
              value: _n_hour_value,
              min: CRON_HOURS_EVERY_N_MIN,
              max: CRON_HOURS_EVERY_N_MAX,
              divisions: CRON_HOURS_EVERY_N_MAX.round(),
              label: _n_hour_value.round().toString(),
              onChanged: (double value) {
                setState(() {
                  _n_hour_value = value;
                  _cronHoursMode = CronHoursMode.EVERY_N_HOURS;
                  calculateCronHoursExpression();
                  resetOtherModes();
                  notifier.setHours(_cronHoursExpression);
                });
              },
              inactiveColor: _cronHoursMode == CronHoursMode.EVERY_N_HOURS
                  ? COLOR_PARAM_MODE_ACTIVE_GENERAL
                  : COLOR_PARAM_MODE_INACTIVE_GENERAL,
              activeColor: _cronHoursMode == CronHoursMode.EVERY_N_HOURS
                  ? COLOR_PARAM_MODE_ACTIVE_GENERAL
                  : COLOR_PARAM_MODE_INACTIVE_GENERAL,
              thumbColor: _cronHoursMode == CronHoursMode.EVERY_N_HOURS
                  ? COLOR_PARAM_MODE_ACTIVE_GENERAL
                  : COLOR_PARAM_MODE_INACTIVE_GENERAL,
            ),
          ),
        ]),
      )
    ]);
  }

  Widget createSelectedHoursContent() {
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
                children: generateHourSelection(notifier),
              )))
    ]);
  }

  List<Widget> generateHourSelection(CronExpressionNotifier notifier) {
    List<Widget> rows = [];

    int hourCount = 0;
    for (var i = 0; i < 3; i++) {
      List<Widget> hourButtons = [];
      for (var j = 0; j < 10 && hourCount <= CRON_HOURS_MAX; j++) {
        int hourValue = i * 10 + j;
        OutlinedButton hourButton = new OutlinedButton(
          child: Text(
            hourValue.toString(),
            style: TextStyle(fontSize: 16.0),
          ),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                    (Set<MaterialState> states) {
                  if (_selected_hours[hourValue]) {
                    return COLOR_PARAM_MODE_ACTIVE_BUTTON_BACKGROUND;
                  }
                  return COLOR_PARAM_MODE_INACTIVE_BUTTON_BACKGROUND; // defer to the defaults
                },
              ), foregroundColor: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                if (_selected_hours[hourValue]) {
                  return COLOR_PARAM_MODE_ACTIVE_BUTTON_FOREGROUND;
                }
                return COLOR_PARAM_MODE_INACTIVE_BUTTON_FOREGROUND; // defer to the defaults
              })),
          onPressed: () {
            setState(() {
              _selected_hours[hourValue] = !_selected_hours[hourValue];
              _cronHoursMode = CronHoursMode.SELECTED_HOURS;
              calculateCronHoursExpression();
              notifier.setHours(_cronHoursExpression);

              resetOtherModes();
            });
          },
        );
        hourButtons.add(hourButton);
        hourCount++;
      }
      rows.add(new Wrap(
          direction: Axis.horizontal,
          alignment: WrapAlignment.start,
          spacing: 10,
          children: hourButtons));
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
        for (var i = 0; i <= CRON_HOURS_MAX; i++) {
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
      for (var i = 0; i < _selected_hours.length; i++) {
        _selected_hours[i] = false;
      }
    }
    if (_cronHoursMode != CronHoursMode.EVERY_N_HOURS) {
      _n_hour_value = CRON_HOURS_EVERY_N_MIN;
    }
  }
}

