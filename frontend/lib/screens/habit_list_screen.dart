import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../services/api_service.dart';
import '../services/local_storage.dart';
import 'add_edit_habit_screen.dart';
import 'habit_details_screen.dart';

class HabitListScreen extends StatefulWidget {
  const HabitListScreen({super.key});

  @override
  State<HabitListScreen> createState() => _HabitListScreenState();
}

class _HabitListScreenState extends State<HabitListScreen> {
  List<Habit> _habits = [];
  bool _isLoading = true;
  String _statusFilter = 'active';
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userId = await LocalStorage.getUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final habits =
      await ApiService.fetchHabits(userId, _statusFilter);

      setState(() {
        _habits = habits;
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

  Future<void> _logout() async {
    await LocalStorage.clearUserId();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> _archiveHabit(Habit habit) async {
    try {
      final userId = await LocalStorage.getUserId();
      if (userId == null) throw Exception('User not logged in');

      await ApiService.updateHabit(
        habit.id,
        userId,
        habit.title,
        habit.description,
        habit.frequency,
        'archived',
      );

      _loadHabits();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _deleteHabit(Habit habit) async {
    try {
      final userId = await LocalStorage.getUserId();
      if (userId == null) throw Exception('User not logged in');

      await ApiService.deleteHabit(habit.id, userId);
      _loadHabits();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  void _showHabitActions(Habit habit) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (habit.status == 'active')
            ListTile(
              leading: const Icon(Icons.archive),
              title: const Text('Archive Habit'),
              onTap: () {
                Navigator.pop(context);
                _archiveHabit(habit);
              },
            ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Delete Habit'),
            onTap: () {
              Navigator.pop(context);
              _deleteHabit(habit);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Habits'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),

      // ➕ Add Habit
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddEditHabitScreen(),
            ),
          );

          if (result == true) {
            _loadHabits();
          }
        },
        child: const Icon(Icons.add),
      ),

      body: Column(
        children: [
          // Active / Archived filter
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text('Active'),
                  selected: _statusFilter == 'active',
                  onSelected: (_) {
                    setState(() {
                      _statusFilter = 'active';
                    });
                    _loadHabits();
                  },
                ),
                const SizedBox(width: 10),
                ChoiceChip(
                  label: const Text('Archived'),
                  selected: _statusFilter == 'archived',
                  onSelected: (_) {
                    setState(() {
                      _statusFilter = 'archived';
                    });
                    _loadHabits();
                  },
                ),
              ],
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.red),
              ),
            )
                : _habits.isEmpty
                ? const Center(child: Text('No habits found'))
                : ListView.builder(
              itemCount: _habits.length,
              itemBuilder: (context, index) {
                final habit = _habits[index];
                return Card(
                  child: ListTile(
                    title: Text(habit.title),
                    subtitle: Text(
                      '${habit.frequency} • ${habit.status}',
                    ),

                    // 👉 Open habit details
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              HabitDetailsScreen(
                                habit: habit,
                              ),
                        ),
                      );
                    },

                    // 👉 Archive / Delete
                    onLongPress: () {
                      _showHabitActions(habit);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
