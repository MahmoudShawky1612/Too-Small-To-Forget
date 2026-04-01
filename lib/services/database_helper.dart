import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:toosmalltoforget/models/memory.dart';
import 'package:toosmalltoforget/models/category.dart'; // We'll create this

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'memories.db');
    // Version 2: added categories table and new columns
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade, // <-- new: handle existing databases
    );
  }

  // Called when the database is created for the first time (fresh install)
  Future<void> _onCreate(Database db, int version) async {
    // Create categories table
    await db.execute('''
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      )
    ''');
    // Create memories table with new columns
    await db.execute('''
      CREATE TABLE memories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        details TEXT NOT NULL,
        date TEXT NOT NULL,
        categoryId INTEGER,
        reminder TEXT,
        photoPath TEXT
      )
    ''');
  }

  // Called when the database version in code is higher than the existing version on disk
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add categories table
      await db.execute('''
        CREATE TABLE categories(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL UNIQUE
        )
      ''');
      // Add new columns to existing memories table
      await db.execute('ALTER TABLE memories ADD COLUMN categoryId INTEGER');
      await db.execute('ALTER TABLE memories ADD COLUMN photoPath TEXT');
    }
  }

  // -------- Category CRUD ----------
  Future<int> insertCategory(Category category) async {
    Database db = await database;
    return await db.insert('categories', category.toMap());
  }

  Future<List<Category>> getAllCategories() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('categories', orderBy: 'name');
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  Future<int> deleteCategory(int id) async {
    Database db = await database;
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  // -------- Memory CRUD (with filters) ----------
  // Insert memory
  Future<int> insertMemory(Memory memory) async {
    Database db = await database;
    return await db.insert('memories', memory.toMap());
  }

  // Get all memories (or filtered by category and/or search query)
  Future<List<Memory>> getMemories({int? categoryId, String? searchQuery}) async {
    Database db = await database;
    List<String> conditions = [];
    List<Object?> args = [];

    if (categoryId != null) {
      conditions.add('categoryId = ?');
      args.add(categoryId);
    }
    if (searchQuery != null && searchQuery.isNotEmpty) {
      conditions.add('(title LIKE ? OR details LIKE ?)');
      args.add('%$searchQuery%');
      args.add('%$searchQuery%');
    }

    String? whereClause = conditions.isNotEmpty ? conditions.join(' AND ') : null;

    List<Map<String, dynamic>> maps = await db.query(
      'memories',
      where: whereClause,
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => Memory.fromMap(maps[i]));
  }

  // Convenience methods (for backward compatibility)
  Future<List<Memory>> getAllMemories() async {
    return getMemories(); // no filters
  }

  Future<List<Memory>> searchMemories(String query) async {
    return getMemories(searchQuery: query);
  }

  Future<int> updateMemory(Memory memory) async {
    Database db = await database;
    return await db.update(
      'memories',
      memory.toMap(),
      where: 'id = ?',
      whereArgs: [memory.id],
    );
  }

  Future<int> deleteMemory(int id) async {
    Database db = await database;
    return await db.delete('memories', where: 'id = ?', whereArgs: [id]);
  }
}