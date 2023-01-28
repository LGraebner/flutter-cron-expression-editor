import 'package:easy_cron/easy_cron.dart';
import 'package:intl/intl.dart';

final String dateFormat = 'hh:mm:ss a, LLL d y';
final int nbMaxRows = 16;

final parser = UnixCronParser();

List<String> createCronSchedules(String cronExpression) {
  List<String> cronSchedules = [];
  final schedule = parser.parse(cronExpression);
  DateTime startTime = DateTime.now();
  CronTime nextTrigger = schedule.next(startTime);
  int i = 0;
  while (nextTrigger != null && i < nbMaxRows) {
    cronSchedules.add(DateFormat(dateFormat).format(nextTrigger.time));
    nextTrigger = schedule.next(nextTrigger.time);
    i++;
  }

  return cronSchedules;
}