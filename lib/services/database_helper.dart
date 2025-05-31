import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/task.dart';

class DatabaseHelper {
  static Database? _database;
  static const String tableName = 'tasks';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path;
    
    // For web platform, use a simple database name
    if (kIsWeb) {
      path = 'task_planner.db';
    } else {
      // For mobile/desktop platforms, use the application documents directory
      final Directory documentsDirectory = await getApplicationDocumentsDirectory();
      path = join(documentsDirectory.path, 'task_planner.db');
    }
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE $tableName(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            description TEXT,
            dueDate TEXT,
            isCompleted INTEGER,
            images TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Handle database upgrades here
      },
    );
  }

  Future<int> insertTask(Task task) async {
    final db = await database;
    return await db.insert(tableName, task.toMap());
  }

  Future<List<Task>> getTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  Future<int> updateTask(Task task) async {
    final db = await database;
    return await db.update(
      tableName,
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
} 