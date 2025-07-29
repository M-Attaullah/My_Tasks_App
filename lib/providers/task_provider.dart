import 'package:flutter/material.dart';
import '../database/task_database.dart';
import '../models/task.dart';

class TaskProvider extends ChangeNotifier {
  final _db = TaskDatabase.instance;

  final List<Task> _tasks = [];
  List<Task> get tasks => List.unmodifiable(_tasks);

  bool _loading = false;
  bool get isLoading => _loading;

  Future<void> loadTasks() async {
    _loading = true;
    notifyListeners();
    final result = await _db.getAllTasks();
    _tasks
      ..clear()
      ..addAll(result);
    _loading = false;
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    final id = await _db.insertTask(task);
    _tasks.add(task.copyWith(id: id));
    notifyListeners();
  }

  Future<void> updateTask(Task task) async {
    if (task.id == null) return;
    await _db.updateTask(task);
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      notifyListeners();
    }
  }

  Future<void> deleteTask(Task task) async {
    if (task.id == null) return;
    await _db.deleteTask(task.id!);
    _tasks.removeWhere((t) => t.id == task.id);
    notifyListeners();
  }

  Future<void> toggleCompleted(Task task) async {
    final updated = task.copyWith(isCompleted: !task.isCompleted);
    await updateTask(updated);
  }
}
