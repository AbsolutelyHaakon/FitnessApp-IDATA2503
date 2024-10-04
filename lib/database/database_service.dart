import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'fitness_app_db.dart';


class DatabaseService {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await initDatabase();
    return _database!;
  }

  Future<String> get fullPath async {
    const name = 'fitnessApp.db';
    final path = await getDatabasesPath();
    return join(path, name);
  }

  Future<Database> initDatabase() async {
    final path = await fullPath;
    var database = await openDatabase(
      path,
      version: 1,
      onCreate: create,
      singleInstance: true,
    );
    return database;
  }

  Future<void> create(Database database, int version) async =>
      await FitnessAppDB().createDB(database);
}