import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../models/habit_log.dart';
import '../models/habit_stats.dart';
import '../services/api_service.dart';
import '../services/local_storage.dart';

class HabitDetailsScreen extends StatefulWidget {
  final Habit habit;

  const HabitDetailsScreen({super.key, required this.habit});

  @override
  State<HabitDetailsScreen> createState() => _HabitDetailsScreenState();
}

class _HabitDetailsScreenState extends State<HabitDetailsScreen> {
  List<HabitLog> _logs = [];
  HabitStats? _stats;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userId = await LocalStorage.getUserId();
      if (userId == null) throw Exception('User not logged in');

      final logs =
      await ApiService.fetchHabitLogs(widget.habit.id, userId);
      final stats =
      await ApiService.fetchHabitStats(widget.habit.id, userId);

      setState(() {
        _logs = logs;
        _stats = stats;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _markTodayDone() async {
    try {
      final userId = await LocalStorage.getUserId();
      if (userId == null) throw Exception('User not logged in');

      final today = DateTime.now().toIso8601String().substring(0, 10);

      await ApiService.markHabitDone(
        widget.habit.id,
        userId,
        today,
      );

      _loadDetails();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.habit.title)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
        child: Text(
          _error!,
          style: const TextStyle(color: Colors.red),
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Frequency: ${widget.habit.frequency}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),

            if (_stats != null)
              Text(
                'Completion Rate: ${_stats!.completionRate}%',
                style: const TextStyle(fontSize: 16),
              ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: widget.habit.status == 'archived'
                  ? null
                  : _markTodayDone,
              child: const Text('Mark today as done'),
            ),


            const SizedBox(height: 20),

            const Text(
              'Logs',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            Expanded(
              child: ListView.builder(
                itemCount: _logs.length,
                itemBuilder: (context, index) {
                  final log = _logs[index];
                  return ListTile(
                    title: Text(log.date),
                    trailing: Icon(
                      log.completed
                          ? Icons.check_circle
                          : Icons.cancel,
                      color: log.completed
                          ? Colors.green
                          : Colors.red,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
