class Habit {
  final String id;
  final String title;
  final String description;
  final String frequency;
  final String status;

  Habit({
    required this.id,
    required this.title,
    required this.description,
    required this.frequency,
    required this.status,
  });

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['_id'],
      title: json['title'],
      description: json['description'] ?? '',
      frequency: json['frequency'],
      status: json['status'],
    );
  }
}
