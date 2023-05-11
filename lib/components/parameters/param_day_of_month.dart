import 'package:cron_expression_editor/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../cron/cron_helper.dart';
import '../../cron/cron_modes.dart';
import '../../helper/button_factory.dart';
import '../../state/cron_expression_model.dart';
import '../../state/cron_expression_notifier.dart';
import '../../state/state_providers.dart';

class ParamDayOfMonth extends ConsumerStatefulWidget {
  const ParamDayOfMonth({super.key});

  @override
  _ParamDayOfMonthState createState() => _ParamDayOfMonthState();
}

class _ParamDayOfMonthState extends ConsumerState<ParamDayOfMonth> {
  late String _cronDayOfMonthExpression;
  late CronDayOfMonthMode _cronDayOfMonthMode;

  late List<bool> _selected_days;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cronExpressionProvider) as CronExpressionModel;
    _cronDayOfMonthExpression = state.cronExpression.split(" ")[2];
    _cronDayOfMonthMode = getCronDayOfMonthMode(_cronDayOfMonthExpression);
    _selected_days =
        getSelectedDaysValues(_cronDayOfMonthMode, _cronDayOfMonthExpression);

    return createDayOfMonthSelector(context, state, ref);
  }

  Widget createDayOfMonthSelector(
      BuildContext context, CronExpressionModel state, WidgetRef ref) {
    var t = AppLocalizations.of(context);

    return DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const SizedBox(height: 10),
            Row(
              children: [
                createSubCronExpressionLabel('${state.dayOfMonth}', COLOR_DAY_OF_MONTH)
              ],
            ),
            SizedBox(
              height: 10,
            ),
            TabBar(
              labelColor: Colors.black,
              tabs: [
                Tab(text: t!.every_day),
                Tab(text: t!.selected_days),
              ],
            ),
            Expanded(
                child: TabBarView(children: [
                  createEveryDayContent(),
                  createSelectedDaysContent()
                ]))
          ],
        ));
  }

  Widget createEveryDayContent() {
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
                      t!.every_day,
                      style: TextStyle(fontSize: 18.0),
                    ),
                    style: ButtonStyle(
                      backgroundColor:
                      MaterialStateProperty.resolveWith<Color?>(
                            (Set<MaterialState> states) {
                          if (_cronDayOfMonthMode ==
                              CronDayOfMonthMode.EVERY_DAY) {
                            return COLOR_PARAM_MODE_ACTIVE_BUTTON_BACKGROUND;
                          }
                          return COLOR_PARAM_MODE_INACTIVE_BUTTON_BACKGROUND; // defer to the defaults
                        },
                      ),
                      foregroundColor:
                      MaterialStateProperty.resolveWith<Color?>(
                              (Set<MaterialState> states) {
                            if (_cronDayOfMonthMode == CronDayOfMonthMode.EVERY_DAY) {
                              return COLOR_PARAM_MODE_ACTIVE_BUTTON_FOREGROUND;
                            }
                            return COLOR_PARAM_MODE_INACTIVE_BUTTON_FOREGROUND; // defer to the defaults
                          }),
                    ),
                    onPressed: () {
                      setState(() {
                        _cronDayOfMonthMode = CronDayOfMonthMode.EVERY_DAY;
                        calculateCronDayOfMonthExpression();
                        notifier.setDayOfMonth(_cronDayOfMonthExpression);
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

  Widget createSelectedDaysContent() {
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
                children: generateDayOfMonthSelection(notifier),
              )))
    ]);
  }

  List<Widget> generateDayOfMonthSelection(CronExpressionNotifier notifier) {
    List<Widget> rows = [];

    int mod = 7;
    List<Widget> dayButtons = [];
    for (var i = CRON_DAY_OF_MONTH_MIN; i <= CRON_DAY_OF_MONTH_MAX; i++) {
      int dayValue = i.toInt();
      OutlinedButton dayButton = OutlinedButton(
          child: Text(
            dayValue.toString(),
            style: TextStyle(fontSize: 16.0),
          ),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                    (Set<MaterialState> states) {
                  if (_selected_days[dayValue]) {
                    return COLOR_PARAM_MODE_ACTIVE_BUTTON_BACKGROUND;
                  }
                  return COLOR_PARAM_MODE_INACTIVE_BUTTON_BACKGROUND; // defer to the defaults
                },
              ), foregroundColor: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                if (_selected_days[dayValue]) {
                  return COLOR_PARAM_MODE_ACTIVE_BUTTON_FOREGROUND;
                }
                return COLOR_PARAM_MODE_INACTIVE_BUTTON_FOREGROUND; // defer to the defaults
              })),
          onPressed: () {
            setState(() {
              _selected_days[dayValue] = !_selected_days[dayValue];
              _cronDayOfMonthMode = CronDayOfMonthMode.SELECTED_DAYS;
              calculateCronDayOfMonthExpression();
              notifier.setDayOfMonth(_cronDayOfMonthExpression);

              resetOtherModes();
            });
          },
          onLongPress: () {
            setState(() {
              _selected_days[dayValue] = !_selected_days[dayValue];
              _cronDayOfMonthMode = CronDayOfMonthMode.SELECTED_DAYS;
              calculateCronDayOfMonthExpression();
              notifier.setDayOfMonth(_cronDayOfMonthExpression);

              resetOtherModes();
            });
          });
      dayButtons.add(dayButton);
      if (i % mod == 0 || i == CRON_DAY_OF_MONTH_MAX) {
        rows.add(Wrap(
            direction: Axis.horizontal,
            alignment: WrapAlignment.start,
            spacing: 10,
            children: dayButtons));
        dayButtons = [];
      }
    }

    return rows;
  }

  void calculateCronDayOfMonthExpression() {
    switch (_cronDayOfMonthMode) {
      case CronDayOfMonthMode.EVERY_DAY:
        _cronDayOfMonthExpression = '*';
        break;
      case CronDayOfMonthMode.SELECTED_DAYS:
        String tmpString = '';
        bool firstValue = true;
        for (var i = 0; i <= (CRON_DAY_OF_MONTH_MAX+CRON_DAY_OF_MONTH_MIN); i++) {
          if (_selected_days[i] == true) {
            if (firstValue) {
              firstValue = false;
            } else {
              tmpString += ',';
            }
            tmpString += i.toString();
          }
        }
        if (!tmpString.isEmpty) {
          _cronDayOfMonthExpression = tmpString;
        } else {
          _cronDayOfMonthMode = CronDayOfMonthMode.EVERY_DAY;
          calculateCronDayOfMonthExpression();
        }
    }
  }

  void resetOtherModes() {
    if (_cronDayOfMonthMode != CronDayOfMonthMode.SELECTED_DAYS) {
      for (var i = 0; i < _selected_days.length; i++) {
        _selected_days[i] = false;
      }
    }
  }
}



