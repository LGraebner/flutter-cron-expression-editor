import '../constants.dart';
import 'cron_modes.dart';

String EVERY_UNIT_EXP = '*';
String EVERY_N_EXP = '*/';

/* Minutes */
CronMinutesMode getCronMinutesMode(String cronMinutesExpression) {
  if (cronMinutesExpression == EVERY_UNIT_EXP) {
    return CronMinutesMode.EVERY_MINUTE;
  }
  if (cronMinutesExpression.contains(EVERY_N_EXP)) {
    return CronMinutesMode.EVERY_N_MINUTES;
  }

  return CronMinutesMode.SELECTED_MINUTES;
}

double getEveryNMinutesValue(
    CronMinutesMode cronMinutesMode, String cronMinutesExpression) {
  if (cronMinutesMode == CronMinutesMode.EVERY_N_MINUTES) {
    return getEveryNValue(cronMinutesExpression);
  } else {
    return CRON_MINUTES_EVERY_N_MIN;
  }
}

List<bool> getSelectedMinutesValues(
    CronMinutesMode cronMinutesMode, String cronMinutesExpression) {
  List<bool> selectedMinutes = [];
  for (var i = 0; i <= (CRON_MINUTES_MAX - CRON_MINUTES_MIN); i++) {
    selectedMinutes.add(false);
  }

  if (cronMinutesMode == CronMinutesMode.SELECTED_MINUTES) {
    List<int> minutes =
    cronMinutesExpression.split(',').map((e) => int.parse(e)).toList();
    for (var i in minutes) {
      selectedMinutes[i] = true;
    }
  }

  return selectedMinutes;
}

/* Hours */
CronHoursMode getCronHoursMode(String cronHoursExpression) {
  if (cronHoursExpression == EVERY_UNIT_EXP) {
    return CronHoursMode.EVERY_HOUR;
  }
  if (cronHoursExpression.contains(EVERY_N_EXP)) {
    return CronHoursMode.EVERY_N_HOURS;
  }

  return CronHoursMode.SELECTED_HOURS;
}

double getEveryNHoursValue(
    CronHoursMode cronHoursMode, String cronHoursExpression) {
  if (cronHoursMode == CronHoursMode.EVERY_N_HOURS) {
    return getEveryNValue(cronHoursExpression);
  } else {
    return CRON_HOURS_EVERY_N_MIN;
  }
}

List<bool> getSelectedHoursValues(
    CronHoursMode cronHoursMode, String cronHoursExpression) {
  List<bool> selectedHours = [];
  for (var i = 0; i < (CRON_MINUTES_EVERY_N_MAX + CRON_MINUTES_EVERY_N_MIN); i++) {
    selectedHours.add(false);
  }

  if (cronMinutesMode == CronMinutesMode.SELECTED_MINUTES) {
    List<int> minutes =
    cronMinutesExpression.split(',').map((e) => int.parse(e)).toList();
    for (var i in minutes) {
      selectedMinutes[i] = true;
    }
  }

  return selectedMinutes;
}

/* General */

double getEveryNValue(String cronUnitExpression) {
  return double.parse(cronUnitExpression.split("*/")[1]);
}