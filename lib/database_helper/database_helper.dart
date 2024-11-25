import 'dart:async';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'conversations.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
        CREATE TABLE conversations (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date TEXT,
          question TEXT,
          answer TEXT
        )
      ''');
      },
      // Ensure read-write mode
      readOnly: false,
    );
  }



  Future<int> insertConversation(String date, String question, String answer) async {
    final db = await database;
    return await db.insert('conversations', {
      'date': date,
      'question': question,
      'answer': answer,
    });
  }

  Future<List<Map<String, dynamic>>> getConversations() async {
    final db = await database;
    return await db.query('conversations', orderBy: 'id DESC');
  }

  Future<int> deleteEntry(int id) async {
    try {
      final db = await database;
      print('Attempting to delete from conversations where id = $id');
      final result = await db.delete(
        'conversations',
        where: 'id = ?',
        whereArgs: [id],
      );
      print('Delete result: $result'); // Should print 1 if successful
      return result;
    } catch (e) {
      print('Error deleting entry: $e');
      rethrow;
    }
  }
  Future<void> printAllEntries() async {
    final db = await database;
    final allEntries = await db.query('conversations');
    print('Current database entries: $allEntries');
  }


  Future<void> checkDatabasePermissions() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'conversations.db');

    final file = File(path);
    final isWritable = await file.exists() && await file.stat().then((stat) => stat.mode & 0x92 != 0);

    print('Database is writable: $isWritable');
  }


  Future<int> deleteAllEntries() async {
    final db = await database;
    return await db.delete('conversations');
  }
}
