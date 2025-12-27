class HabitLog {
  final String id;
  final String date;
  final bool completed;

  HabitLog({
    required this.id,
    required this.date,
    required this.completed,
  });

  factory HabitLog.fromJson(Map<String, dynamic> json) {
    return HabitLog(
      id: json['_id'],
      date: json['date'],
      completed: json['completed'],
    );
  }
}
