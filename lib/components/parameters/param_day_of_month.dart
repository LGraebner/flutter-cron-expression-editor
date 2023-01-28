import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final int MIN_DAYS = 1;
final int MAX_DAYS = 31;

class ParamDayOfMonth extends StatefulWidget {
  const ParamDayOfMonth({super.key});

  @override
  State<ParamDayOfMonth> createState() => _ParamDayOfMonthState();
}

class _ParamDayOfMonthState extends State<ParamDayOfMonth> {

  String _cronDayOfMonthExpression = '*';
  CronDayOfMonthMode _cronDayOfMonthMode = CronDayOfMonthMode.EVERY_DAY;

  List<bool> _selected_days= createSelectedDaysValues();

  final cronMinutesExpressionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return createMinutesSelector(context);
  }

  Widget createMinutesSelector(BuildContext context) {
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
                        backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                              (Set<MaterialState> states) {
                            if (_cronDayOfMonthMode == CronDayOfMonthMode.EVERY_DAY) {
                              return Colors.blueAccent;
                            }
                            return Colors.white; // defer to the defaults
                          },
                        ),
                        foregroundColor: MaterialStateProperty.resolveWith<Color?>(
                                (Set<MaterialState> states) {
                              if (_cronDayOfMonthMode == CronDayOfMonthMode.EVERY_DAY) {
                                return Colors.white;
                              }
                              return Colors.black54; // defer to the defaults
                            }),
                      ),
                      onPressed: () {
                        setState(() {
                          _cronDayOfMonthMode = CronDayOfMonthMode.EVERY_DAY;
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

    int maxRows = (MAX_DAYS-MIN_DAYS) ~/ 10 + 1;
    int dayCount = 0;
    for (var i = 0; i < maxRows; i++) {
      List<Widget> minuteButtons = [];
      for (var j = 0; j < 10 && dayCount <= (MAX_DAYS-MIN_DAYS); j++) {
        int dayValue = i * 10 + j + MIN_DAYS;
        OutlinedButton minuteButton = new OutlinedButton(
          child: Text(
            (dayValue).toString(),
            style: TextStyle(fontSize: 16.0),
          ),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                    (Set<MaterialState> states) {
                  if (_selected_days[dayValue-MIN_DAYS]) {
                    return Colors.blueAccent;
                  }
                  return Colors.white; // defer to the defaults
                },
              ), foregroundColor: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                if (_selected_days[dayValue-MIN_DAYS]) {
                  return Colors.white;
                }
                return Colors.black54; // defer to the defaults
              })),
          onPressed: () {
            setState(() {
              _selected_days[dayValue-MIN_DAYS] = !_selected_days[dayValue-MIN_DAYS];
              _cronDayOfMonthMode = CronDayOfMonthMode.SELECTED_DAYS;
              calculateCronDayOfMonthExpression();
              resetOtherModes();
            });
          },
        );
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
      case CronDayOfMonthMode.EVERY_DAY:
        _cronDayOfMonthExpression = '*';
        break;
      case CronDayOfMonthMode.SELECTED_DAYS:
        String tmpString = '';
        bool firstValue = true;
        for (var i=0; i<_selected_days.length; i++) {
          if (_selected_days[i] == true) {
            if (firstValue) {
              firstValue = false;
            } else {
              tmpString += ',';
            }
            tmpString += (i+MIN_DAYS).toString();
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
      for (var i=0; i < _selected_days.length; i++) {
        _selected_days[i] = false;
      }
    }
  }
}

List<bool> createSelectedDaysValues() {
  List<bool> selectedDays = [];
  for (var i = 0; i <= MAX_DAYS-MIN_DAYS; i++) {
    selectedDays.add(false);
  }

  return selectedDays;
}

enum CronDayOfMonthMode {
  EVERY_DAY,
  SELECTED_DAYS
}
