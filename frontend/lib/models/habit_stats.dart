class HabitStats {
  final int totalDaysTracked;
  final int daysCompleted;
  final int completionRate;

  HabitStats({
    required this.totalDaysTracked,
    required this.daysCompleted,
    required this.completionRate,
  });

  factory HabitStats.fromJson(Map<String, dynamic> json) {
    return HabitStats(
      totalDaysTracked: json['totalDaysTracked'],
      daysCompleted: json['daysCompleted'],
      completionRate: json['completionRate'],
    );
  }
}
