import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../services/api_service.dart';
import '../services/local_storage.dart';

class AddEditHabitScreen extends StatefulWidget {
  final Habit? habit;

  const AddEditHabitScreen({super.key, this.habit});

  @override
  State<AddEditHabitScreen> createState() => _AddEditHabitScreenState();
}

class _AddEditHabitScreenState extends State<AddEditHabitScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _frequency = 'daily';
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.habit != null) {
      _titleController.text = widget.habit!.title;
      _descriptionController.text = widget.habit!.description;
      _frequency = widget.habit!.frequency;
    }
  }

  Future<void> _saveHabit() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userId = await LocalStorage.getUserId();
      if (userId == null) throw Exception('User not logged in');

      if (widget.habit == null) {
        await ApiService.createHabit(
          userId,
          _titleController.text.trim(),
          _descriptionController.text.trim(),
          _frequency,
        );
      } else {
        await ApiService.updateHabit(
          widget.habit!.id,
          userId,
          _titleController.text.trim(),
          _descriptionController.text.trim(),
          _frequency,
          widget.habit!.status,
        );
      }

      if (!mounted) return;
      Navigator.pop(context, true);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.habit == null ? 'Add Habit' : 'Edit Habit'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: _frequency,
              items: const [
                DropdownMenuItem(value: 'daily', child: Text('Daily')),
                DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
              ],
              onChanged: (value) {
                setState(() {
                  _frequency = value!;
                });
              },
              decoration: const InputDecoration(labelText: 'Frequency'),
            ),

            const SizedBox(height: 20),

            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),

            const SizedBox(height: 10),

            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _saveHabit,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
