import 'package:sqflite/sqflite.dart';
import '../models/daily_target.dart';
import 'auth_controller.dart';

class TargetController {
  // Get the daily target for the given user from the database.
  Future<double?> getDailyTarget(String userEmail) async {
    final db = AuthController.instance.db;
    List<Map<String, dynamic>> result = await db.query(
      'daily_targets',
      where: 'user_email = ?',
      whereArgs: [userEmail],
    );
    if (result.isEmpty) return null;
    return result.first['target'];
  }

  // Set (or update) the daily target for the given user in the database.
  Future<void> setDailyTarget(String userEmail, double target) async {
    final db = AuthController.instance.db;
    await db.insert(
      'daily_targets',
      {'user_email': userEmail, 'target': target},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Returns the working seconds for today (or 0 if not exists)
  Future<double> getTodayWorking(String userEmail) async {
    final db = AuthController.instance.db;
    String today = DateTime.now().toIso8601String().substring(0, 10); // "YYYY-MM-DD"
    List<Map<String, dynamic>> result = await db.query(
      'daily_logs',
      where: 'user_email = ? AND date = ?',
      whereArgs: [userEmail, today],
    );
    if (result.isEmpty) return 0;
    return result.first['working_seconds'];
  }

// Create an initial log record for today if it doesn't exist.
  Future<void> initDailyLog(String userEmail) async {
    final db = AuthController.instance.db;
    String today = DateTime.now().toIso8601String().substring(0, 10);
    // Check if record exists
    List<Map<String, dynamic>> result = await db.query(
      'daily_logs',
      where: 'user_email = ? AND date = ?',
      whereArgs: [userEmail, today],
    );
    if (result.isEmpty) {
      await db.insert(
        'daily_logs',
        {'user_email': userEmail, 'date': today, 'working_seconds': 0},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

// Update the daily log with new working seconds.
  Future<void> updateDailyLog(String userEmail, double workingSeconds) async {
    final db = AuthController.instance.db;
    String today = DateTime.now().toIso8601String().substring(0, 10);
    await db.update(
      'daily_logs',
      {'working_seconds': workingSeconds},
      where: 'user_email = ? AND date = ?',
      whereArgs: [userEmail, today],
    );
  }


}
