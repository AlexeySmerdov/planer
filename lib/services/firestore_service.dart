import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../utils/time_formatter.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get _userId => _auth.currentUser?.uid;

  // Simple collections references
  CollectionReference get _tasksCollection => _db.collection('tasks');

  // Create task
  Future<String> createTask(Task task) async {
    if (_userId == null) throw Exception('User not authenticated');
    
    if (kDebugMode) {
      print('FirestoreService: Creating task for user $_userId');
      print('Task data: ${task.title} - ${task.description}');
    }
    
    final docRef = await _tasksCollection.add({
      'userId': _userId, // Add userId to filter tasks by user
      'title': task.title,
      'description': task.description,
      'dueDate': Timestamp.fromDate(task.dueDate),
      'dueTime': task.dueTime != null ? TimeFormatter.timeToString(task.dueTime!) : null,
      'isCompleted': task.isCompleted,
      'images': task.images,
      'tags': task.tags,
      'richTextContent': task.richTextContent,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    
    if (kDebugMode) {
      print('FirestoreService: Task created with ID: ${docRef.id}');
    }
    
    return docRef.id;
  }

  // Get all tasks for current user
  Stream<List<Task>> getTasks() {
    if (_userId == null) return Stream.value([]);
    
    return _tasksCollection
        .where('userId', isEqualTo: _userId)
        .snapshots()
        .map((snapshot) {
          final tasks = snapshot.docs
              .map((doc) => Task.fromFirestore(doc))
              .toList();
          // Sort by dueDate on client side while index is building
          tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
          return tasks;
        });
  }

  // Get tasks for specific date
  Stream<List<Task>> getTasksForDate(DateTime date) {
    if (_userId == null) return Stream.value([]);
    
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    
    return _tasksCollection
        .where('userId', isEqualTo: _userId)
        .where('dueDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('dueDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Task.fromFirestore(doc))
            .toList());
  }

  // Update task
  Future<void> updateTask(Task task) async {
    if (_userId == null || task.id == null) throw Exception('Invalid task or user');
    
    await _tasksCollection.doc(task.id).update({
      'title': task.title,
      'description': task.description,
      'dueDate': Timestamp.fromDate(task.dueDate),
      'dueTime': task.dueTime != null ? TimeFormatter.timeToString(task.dueTime!) : null,
      'isCompleted': task.isCompleted,
      'images': task.images,
      'tags': task.tags,
      'richTextContent': task.richTextContent,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Delete task
  Future<void> deleteTask(String taskId) async {
    if (_userId == null) throw Exception('User not authenticated');
    
    await _tasksCollection.doc(taskId).delete();
  }

  // Mark task as completed/incomplete
  Future<void> toggleTaskCompletion(String taskId, bool isCompleted) async {
    if (_userId == null) throw Exception('User not authenticated');
    
    await _tasksCollection.doc(taskId).update({
      'isCompleted': isCompleted,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
} 