import 'package:easy_cron/easy_cron.dart';
import 'package:intl/intl.dart';

final String dateFormat = 'HH:mm:ss a, LLL d y';
final int nbMaxRows = 18;

final parser = UnixCronParser();

List<String> createCronSchedules(String cronExpression) {
  List<String> cronSchedules = [];
  try {

    final schedule = parser.parse(cronExpression);
    DateTime startTime = DateTime.now();
    CronTime nextTrigger = schedule.next(startTime);
    if (nextTrigger.time == null) {
      cronSchedules.add("Invalid Cron Expression");
      return cronSchedules;
    }
    int i = 0;
    while (nextTrigger != null && i < nbMaxRows) {
      cronSchedules.add(DateFormat(dateFormat).format(nextTrigger.time));
      nextTrigger = schedule.next(nextTrigger.time);
      i++;
    }

  } catch (e) {
    print(e);
  }

  return cronSchedules;
}