import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'fitness_app_db.dart';

/// This class handles the database operations for the fitness app.
/// It initializes the database, provides the database instance, and creates the database schema.
class DatabaseService {
  // The database instance
  Database? _database;

  // Getter for the database instance
  Future<Database> get database async {
    // If the database is already initialized, return it
    if (_database != null) {
      return _database!;
    }
    // Otherwise, initialize the database
    _database = await initDatabase();
    return _database!;
  }

  // Getter for the full path of the database file
  Future<String> get fullPath async {
    const name = 'fitnessApp.db'; // The name of the database file
    final path = await getDatabasesPath(); // Get the path to the databases directory
    return join(path, name); // Join the path and the name to get the full path
  }

  // Initialize the database
  Future<Database> initDatabase() async {
    final path = await fullPath; // Get the full path of the database file
    var database = await openDatabase(
      path, // The path to the database file
      version: 1, // The version of the database
      onCreate: create, // The function to call when creating the database
      singleInstance: true, // Ensure that only one instance of the database is created
    );
    return database; // Return the database instance
  }

  // Create the database schema
  Future<void> create(Database database, int version) async =>
      await FitnessAppDB().createDB(database); // Call the createDB function from FitnessAppDB
}