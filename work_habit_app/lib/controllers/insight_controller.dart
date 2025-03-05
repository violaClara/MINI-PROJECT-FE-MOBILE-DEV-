import 'package:intl/intl.dart';
import 'auth_controller.dart'; // sesuaikan path-nya

// Model data insight
class InsightData {
  final double trackedPercentage; // (%) = (trackedDays/totalDaysInMonth)*100
  final int currentStreak;
  final int longestStreak;
  final Map<String, bool> yearlyTrackedMap;
  final Map<String, bool> monthlyTrackedMap;
  final int currentMonth;
  final int currentYear;

  InsightData({
    required this.trackedPercentage,
    required this.currentStreak,
    required this.longestStreak,
    required this.yearlyTrackedMap,
    required this.monthlyTrackedMap,
    required this.currentMonth,
    required this.currentYear,
  });
}

// Helper function untuk format tanggal menjadi "YYYY-MM-DD"
String formatDate(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

// Fungsi untuk mengambil data insight dari database
Future<InsightData> loadInsightData() async {
  final user = AuthController.instance.currentUser;
  if (user == null) {
    return InsightData(
      trackedPercentage: 0,
      currentStreak: 0,
      longestStreak: 0,
      yearlyTrackedMap: {},
      monthlyTrackedMap: {},
      currentMonth: DateTime.now().month,
      currentYear: DateTime.now().year,
    );
  }

  final db = AuthController.instance.db;
  final String userEmail = user.email;
  DateTime now = DateTime.now();
  int currentYear = now.year;
  int currentMonth = now.month;

  // 1. Ambil data log untuk bulan ini
  DateTime monthStart = DateTime(currentYear, currentMonth, 1);
  DateTime monthEnd = DateTime(currentYear, currentMonth + 1, 0); // hari terakhir bulan ini
  List<Map<String, dynamic>> monthlyLogs = await db.query(
    'daily_logs',
    where: 'user_email = ? AND date BETWEEN ? AND ?',
    whereArgs: [userEmail, formatDate(monthStart), formatDate(monthEnd)],
  );
  Map<String, bool> monthlyTrackedMap = {};
  int totalDaysInMonth = monthEnd.day;
  int countTracked = 0;
  for (int day = 1; day <= totalDaysInMonth; day++) {
    DateTime date = DateTime(currentYear, currentMonth, day);
    String key = formatDate(date);
    bool tracked = monthlyLogs.any((log) {
      return log['date'] == key && (log['working_seconds'] as num) > 0;
    });
    monthlyTrackedMap[key] = tracked;
    if (tracked) countTracked++;
  }
  double trackedPercentage = (countTracked / totalDaysInMonth) * 100;

  // 2. Ambil data log dari memberSince sampai hari ini untuk hitung streak
  DateTime memberSince = user.memberSince;
  DateTime streakStart = memberSince.isAfter(now) ? now : memberSince;
  List<Map<String, dynamic>> streakLogs = await db.query(
    'daily_logs',
    where: 'user_email = ? AND date BETWEEN ? AND ?',
    whereArgs: [userEmail, formatDate(streakStart), formatDate(now)],
  );
  Set<String> trackedDates = streakLogs
      .where((log) => (log['working_seconds'] as num) > 0)
      .map<String>((log) => log['date'] as String)
      .toSet();

  int currentStreak = 0;
  DateTime checkDate = now;
  while (trackedDates.contains(formatDate(checkDate))) {
    currentStreak++;
    checkDate = checkDate.subtract(Duration(days: 1));
  }

  int longestStreak = 0;
  int tempStreak = 0;
  DateTime iterDate = streakStart;
  while (!iterDate.isAfter(now)) {
    if (trackedDates.contains(formatDate(iterDate))) {
      tempStreak++;
      if (tempStreak > longestStreak) longestStreak = tempStreak;
    } else {
      tempStreak = 0;
    }
    iterDate = iterDate.add(Duration(days: 1));
  }

  // 3. Ambil data log untuk tahun ini (grid yearly view)
  DateTime yearStart = DateTime(currentYear, 1, 1);
  DateTime yearEnd = DateTime(currentYear, 12, 31);
  List<Map<String, dynamic>> yearlyLogs = await db.query(
    'daily_logs',
    where: 'user_email = ? AND date BETWEEN ? AND ?',
    whereArgs: [userEmail, formatDate(yearStart), formatDate(yearEnd)],
  );
  Map<String, bool> yearlyTrackedMap = {};
  int daysInYear = yearEnd.difference(yearStart).inDays + 1;
  for (int i = 0; i < daysInYear; i++) {
    DateTime date = yearStart.add(Duration(days: i));
    String key = formatDate(date);
    bool tracked = yearlyLogs.any((log) {
      return log['date'] == key && (log['working_seconds'] as num) > 0;
    });
    yearlyTrackedMap[key] = tracked;
  }

  return InsightData(
    trackedPercentage: trackedPercentage,
    currentStreak: currentStreak,
    longestStreak: longestStreak,
    yearlyTrackedMap: yearlyTrackedMap,
    monthlyTrackedMap: monthlyTrackedMap,
    currentMonth: currentMonth,
    currentYear: currentYear,
  );
}