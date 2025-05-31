import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../services/firestore_service.dart';

class TaskProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<Task> _tasks = [];
  bool _isInitialized = false;
  String? _errorMessage;
  final Set<String> _selectedTags = {}; // Added selected tags for filtering
  
  List<Task> get tasks => _getFilteredTasks();
  List<Task> get allTasks => _tasks; // Get all tasks without filter
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;
  Set<String> get selectedTags => _selectedTags;
  Set<String> get availableTags {
    // Get all unique tags from all tasks
    final Set<String> tags = {};
    for (final task in _tasks) {
      tags.addAll(task.tags);
    }
    return tags;
  }

  List<Task> _getFilteredTasks() {
    if (_selectedTags.isEmpty) {
      return _tasks;
    }
    
    return _tasks.where((task) {
      // Task must have ALL selected tags (AND logic)
      return _selectedTags.every((tag) => task.tags.contains(tag));
    }).toList();
  }

  void toggleTagFilter(String tag) {
    if (_selectedTags.contains(tag)) {
      _selectedTags.remove(tag);
    } else {
      _selectedTags.add(tag);
    }
    notifyListeners();
  }

  void clearTagFilters() {
    _selectedTags.clear();
    notifyListeners();
  }

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Listen to tasks stream with error handling
      _firestoreService.getTasks().listen(
        (tasks) {
          _tasks = tasks;
          _isInitialized = true;
          _errorMessage = null;
          notifyListeners();
        },
        onError: (error) {
          // Handle permission errors or other Firestore errors
          if (kDebugMode) {
            print('TaskProvider error: $error');
          }
          _tasks = []; // Set empty list
          _isInitialized = true; // Mark as initialized even with error
          _errorMessage = error.toString();
          notifyListeners();
        },
      );
    } catch (e) {
      // Fallback error handling
      if (kDebugMode) {
        print('TaskProvider initialization error: $e');
      }
      _tasks = [];
      _isInitialized = true;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
  
  Future<void> addTask(Task task) async {
    try {
      if (kDebugMode) {
        print('TaskProvider: Creating task - ${task.title}');
      }
      await _firestoreService.createTask(task);
      if (kDebugMode) {
        print('TaskProvider: Task created successfully');
      }
      // The stream will automatically update _tasks
    } catch (e) {
      if (kDebugMode) {
        print('TaskProvider: Failed to create task - $e');
      }
      throw Exception('Failed to add task: $e');
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      await _firestoreService.updateTask(task);
      // The stream will automatically update _tasks
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _firestoreService.deleteTask(taskId);
      // The stream will automatically update _tasks
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }

  Future<void> toggleTaskCompletion(Task task) async {
    try {
      if (task.id != null) {
        await _firestoreService.toggleTaskCompletion(task.id!, !task.isCompleted);
        // The stream will automatically update _tasks
      }
    } catch (e) {
      throw Exception('Failed to toggle task completion: $e');
    }
  }

  List<Task> getTasksForDate(DateTime date) {
    return _getFilteredTasks().where((task) =>
      task.dueDate.year == date.year &&
      task.dueDate.month == date.month &&
      task.dueDate.day == date.day
    ).toList();
  }

  // Legacy method for compatibility
  Future<void> loadTasks() async {
    // No longer needed as we use streams, but kept for compatibility
    notifyListeners();
  }
} 