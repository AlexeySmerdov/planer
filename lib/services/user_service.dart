import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get _userId => _auth.currentUser?.uid;

  // Get user document reference
  DocumentReference? get _userDoc => _userId != null ? _db.collection('users').doc(_userId) : null;

  // Get user data stream
  Stream<Map<String, dynamic>?> getUserData() {
    if (_userId == null) return Stream.value(null);
    
    return _userDoc!.snapshots().map((doc) {
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      }
      return null;
    });
  }

  // Update taskToday field
  Future<void> updateTaskToday(String text) async {
    if (_userId == null) throw Exception('User not authenticated');
    
    if (kDebugMode) {
      print('UserService: Updating taskToday for user $_userId');
    }
    
    await _userDoc!.set({
      'taskToday': text,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Update taskTomorrow field
  Future<void> updateTaskTomorrow(String text) async {
    if (_userId == null) throw Exception('User not authenticated');
    
    if (kDebugMode) {
      print('UserService: Updating taskTomorrow for user $_userId');
    }
    
    await _userDoc!.set({
      'taskTomorrow': text,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Get taskToday
  Future<String> getTaskToday() async {
    if (_userId == null) return '';
    
    final doc = await _userDoc!.get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>?;
      return data?['taskToday'] ?? '';
    }
    return '';
  }

  // Get taskTomorrow
  Future<String> getTaskTomorrow() async {
    if (_userId == null) return '';
    
    final doc = await _userDoc!.get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>?;
      return data?['taskTomorrow'] ?? '';
    }
    return '';
  }
} 