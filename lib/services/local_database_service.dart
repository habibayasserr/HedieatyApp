import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabaseService {
  static Database? _database;

  // Initialize database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final path = await getDatabasesPath();
    final dbPath = join(path, 'hedieaty.db');

    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Drop tables if they already exist (useful for development)
    await db.execute('DROP TABLE IF EXISTS Users');
    await db.execute('DROP TABLE IF EXISTS Events');
    await db.execute('DROP TABLE IF EXISTS Friends');

    // Create Users table
    await db.execute('''
    CREATE TABLE Users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      phone TEXT NOT NULL UNIQUE,
      email TEXT NOT NULL UNIQUE,
     
    )
  ''');

    // Create Events table
    await db.execute('''
    CREATE TABLE Events (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      date TEXT NOT NULL, 
      location TEXT NOT NULL,
      description TEXT NOT NULL,
      category TEXT NOT NULL DEFAULT 'General',
      user_id INTEGER NOT NULL,
      FOREIGN KEY (user_id) REFERENCES Users (id) ON DELETE CASCADE
    )
  ''');

    // Create Friends table
    await db.execute('''
    CREATE TABLE Friends (
      user_id INTEGER NOT NULL,               
      friend_user_id INTEGER NOT NULL,         
      FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE,
      FOREIGN KEY (friend_user_id) REFERENCES Users(id) ON DELETE CASCADE,
      PRIMARY KEY (user_id, friend_user_id)   
    );

  ''');
  }

// **1. Fetch All Events**
  Future<List<Map<String, dynamic>>> getAllEvents() async {
    final db = await database;
    return await db.query('Events'); // Fetch all rows from Events table
  }

  // **2. Insert New Event**
  Future<void> insertEvent(Map<String, dynamic> eventData) async {
    final db = await database;
    await db.insert(
      'Events',
      eventData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // **3. Update an Event**
  Future<void> updateEvent(Map<String, dynamic> eventData, int id) async {
    final db = await database;
    await db.update(
      'Events',
      eventData,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // **4. Delete an Event**
  Future<void> deleteEvent(int id) async {
    final db = await database;
    await db.delete(
      'Events',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getEventsByUserId(String userId) async {
    final db = await database; // Get the database instance
    return await db.query(
      'Events', // Table name
      where: 'user_id = ?', // Query condition
      whereArgs: [userId], // Pass the userId to prevent SQL injection
    );
  }
}
