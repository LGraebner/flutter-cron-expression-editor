import 'package:cron_expression_editor/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../cron/cron_helper.dart';
import '../../cron/cron_modes.dart';
import '../../helper/button_factory.dart';
import '../../state/cron_expression_model.dart';
import '../../state/cron_expression_notifier.dart';
import '../../state/state_providers.dart';

class ParamMonth extends ConsumerStatefulWidget {
  const ParamMonth({super.key});

  @override
  _ParamMonthState createState() => _ParamMonthState();
}

class _ParamMonthState extends ConsumerState<ParamMonth> {
  late String _cronMonthExpression;
  late CronMonthMode _cronMonthMode;

  late List<bool> _selected_months;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cronExpressionProvider) as CronExpressionModel;
    _cronMonthExpression = state.cronExpression.split(" ")[3];
    _cronMonthMode = getCronMonthMode(_cronMonthExpression);
    _selected_months =
        getSelectedMonthsValues(_cronMonthMode, _cronMonthExpression);

    return createMonthSelector(context, state, ref);
  }

  Widget createMonthSelector(
      BuildContext context, CronExpressionModel state, WidgetRef ref) {
    var t = AppLocalizations.of(context);

    return DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const SizedBox(height: 10),
            Row(
              children: [
                createSubCronExpressionLabel('${state.month}', COLOR_MONTH)
              ],
            ),
            SizedBox(
              height: 10,
            ),
            TabBar(
              labelColor: Colors.black,
              tabs: [
                Tab(text: t!.every_month),
                Tab(text: t!.selected_months),
              ],
            ),
            Expanded(
                child: TabBarView(children: [
                  createEveryMonthContent(),
                  createSelectedMonthsContent()
                ]))
          ],
        ));
  }

  Widget createEveryMonthContent() {
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
                      t!.every_month,
                      style: TextStyle(fontSize: 18.0),
                    ),
                    style: ButtonStyle(
                      backgroundColor:
                      MaterialStateProperty.resolveWith<Color?>(
                            (Set<MaterialState> states) {
                          if (_cronMonthMode ==
                              CronMonthMode.EVERY_MONTH) {
                            return COLOR_PARAM_MODE_ACTIVE_BUTTON_BACKGROUND;
                          }
                          return COLOR_PARAM_MODE_INACTIVE_BUTTON_BACKGROUND; // defer to the defaults
                        },
                      ),
                      foregroundColor:
                      MaterialStateProperty.resolveWith<Color?>(
                              (Set<MaterialState> states) {
                            if (_cronMonthMode == CronMonthMode.EVERY_MONTH) {
                              return COLOR_PARAM_MODE_ACTIVE_BUTTON_FOREGROUND;
                            }
                            return COLOR_PARAM_MODE_INACTIVE_BUTTON_FOREGROUND; // defer to the defaults
                          }),
                    ),
                    onPressed: () {
                      setState(() {
                        _cronMonthMode = CronMonthMode.EVERY_MONTH;
                        calculateCronMonthExpression();
                        notifier.setMonth(_cronMonthExpression);
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

  Widget createSelectedMonthsContent() {
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
                children: generateMonthSelection(notifier),
              )))
    ]);
  }

  List<Widget> generateMonthSelection(CronExpressionNotifier notifier) {
    List<Widget> rows = [];

    int mod = 4;
    List<Widget> monthButtons = [];
    for (var i = CRON_MONTH_MIN; i <= CRON_MONTH_MAX; i++) {
      int monthValue = i.toInt();
      SizedBox monthButton = new SizedBox(width: 150, child:
       OutlinedButton(
          child: Text(
            (DateFormat('MMMM').format(DateTime(0, monthValue))).toString(),
            style: TextStyle(fontSize: 16.0),
          ),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                    (Set<MaterialState> states) {
                  if (_selected_months[monthValue]) {
                    return COLOR_PARAM_MODE_ACTIVE_BUTTON_BACKGROUND;
                  }
                  return COLOR_PARAM_MODE_INACTIVE_BUTTON_BACKGROUND; // defer to the defaults
                },
              ), foregroundColor: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                if (_selected_months[monthValue]) {
                  return COLOR_PARAM_MODE_ACTIVE_BUTTON_FOREGROUND;
                }
                return COLOR_PARAM_MODE_INACTIVE_BUTTON_FOREGROUND; // defer to the defaults
              })),
          onPressed: () {
            setState(() {
              _selected_months[monthValue] = !_selected_months[monthValue];
              _cronMonthMode = CronMonthMode.SELECTED_MONTHS;
              calculateCronMonthExpression();
              notifier.setMonth(_cronMonthExpression);

              resetOtherModes();
            });
          },
          onLongPress: () {
            setState(() {
              _selected_months[monthValue] = !_selected_months[monthValue];
              _cronMonthMode = CronMonthMode.SELECTED_MONTHS;
              calculateCronMonthExpression();
              notifier.setMonth(_cronMonthExpression);

              resetOtherModes();
            });
          }));
      monthButtons.add(monthButton);
      if (i % mod == 0 || i == CRON_MONTH_MAX) {
        rows.add(Wrap(
            direction: Axis.horizontal,
            alignment: WrapAlignment.start,
            spacing: 10,
            children: monthButtons));
        monthButtons = [];
      }
    }

    return rows;
  }

  void calculateCronMonthExpression() {
    switch (_cronMonthMode) {
      case CronMonthMode.EVERY_MONTH:
        _cronMonthExpression = '*';
        break;
      case CronMonthMode.SELECTED_MONTHS:
        String tmpString = '';
        bool firstValue = true;
        for (var i = 0; i <= (CRON_MONTH_MAX + CRON_MONTH_MIN); i++) {
          if (_selected_months[i] == true) {
            if (firstValue) {
              firstValue = false;
            } else {
              tmpString += ',';
            }
            tmpString += i.toString();
          }
        }
        if (!tmpString.isEmpty) {
          _cronMonthExpression = tmpString;
        } else {
          _cronMonthMode = CronMonthMode.EVERY_MONTH;
          calculateCronMonthExpression();
        }
    }
  }

  void resetOtherModes() {
    if (_cronMonthMode != CronMonthMode.SELECTED_MONTHS) {
      for (var i = 0; i < _selected_months.length; i++) {
        _selected_months[i] = false;
      }
    }
  }
}



