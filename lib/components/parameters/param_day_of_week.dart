import 'package:cron_expression_editor/helper/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants.dart';
import '../../cron/cron_helper.dart';
import '../../cron/cron_modes.dart';
import '../../helper/button_factory.dart';
import '../../state/cron_expression_model.dart';
import '../../state/cron_expression_notifier.dart';
import '../../state/state_providers.dart';

const dayOfWeekMap = {
  1 : 'MONDAY',
  2 : 'TUESDAY',
  3 : 'WEDNESDAY',
  4 : 'THURSDAY',
  5 : 'FRIDAY',
  6 : 'SATURDAY',
  7 : 'SUNDAY',
};

class ParamDayOfWeek extends ConsumerStatefulWidget {
  const ParamDayOfWeek({super.key});

  @override
  _ParamDayOfWeekState createState() => _ParamDayOfWeekState();
}

class _ParamDayOfWeekState extends ConsumerState<ParamDayOfWeek> {
  late String _cronDayOfWeekExpression;
  late CronDayOfWeekMode _cronDayOfWeekMode;

  late List<bool> _selected_days_of_week;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cronExpressionProvider) as CronExpressionModel;
    _cronDayOfWeekExpression = state.cronExpression.split(" ")[4];
    _cronDayOfWeekMode = getCronDayOfWeekMode(_cronDayOfWeekExpression);
    _selected_days_of_week =
        getSelectedDaysOfWeekValues(
            _cronDayOfWeekMode, _cronDayOfWeekExpression);

    return createDayOfWeekSelector(context, state, ref);
  }

  Widget createDayOfWeekSelector(BuildContext context,
      CronExpressionModel state, WidgetRef ref) {
    var t = AppLocalizations.of(context);

    return DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const SizedBox(height: 10),
            Row(
              children: [
                createSubCronExpressionLabel(
                    '${state.dayOfWeek}', COLOR_DAY_OF_WEEK)
              ],
            ),
            SizedBox(
              height: 10,
            ),
            TabBar(
              labelColor: Colors.black,
              tabs: [
                Tab(text: t!.every_day_of_week),
                Tab(text: t!.selected_day_of_week),
              ],
            ),
            Expanded(
                child: TabBarView(children: [
                  createEveryDayOfWeekContent(),
                  createSelectedDaysOfWeekContent()
                ]))
          ],
        ));
  }


  Widget createEveryDayOfWeekContent() {
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
                      t!.every_day_of_week,
                      style: TextStyle(fontSize: 18.0),
                    ),
                    style: ButtonStyle(
                      backgroundColor:
                      MaterialStateProperty.resolveWith<Color?>(
                            (Set<MaterialState> states) {
                          if (_cronDayOfWeekMode ==
                              CronDayOfWeekMode.EVERY_DAY_OF_WEEK) {
                            return COLOR_PARAM_MODE_ACTIVE_BUTTON_BACKGROUND;
                          }
                          return COLOR_PARAM_MODE_INACTIVE_BUTTON_BACKGROUND; // defer to the defaults
                        },
                      ),
                      foregroundColor:
                      MaterialStateProperty.resolveWith<Color?>(
                              (Set<MaterialState> states) {
                            if (_cronDayOfWeekMode ==
                                CronDayOfWeekMode.EVERY_DAY_OF_WEEK) {
                              return COLOR_PARAM_MODE_ACTIVE_BUTTON_FOREGROUND;
                            }
                            return COLOR_PARAM_MODE_INACTIVE_BUTTON_FOREGROUND; // defer to the defaults
                          }),
                    ),
                    onPressed: () {
                      setState(() {
                        _cronDayOfWeekMode = CronDayOfWeekMode.EVERY_DAY_OF_WEEK;
                        calculateCronDayOfWeekExpression();
                        notifier.setDayOfWeek(_cronDayOfWeekExpression);
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

  Widget createSelectedDaysOfWeekContent() {
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
                children: generateDayOfWeekSelection(notifier),
              )))
    ]);
  }

  List<Widget> generateDayOfWeekSelection(CronExpressionNotifier notifier) {
    List<Widget> rows = [];

    int mod = 3;
    List<Widget> dayOfWeekButtons = [];
    for (var i = CRON_DAY_OF_WEEK_MIN; i <= CRON_DAY_OF_WEEK_MAX; i++) {
      int dayOfWeekValue = i.toInt();
      SizedBox dayOfWeekButton = new SizedBox(width: 150, child:
      OutlinedButton(
          child: Text(
            dayOfWeekMap[dayOfWeekValue].toString().capitalize(),
            style: TextStyle(fontSize: 16.0),
          ),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                    (Set<MaterialState> states) {
                  if (_selected_days_of_week[dayOfWeekValue]) {
                    return COLOR_PARAM_MODE_ACTIVE_BUTTON_BACKGROUND;
                  }
                  return COLOR_PARAM_MODE_INACTIVE_BUTTON_BACKGROUND; // defer to the defaults
                },
              ), foregroundColor: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                if (_selected_days_of_week[dayOfWeekValue]) {
                  return COLOR_PARAM_MODE_ACTIVE_BUTTON_FOREGROUND;
                }
                return COLOR_PARAM_MODE_INACTIVE_BUTTON_FOREGROUND; // defer to the defaults
              })),
          onPressed: () {
            setState(() {
              _selected_days_of_week[dayOfWeekValue] = !_selected_days_of_week[dayOfWeekValue];
              _cronDayOfWeekMode = CronDayOfWeekMode.SELECTED_DAYS_OF_WEEK;
              calculateCronDayOfWeekExpression();
              notifier.setDayOfWeek(_cronDayOfWeekExpression);

              resetOtherModes();
            });
          },
          onLongPress: () {
            setState(() {
              _selected_days_of_week[dayOfWeekValue] = !_selected_days_of_week[dayOfWeekValue];
              _cronDayOfWeekMode = CronDayOfWeekMode.SELECTED_DAYS_OF_WEEK;
              calculateCronDayOfWeekExpression();
              notifier.setDayOfWeek(_cronDayOfWeekExpression);

              resetOtherModes();
            });
          }));
      dayOfWeekButtons.add(dayOfWeekButton);
      if (i % mod == 0 || i == CRON_DAY_OF_WEEK_MAX) {
        rows.add(Wrap(
            direction: Axis.horizontal,
            alignment: WrapAlignment.start,
            spacing: 10,
            children: dayOfWeekButtons));
        dayOfWeekButtons = [];
      }
    }

    return rows;
  }

  void calculateCronDayOfWeekExpression() {
    switch (_cronDayOfWeekMode) {
      case CronDayOfWeekMode.EVERY_DAY_OF_WEEK:
        _cronDayOfWeekExpression = '*';
        break;
      case CronDayOfWeekMode.SELECTED_DAYS_OF_WEEK:
        String tmpString = '';
        bool firstValue = true;
        for (var i = 0; i <= (CRON_DAY_OF_WEEK_MAX + CRON_DAY_OF_WEEK_MIN); i++) {
          if (_selected_days_of_week[i] == true) {
            if (firstValue) {
              firstValue = false;
            } else {
              tmpString += ',';
            }
            tmpString += i.toString();
          }
        }
        if (!tmpString.isEmpty) {
          _cronDayOfWeekExpression = tmpString;
        } else {
          _cronDayOfWeekMode = CronDayOfWeekMode.EVERY_DAY_OF_WEEK;
          calculateCronDayOfWeekExpression();
        }
    }
  }

  void resetOtherModes() {
    if (_cronDayOfWeekMode != CronDayOfWeekMode.SELECTED_DAYS_OF_WEEK) {
      for (var i = 0; i < _selected_days_of_week.length; i++) {
        _selected_days_of_week[i] = false;
      }
    }
  }
}
