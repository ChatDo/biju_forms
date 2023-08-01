import 'dart:io' show Platform;

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseService {
  String dbName = "person.db";
  int dbVersion = 1;

  static final DatabaseService _databaseService = DatabaseService._internal();

  factory DatabaseService() => _databaseService;

  DatabaseService._internal();

  static Database? _database;
  static late String _path;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  String get path => _path;

  Future<Database> _initDatabase() async {
    print("Init DB");
    Database db = await _getDB();

    return db;
  }

  Future<Database> _getDB() async {
    if (Platform.isAndroid) {
      _path = await _getPath(); // Get a location using getDatabasesPath
    } else {
      _path = inMemoryDatabasePath;
    }

    return await openDatabase(
      _path,
      onCreate: _onCreate,
      version: dbVersion,
      onConfigure: (db) async => await db.execute('PRAGMA foreign_keys = ON'),
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    print("Init DB: CREATE TABLES");
    await db.execute(
      'CREATE TABLE person(id INTEGER PRIMARY KEY, name TEXT, firstname TEXT, city TEXT, username TEXT, email TEXT UNIQUE, lottery TEXT, phone TEXT, tournament TEXT, team_name TEXT, game_name TEXT, registered_at TEXT, last_modified TEXT);',
    );
  }

  Future<String> _getPath() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, dbName);
    return path;
  }
}
