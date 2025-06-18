class NotificationModel {
  String selectedHour;
  String selectedDay;
  String selectedField;

  NotificationModel(this.selectedHour, this.selectedDay, this.selectedField);

  String notification() {
    return '$selectedHour, $selectedDay, $selectedField';
  }
}