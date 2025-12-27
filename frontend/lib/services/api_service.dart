import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/habit.dart';
import '../models/habit_log.dart';
import '../models/habit_stats.dart';


class ApiService {
  // Android emulator localhost
  static const String baseUrl = 'http://192.168.1.6:3000';

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final url = Uri.parse('$baseUrl/api/auth/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return data;
    } else {
      throw Exception(data['error'] ?? 'Login failed');
    }
  }

  static Future<void> register(
      String name, String email, String password) async {
    final url = Uri.parse('$baseUrl/api/auth/register');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 201) {
      throw Exception(data['error'] ?? 'Registration failed');
    }
  }

  static Future<List<Habit>> fetchHabits(
      String userId, String status) async {
    final url =
    Uri.parse('$baseUrl/api/habits/$userId?status=$status');

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch habits');
    }

    final List data = jsonDecode(response.body);
    return data.map((e) => Habit.fromJson(e)).toList();
  }

  static Future<void> createHabit(
      String userId,
      String title,
      String description,
      String frequency,
      ) async {
    final url = Uri.parse('$baseUrl/api/habits');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'title': title,
        'description': description,
        'frequency': frequency,
      }),
    );

    if (response.statusCode != 201) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Failed to create habit');
    }
  }

  static Future<void> updateHabit(
      String habitId,
      String userId,
      String title,
      String description,
      String frequency,
      String status,
      ) async {
    final url = Uri.parse('$baseUrl/api/habits/$habitId');

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'title': title,
        'description': description,
        'frequency': frequency,
        'status': status,
      }),
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Failed to update habit');
    }
  }

  static Future<void> markHabitDone(
      String habitId,
      String userId,
      String date,
      ) async {
    final url = Uri.parse('$baseUrl/api/habits/$habitId/mark');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'date': date,
      }),
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Failed to mark habit');
    }
  }

  static Future<List<HabitLog>> fetchHabitLogs(
      String habitId,
      String userId,
      ) async {
    final url = Uri.parse(
      '$baseUrl/api/habits/$habitId/logs?userId=$userId',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch logs');
    }

    final List data = jsonDecode(response.body);
    return data.map((e) => HabitLog.fromJson(e)).toList();
  }

  static Future<HabitStats> fetchHabitStats(
      String habitId,
      String userId,
      ) async {
    final url = Uri.parse(
      '$baseUrl/api/habits/$habitId/stats?userId=$userId',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch stats');
    }

    final data = jsonDecode(response.body);
    return HabitStats.fromJson(data);
  }


  static Future<void> deleteHabit(
      String habitId,
      String userId,
      ) async {
    final url = Uri.parse('$baseUrl/api/habits/$habitId');

    final response = await http.delete(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId}),
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Failed to delete habit');
    }
  }



}
