import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class TagService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get _userId => _auth.currentUser?.uid;

  // Get user tags collection reference
  CollectionReference? get _userTagsCollection => 
      _userId != null ? _db.collection('users').doc(_userId).collection('tags') : null;

  // Get all user tags
  Stream<List<UserTag>> getUserTags() {
    if (_userId == null) return Stream.value([]);
    
    return _userTagsCollection!.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => UserTag.fromFirestore(doc))
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    });
  }

  // Create or update tag
  Future<void> saveTag(UserTag tag) async {
    if (_userId == null) throw Exception('User not authenticated');
    
    if (kDebugMode) {
      print('TagService: Saving tag "${tag.name}" for user $_userId');
    }
    
    final docRef = tag.id != null 
        ? _userTagsCollection!.doc(tag.id)
        : _userTagsCollection!.doc();
    
    await docRef.set({
      'name': tag.name.toLowerCase().trim(),
      'color': tag.color,
      'description': tag.description,
      'createdAt': tag.createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Delete tag
  Future<void> deleteTag(String tagId) async {
    if (_userId == null) throw Exception('User not authenticated');
    
    if (kDebugMode) {
      print('TagService: Deleting tag $tagId for user $_userId');
    }
    
    await _userTagsCollection!.doc(tagId).delete();
  }

  // Get tag usage statistics
  Future<Map<String, int>> getTagUsageStats(List<String> availableTags) async {
    if (_userId == null) return {};
    
    final stats = <String, int>{};
    
    for (String tag in availableTags) {
      final snapshot = await _db.collection('tasks')
          .where('userId', isEqualTo: _userId)
          .where('tags', arrayContains: tag)
          .get();
      
      stats[tag] = snapshot.docs.length;
    }
    
    return stats;
  }

  // Check if tag exists
  Future<bool> tagExists(String tagName) async {
    if (_userId == null) return false;
    
    final snapshot = await _userTagsCollection!
        .where('name', isEqualTo: tagName.toLowerCase().trim())
        .get();
    
    return snapshot.docs.isNotEmpty;
  }
}

class UserTag {
  final String? id;
  final String name;
  final String color;
  final String description;
  final DateTime? createdAt;

  UserTag({
    this.id,
    required this.name,
    this.color = '#2196F3',
    this.description = '',
    this.createdAt,
  });

  factory UserTag.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return UserTag(
      id: doc.id,
      name: data['name'] ?? '',
      color: data['color'] ?? '#2196F3',
      description: data['description'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name.toLowerCase().trim(),
      'color': color,
      'description': description,
      'createdAt': createdAt,
    };
  }

  UserTag copyWith({
    String? id,
    String? name,
    String? color,
    String? description,
    DateTime? createdAt,
  }) {
    return UserTag(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
} 