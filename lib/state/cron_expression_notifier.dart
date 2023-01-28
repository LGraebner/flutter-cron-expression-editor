import 'package:cron_expression_editor/constants.dart';
import 'package:cron_expression_editor/state/cron_expression_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CronExpressionNotifier extends StateNotifier<CronExpressionModel> {
  CronExpressionNotifier()
      : super(CronExpressionModel.fromCronExpression(INITIAL_CRON_EXPRESSION));

  void setMinutes(String minutes) => state = new CronExpressionModel(minutes, state.hours, state.dayOfMonth, state.month, state.dayOfWeek);

  void setHours(String hours) => state = new CronExpressionModel(state.minutes, hours, state.dayOfMonth, state.month, state.dayOfWeek);

  void setDayOfMonth(String dayOfMonth) => state = new CronExpressionModel(state.minutes, state.hours, dayOfMonth, state.month, state.dayOfWeek);

  void setMonth(String month) => state = new CronExpressionModel(state.minutes, state.hours, state.dayOfMonth, month, state.dayOfWeek);

  void setDayOfWeek(String dayOfWeek) => state = new CronExpressionModel(state.minutes, state.hours, state.dayOfMonth, state.month, dayOfWeek);

  void setCronExpression(String cronExpression) =>  state = CronExpressionModel.fromCronExpression(cronExpression);

}
