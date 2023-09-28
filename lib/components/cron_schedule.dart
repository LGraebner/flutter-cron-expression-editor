import 'package:cron_expression_editor/helper/cron_schedule_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/cron_expression_model.dart';
import '../state/state_providers.dart';

class CronSchedule extends StatefulWidget {
  const CronSchedule({super.key});

  @override
  State<CronSchedule> createState() => _CronScheduleState();
}

class _CronScheduleState extends State<CronSchedule> {
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      // print("rebuilding cron expression display");
      final state = ref.watch(cronExpressionProvider) as CronExpressionModel;
      return createScheduleTable('${state.cronExpression}');
    });
  }

  Widget createScheduleTable(String cronExpression) {
    List<String> cronSchedules = createCronSchedules(cronExpression);
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black12,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      padding: const EdgeInsets.only(top: 1.0),
      alignment: Alignment.topLeft,
      child: DataTable(
          headingRowHeight: 30,
          columns: const <DataColumn>[
            DataColumn(
                label: Text(
              'Next Trigger Dates',
              style: TextStyle(fontWeight: FontWeight.bold),
            )),
          ],
          rows: List<DataRow>.generate(
            cronSchedules.length,
            (int index) => DataRow(
              color: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                if (index.isEven) {
                  return Colors.grey.withOpacity(0.2);
                }
                return null; // Use default value for other states and odd rows.
              }),
              cells: <DataCell>[
                DataCell(Text(cronSchedules[index])),
              ],
            ),
          )),
    );
  }
}
