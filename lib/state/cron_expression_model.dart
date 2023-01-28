class CronExpressionModel {
  late String cronExpression;
  late String minutes;
  late String hours;
  late String dayOfMonth;
  late String month;
  late String dayOfWeek;

  CronExpressionModel(this.minutes, this.hours, this.dayOfMonth, this.month, this.dayOfWeek) {
    cronExpression = recalculateCronExpression();
  }

  CronExpressionModel.fromCronExpression(this.cronExpression) {
    List<String> cronItems = cronExpression.split(" ");
    minutes = cronItems[0];
    hours = cronItems[1];
    dayOfMonth = cronItems[2];
    month = cronItems[3];
    dayOfWeek = cronItems[4];
    cronExpression = recalculateCronExpression();
  }

  CronExpressionModel.fromCronExpressionModel(CronExpressionModel another) {
    cronExpression = another.cronExpression;
    minutes = another.minutes;
    hours = another.hours;
    dayOfMonth = another.dayOfMonth;
    month = another.month;
    dayOfWeek = another.dayOfWeek;
  }

  String recalculateCronExpression() {
    var cronItems = [this.minutes, this.hours, this.dayOfMonth, this.month, this.dayOfWeek];
    String cronExpression = cronItems.join(" ");

    return cronExpression;
  }

  CronExpressionModel withMinutes(String minutes) {
    CronExpressionModel newModel = CronExpressionModel.fromCronExpressionModel(this);
    newModel.minutes = minutes;
    newModel.recalculateCronExpression();

    return newModel;
  }

}