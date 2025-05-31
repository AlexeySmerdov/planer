import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../utils/time_formatter.dart';

class Task {
  final String? id;
  String title;
  String description;
  DateTime dueDate;
  TimeOfDay? dueTime;
  bool isCompleted;
  List<String> images; // stores base64-encoded image data
  List<String> tags; // Added tags field
  dynamic richTextContent;  // Made public directly

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.dueTime,
    this.isCompleted = false,
    this.images = const [],
    this.tags = const [], // Added tags parameter
    dynamic richTextContent = const [],
  }) : richTextContent = richTextContent;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'dueTime': dueTime != null ? TimeFormatter.timeToString(dueTime!) : null,
      'isCompleted': isCompleted ? 1 : 0,
      'images': images.join(','),
      'tags': tags.join(','), // Added tags to map
      'richTextContent': richTextContent.toString(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    var content = map['richTextContent'];
    dynamic richContent = const [];
    
    if (content != null && content.isNotEmpty) {
      try {
        if (content is String) {
          // Handle the case where it might be stored as string
          richContent = content;
        } else {
          richContent = content;
        }
      } catch (e) {
        richContent = const [];
      }
    }

    return Task(
      id: map['id']?.toString(),
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      dueDate: DateTime.parse(map['dueDate']),
      dueTime: TimeFormatter.stringToTime(map['dueTime']),
      isCompleted: map['isCompleted'] == 1,
      images: map['images']?.toString().split(',').where((s) => s.isNotEmpty).toList() ?? [],
      tags: map['tags']?.toString().split(',').where((s) => s.isNotEmpty).toList() ?? [], // Added tags parsing
      richTextContent: richContent,
    );
  }

  // Firestore constructor
  factory Task.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Task(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      dueTime: TimeFormatter.stringToTime(data['dueTime']),
      isCompleted: data['isCompleted'] ?? false,
      images: List<String>.from(data['images'] ?? []),
      tags: List<String>.from(data['tags'] ?? []), // Added tags from Firestore
      richTextContent: data['richTextContent'] ?? const [],
    );
  }
} 