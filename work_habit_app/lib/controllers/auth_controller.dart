import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';

class AuthController extends ChangeNotifier{
  AuthController._privateConstructor();
  static final AuthController instance = AuthController._privateConstructor();

  Database? _db;
  User? currentUser;

  // Expose the database instance
  Database get db => _db!;

  Future<void> initDatabase() async {
    // Get the default databases location using path_provider
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'users.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Create the users table
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT UNIQUE,
            password TEXT,
            member_since TEXT
          )
        ''');
        // Create the daily_targets table (for target seconds)
        await db.execute('''
        CREATE TABLE daily_targets(
          user_email TEXT PRIMARY KEY,
          target REAL
        )
      ''');
        // Create the daily_logs table to track working seconds per day
        await db.execute('''
        CREATE TABLE daily_logs(
          user_email TEXT,
          date TEXT,
          working_seconds REAL,
          PRIMARY KEY (user_email, date)
        )
      ''');
      },
    );
  }

  // Sign up a new user. Returns an error message if fails, otherwise null.
  Future<String?> signUp(String email, String password) async {
    try {
      // Check if user already exists
      final List<Map<String, dynamic>> maps = await _db!.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );
      if (maps.isNotEmpty) {
        return 'User already exists with that email.';
      }

      // Insert the user into the database.
      await _db!.insert(
        'users',
        User(email: email, password: password, memberSince: DateTime.now()).toMap(),
      );

      // Insert default daily target for new user (default value: 1220)
      // await _db!.insert(
      //   'daily_targets',
      //   {'user_email': email, 'target': 1220},
      //   conflictAlgorithm: ConflictAlgorithm.replace,
      // );

      return null; // Sign up successful
    } catch (e) {
      return 'Sign up failed: ${e.toString()}';
    }
  }

  Future<String?> login(String email, String password) async {
    try {
      final List<Map<String, dynamic>> maps = await _db!.query(
        'users',
        where: 'email = ? AND password = ?',
        whereArgs: [email, password],
      );
      if (maps.isEmpty) {
        return 'Invalid email or password.';
      }
      currentUser = User.fromMap(maps.first);

      // Save login state in Hive
      var box = await Hive.openBox('settings');
      await box.put('isLoggedIn', true);
      await box.put('userEmail', email); // if you want to use user details later

      return null; // Login successful
    } catch (e) {
      return 'Login failed: ${e.toString()}';
    }
  }


  void signOut() async {
    currentUser = null;
    var box = await Hive.openBox('settings');
    await box.put('isLoggedIn', false);
    // Optionally remove user details
    await box.delete('userEmail');
  }

  Future<void> restoreUser() async {
    var box = await Hive.openBox('settings');
    String? email = box.get('userEmail');
    if (email != null) {
      final List<Map<String, dynamic>> maps = await _db!.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );
      if (maps.isNotEmpty) {
        currentUser = User.fromMap(maps.first);
      }
    }
  }

  Future<String?> updateEmail(String newEmail) async {
    if (currentUser == null) return 'User belum login.';
    String oldEmail = currentUser!.email;
    try {
      // Update pada tabel users
      await _db!.update(
        'users',
        {'email': newEmail},
        where: 'id = ?',
        whereArgs: [currentUser!.id],
      );
      // Update record daily_targets agar target tetap tersimpan
      await _db!.update(
        'daily_targets',
        {'user_email': newEmail},
        where: 'user_email = ?',
        whereArgs: [oldEmail],
      );
      // Perbarui currentUser dengan email baru
      currentUser = User(
        id: currentUser!.id,
        email: newEmail,
        password: currentUser!.password,
        memberSince: currentUser!.memberSince,
      );
      notifyListeners();
      return null;
    } catch (e) {
      return 'Gagal memperbarui email: ${e.toString()}';
    }
  }

  Future<String?> updatePassword(String newPassword) async {
    if (currentUser == null) return 'User belum login.';
    try {
      await _db!.update(
        'users',
        {'password': newPassword},
        where: 'id = ?',
        whereArgs: [currentUser!.id],
      );
      // Perbarui currentUser
      currentUser = User(
        id: currentUser!.id,
        email: currentUser!.email,
        password: newPassword,
        memberSince: currentUser!.memberSince,
      );
      notifyListeners();
      return null;
    } catch (e) {
      return 'Gagal memperbarui password: ${e.toString()}';
    }
  }



}
