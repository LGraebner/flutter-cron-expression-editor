import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

final int MIN_DAY_OF_WEEK = 0;
final int MAX_DAY_OF_WEEK = 7;

const dayOfWeekMap = {
  0 : 'SUNDAY',
  1 : 'MONDAY',
  2 : 'TUESDAY',
  3 : 'WEDNESDAY',
  4 : 'THURSDAY',
  5 : 'FRIDAY',
  6 : 'SATURDAY',
  7 : 'SUNDAY',
};

class ParamDayOfWeek extends StatefulWidget {
  const ParamDayOfWeek({super.key});

  @override
  State<ParamDayOfWeek> createState() => _ParamDayOfWeekState();
}

class _ParamDayOfWeekState extends State<ParamDayOfWeek> {

  String _cronDayOfWeekExpression = '*';
  CronDayOfWeekMode _cronDayOfWeekMode = CronDayOfWeekMode.EVERY_DAY_OF_WEEK;

  List<bool> _selected_days_of_week = createSelectedDaysOfWeekValues();

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
                    labelText: _cronDayOfWeekExpression),
              ),
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
                        t!.every_day_of_week,
                        style: TextStyle(fontSize: 18.0),
                      ),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                              (Set<MaterialState> states) {
                            if (_cronDayOfWeekMode == CronDayOfWeekMode.EVERY_DAY_OF_WEEK) {
                              return Colors.blueAccent;
                            }
                            return Colors.white; // defer to the defaults
                          },
                        ),
                        foregroundColor: MaterialStateProperty.resolveWith<Color?>(
                                (Set<MaterialState> states) {
                              if (_cronDayOfWeekMode == CronDayOfWeekMode.EVERY_DAY_OF_WEEK) {
                                return Colors.white;
                              }
                              return Colors.black54; // defer to the defaults
                            }),
                      ),
                      onPressed: () {
                        setState(() {
                          _cronDayOfWeekMode = CronDayOfWeekMode.EVERY_DAY_OF_WEEK;
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

    int maxRows = (MAX_DAY_OF_WEEK-MIN_DAY_OF_WEEK) ~/ 4 + 1;
    int dayCount = 0;
    for (var i = 0; i < maxRows; i++) {
      List<Widget> minuteButtons = [];
      for (var j = 0; j < 4 && dayCount <= (MAX_DAY_OF_WEEK-MIN_DAY_OF_WEEK); j++) {

        int dayOfWeekValue = i * 4 + j + MIN_DAY_OF_WEEK;
        SizedBox minuteButton = new SizedBox(width: 150, child: OutlinedButton(
          child: Text(
            toBeginningOfSentenceCase(dayOfWeekMap[dayOfWeekValue]!.toLowerCase())!,
            style: TextStyle(fontSize: 16.0),
          ),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                    (Set<MaterialState> states) {
                  if (_selected_days_of_week[dayOfWeekValue-MIN_DAY_OF_WEEK]) {
                    return Colors.blueAccent;
                  }
                  return Colors.white; // defer to the defaults
                },
              ), foregroundColor: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                if (_selected_days_of_week[dayOfWeekValue-MIN_DAY_OF_WEEK]) {
                  return Colors.white;
                }
                return Colors.black54; // defer to the defaults
              })),
          onPressed: () {
            setState(() {
              _selected_days_of_week[dayOfWeekValue-MIN_DAY_OF_WEEK] = !_selected_days_of_week[dayOfWeekValue-MIN_DAY_OF_WEEK];
              _cronDayOfWeekMode = CronDayOfWeekMode.SELECTED_DAYS_OF_WEEK;
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
    switch (_cronDayOfWeekMode) {
      case CronDayOfWeekMode.EVERY_DAY_OF_WEEK:
        _cronDayOfWeekExpression = '*';
        break;
      case CronDayOfWeekMode.SELECTED_DAYS_OF_WEEK:
        String tmpString = '';
        bool firstValue = true;
        for (var i=0; i<_selected_days_of_week.length; i++) {
          if (_selected_days_of_week[i] == true) {
            if (firstValue) {
              firstValue = false;
            } else {
              tmpString += ',';
            }
            tmpString += (i+MIN_DAY_OF_WEEK).toString();
          }
        }
        if (!tmpString.isEmpty) {
          _cronDayOfWeekExpression = tmpString;
        } else {
          _cronDayOfWeekMode = CronDayOfWeekMode.EVERY_DAY_OF_WEEK;
          calculateCronDayOfMonthExpression();
        }
    }
  }

  void resetOtherModes() {
    if (_cronDayOfWeekMode != CronDayOfWeekMode.SELECTED_DAYS_OF_WEEK) {
      for (var i=0; i < _selected_days_of_week.length; i++) {
        _selected_days_of_week[i] = false;
      }
    }
  }
}

List<bool> createSelectedDaysOfWeekValues() {
  List<bool> selectedDays = [];
  for (var i = 0; i <= MAX_DAY_OF_WEEK-MIN_DAY_OF_WEEK; i++) {
    selectedDays.add(false);
  }

  return selectedDays;
}

enum CronDayOfWeekMode {
  EVERY_DAY_OF_WEEK,
  SELECTED_DAYS_OF_WEEK
}
