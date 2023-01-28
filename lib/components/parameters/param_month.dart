import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

final int MIN_MONTH = 1;
final int MAX_MONTH = 12;

class ParamMonth extends StatefulWidget {
  const ParamMonth({super.key});

  @override
  State<ParamMonth> createState() => _ParamMonthState();
}

class _ParamMonthState extends State<ParamMonth> {

  String _cronDayOfMonthExpression = '*';
  CronMonthMode _cronDayOfMonthMode = CronMonthMode.EVERY_MONTH;

  List<bool> _selected_days= createSelectedMonthsValues();

  final cronMinutesExpressionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return createMonthSelector(context);
  }

  Widget createMonthSelector(BuildContext context) {
    var t = AppLocalizations.of(context);

    return DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: _cronDayOfMonthExpression),
              ),
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
                  createEveryDayContent(),
                  createSelectedDaysContent()
                ]))
          ],
        ));
  }

  Widget createEveryDayContent() {
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
                        t!.every_month,
                        style: TextStyle(fontSize: 18.0),
                      ),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                              (Set<MaterialState> states) {
                            if (_cronDayOfMonthMode == CronMonthMode.EVERY_MONTH) {
                              return Colors.blueAccent;
                            }
                            return Colors.white; // defer to the defaults
                          },
                        ),
                        foregroundColor: MaterialStateProperty.resolveWith<Color?>(
                                (Set<MaterialState> states) {
                              if (_cronDayOfMonthMode == CronMonthMode.EVERY_MONTH) {
                                return Colors.white;
                              }
                              return Colors.black54; // defer to the defaults
                            }),
                      ),
                      onPressed: () {
                        setState(() {
                          _cronDayOfMonthMode = CronMonthMode.EVERY_MONTH;
                          calculateCronDayOfMonthExpression();
                          resetOtherModes();
                        });
                      },
                    )),
              ],
            )),
      ],
    );
  }

  Widget createSelectedDaysContent() {
    return Column(children: [
      const SizedBox(height: 10),
      Container(
          padding: const EdgeInsets.all(10.0),
          child: new Align(
              alignment: Alignment.topLeft,
              child: Wrap(
                direction: Axis.vertical,
                spacing: 10,
                children: generateDayOfMonthSelection(),
              )))
    ]);
  }

  List<Widget> generateDayOfMonthSelection() {
    List<Widget> rows = [];

    int maxRows = (MAX_MONTH-MIN_MONTH) ~/ 4 + 1;
    int dayCount = 0;
    for (var i = 0; i < maxRows; i++) {
      List<Widget> minuteButtons = [];
      for (var j = 0; j < 4 && dayCount <= (MAX_MONTH-MIN_MONTH); j++) {
        int monthValue = i * 4 + j + MIN_MONTH;
        SizedBox minuteButton = new SizedBox(width: 150, child: OutlinedButton(
          child: Text(
            (DateFormat('MMMM').format(DateTime(0, monthValue))).toString(),
            style: TextStyle(fontSize: 16.0),
          ),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                    (Set<MaterialState> states) {
                  if (_selected_days[monthValue-MIN_MONTH]) {
                    return Colors.blueAccent;
                  }
                  return Colors.white; // defer to the defaults
                },
              ), foregroundColor: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                if (_selected_days[monthValue-MIN_MONTH]) {
                  return Colors.white;
                }
                return Colors.black54; // defer to the defaults
              })),
          onPressed: () {
            setState(() {
              _selected_days[monthValue-MIN_MONTH] = !_selected_days[monthValue-MIN_MONTH];
              _cronDayOfMonthMode = CronMonthMode.SELECTED_MONTHS;
              calculateCronDayOfMonthExpression();
              resetOtherModes();
            });
          },
        ));
        minuteButtons.add(minuteButton);
        dayCount++;
      }
      rows.add(new Wrap(
          direction: Axis.horizontal,
          alignment: WrapAlignment.start,
          spacing: 10,
          children: minuteButtons));
    }

    return rows;
  }

  void calculateCronDayOfMonthExpression() {
    switch (_cronDayOfMonthMode) {
      case CronMonthMode.EVERY_MONTH:
        _cronDayOfMonthExpression = '*';
        break;
      case CronMonthMode.SELECTED_MONTHS:
        String tmpString = '';
        bool firstValue = true;
        for (var i=0; i<_selected_days.length; i++) {
          if (_selected_days[i] == true) {
            if (firstValue) {
              firstValue = false;
            } else {
              tmpString += ',';
            }
            tmpString += (i+MIN_MONTH).toString();
          }
        }
        if (!tmpString.isEmpty) {
          _cronDayOfMonthExpression = tmpString;
        } else {
          _cronDayOfMonthMode = CronMonthMode.EVERY_MONTH;
          calculateCronDayOfMonthExpression();
        }
    }
  }

  void resetOtherModes() {
    if (_cronDayOfMonthMode != CronMonthMode.SELECTED_MONTHS) {
      for (var i=0; i < _selected_days.length; i++) {
        _selected_days[i] = false;
      }
    }
  }
}

List<bool> createSelectedMonthsValues() {
  List<bool> selectedDays = [];
  for (var i = 0; i <= MAX_MONTH-MIN_MONTH; i++) {
    selectedDays.add(false);
  }

  return selectedDays;
}

enum CronMonthMode {
  EVERY_MONTH,
  SELECTED_MONTHS
}
