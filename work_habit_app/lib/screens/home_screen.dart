import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'insight_screen.dart';
import 'profile_screen.dart';
import '../controllers/target_controller.dart';
import '../controllers/auth_controller.dart';
import 'dart:async'; // Add this import for Timer
import '../widgets/expenditure_chart_dialog.dart';
import '../widgets/bottom_navbar.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dashboard Demo',
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {

  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // false = "Worked" aktif, true = "Remaining" aktif
  bool isRemainingSelected = false;
  Timer? _timer;
  double _workSeconds = 0; // total working seconds today

  // Nilai kerja tetap (hardcoded)
  final double workValue = 656;
  // Target kerja harian (default fallback jika belum diatur)
  double? _targetValue;
  final TargetController _targetController = TargetController();

  // Declare currentUserEmail properly
  late final String currentUserEmail;

  @override
  void initState() {
    super.initState();
    // Mengambil email dari user yang sedang login
    currentUserEmail = AuthController.instance.currentUser?.email ?? "userbaru@example.com";
    _checkDailyTarget();
    _loadTodayWorking();
    _startWorkTimer();
  }

  // Load today's working seconds from the DB:
  void _loadTodayWorking() async {
    double savedWork = await _targetController.getTodayWorking(currentUserEmail);
    setState(() {
      _workSeconds = savedWork;
    });
  }

  void _startWorkTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _workSeconds += 1; // increment by one second
      });
      // Update daily log in the database
      _targetController.updateDailyLog(currentUserEmail, _workSeconds);

      // Optional: check if work target is reached
      if (_targetValue != null && _workSeconds >= _targetValue!) {
        _timer?.cancel();
        _showCompletionDialog();
      }
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Congratulations!"),
          content: const Text("You have completed your work target for today!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  String _formatTime(int totalSeconds) {
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;
    return "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }


  void _checkDailyTarget() async {
    double? target = await _targetController.getDailyTarget(currentUserEmail);
    if (target == null) {
      // No target set, so display the dialog.
      _showSetTargetDialog();
    } else {
      setState(() {
        _targetValue = target;
      });
    }
  }



  void _showSetTargetDialog() {
    int selectedHours = 1; // default selection

    showDialog(
      context: context,
      barrierDismissible: false, // force target set
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Set Daily Work Hours Target"),
          content: StatefulBuilder(
            builder: (context, setState) {
              return DropdownButton<int>(
                value: selectedHours,
                onChanged: (newValue) {
                  setState(() {
                    selectedHours = newValue!;
                  });
                },
                items: List.generate(24, (index) => index + 1) // 1 to 24 hours
                    .map<DropdownMenuItem<int>>((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text("$value hours"),
                  );
                }).toList(),
              );
            },
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                // Convert hours to seconds (e.g. 8 hours = 8*3600 seconds)
                double targetSeconds = selectedHours * 3600.0;
                await _targetController.setDailyTarget(currentUserEmail, targetSeconds);
                // Also, create a daily log record for today (see Step 3)
                await _targetController.initDailyLog(currentUserEmail);
                setState(() {
                  _targetValue = targetSeconds;
                });
                Navigator.of(context).pop();
              },
              child: const Text("Set Target"),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate =
        "${_getDayName(now.weekday).toUpperCase()}, ${now.day} ${_getMonthName(now.month).toUpperCase()}";

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final authController = Provider.of<AuthController>(context, listen: false);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[100],
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Container utama dengan background putih dan padding 24
            Container(
              color: theme.scaffoldBackgroundColor,
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tanggal
                  Text(
                    formattedDate,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Judul Dashboard
                  const Text(
                    "Dashboard",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Subjudul
                  const Text(
                    "Work Log Focus",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Baris Info: (kolom kiri berubah), Lingkaran (center), Target
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Kolom kiri dengan teks yang berubah (fade in/fade out)
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) =>
                            FadeTransition(opacity: animation, child: child),
                        child: isRemainingSelected
                            ? Column(
                          key: const ValueKey("worked_left"),
                          children: [
                            Text(
                              (_workSeconds ~/ 60).toString(), // Show working minutes dynamically
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              "Working",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        )
                            : Column(
                          key: const ValueKey("remaining_left"),
                          children: [
                            Text(
                              _targetValue != null ? ((_targetValue! - _workSeconds) ~/ 60).toString() : "-",
                              // Show remaining minutes dynamically
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              "Remaining",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Lingkaran (gauge) dengan konten yang bisa berubah (center)
                      Stack(
                        children: [
                          // Gambar gauge via CustomPaint
                          // Gauge widget:
                          CustomPaint(
                            size: const Size(150, 150),
                            painter: CirclePainter(
                              workValue: _workSeconds,
                              targetValue: _targetValue ?? 3600, // default fallback of 1 hour in seconds
                              showRemaining: isRemainingSelected,
                            ),
                          ),
                          // Konten di tengah gauge (di-animate)
                          Positioned.fill(
                            child: Center(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                transitionBuilder: (child, animation) =>
                                    FadeTransition(opacity: animation, child: child),
                                child: isRemainingSelected
                                    ? Column(
                                  key: const ValueKey("remaining_center"),
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _targetValue != null ? ((_targetValue! - _workSeconds) ~/ 60).toString() : "-",
                                      style: const TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Text(
                                      "Remaining",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                )
                                    : Column(
                                  key: const ValueKey("worked_center"),
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      (_workSeconds ~/ 60).toString(), // Ensure at least 1 is shown // Convert seconds to minutes,
                                      style: const TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Text(
                                      "Working",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),

                              ),
                            ),
                          ),
                        ],
                      ),
                      // Kolom Target (menampilkan target yang telah diset)
                      // Replace the current target Column in your Row with this GestureDetector
                      // After: shows '-' when _targetValue is null
                      GestureDetector(
                        onTap: () {
                          _showSetTargetDialog();
                        },
                        child: Column(
                          children: [
                            Text(
                              _targetValue != null ? (_targetValue! ~/ 60).toString() : "-", // Convert to minutes
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              "Target",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),

                    ],
                  ),
                  const SizedBox(height: 16),
                  // Baris Progress (Failed, Progress, Success)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ProgressBox(
                        title: "Failed",
                        value: "42",
                        total: "77 %",
                        progress: 0.54,
                        color: Colors.orange,
                      ),
                      ProgressBox(
                        title: "Progress",
                        value: "20",
                        total: "40 %",
                        progress: 0.50,
                        color: Colors.yellow[700]!,
                      ),
                      ProgressBox(
                        title: "Success",
                        value: "85",
                        total: "136 %",
                        progress: 0.625,
                        color: Colors.green,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Baris tombol: Worked & Remaining
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isRemainingSelected
                              ?  colorScheme.onPrimary
                              : colorScheme.primary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          if (isRemainingSelected) {
                            setState(() {
                              isRemainingSelected = false;
                            });
                          }
                        },
                        child: Text(
                          "Worked",
                          style: TextStyle(
                            color: isRemainingSelected
                                ? colorScheme.primary
                                : (isDarkMode ? Colors.grey[900] : colorScheme.secondary),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isRemainingSelected
                              ? colorScheme.primary
                              : colorScheme.onPrimary,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          if (!isRemainingSelected) {
                            setState(() {
                              isRemainingSelected = true;
                            });
                          }
                        },
                        child: Text(
                          "Remaining",
                          style: TextStyle(
                            color: isRemainingSelected
                                ? colorScheme.onPrimary
                                : colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Indikator titik (3 dots)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                DotIndicator(),
                DotIndicator(),
                DotIndicator(),
              ],
            ),
            const SizedBox(height: 32),
            // Section Insight & Analytics
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Header section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Insight & Analytics",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => InsightScreen()),
                          );
                        },
                        child: Text(
                          ">",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Dua kartu: Expenditure & Habits Trend
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => ExpenditureChartDialog(),
                            );
                          },
                          child: CardWidget(
                            title: "Expenditure",
                            titleColor: colorScheme.primary, // Dynamic title color from your theme
                            dateRange: "19 Aug - Now",
                            imageUrl:
                            'assets/icons/chart1.png',
                            taskCount: "1426",
                            taskLabel: "Task",
                            margin: const EdgeInsets.only(right: 8),
                          ),
                        ),
                      ),
                      Expanded(
                        child: CardWidget(
                          title: "Habits Trend",
                          titleColor: colorScheme.primary, // Dynamic title color from your theme
                          dateRange: "19 Aug - Now",
                          imageUrl:
                          'assets/icons/chart2.png',
                          taskCount: "1426",
                          taskLabel: "Task",
                          margin: const EdgeInsets.only(left: 8),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0, // 0 for Dashboard (HomeScreen)
        onTap: (index) {
          switch (index) {
            case 0:
            // Already here.
              break;
            case 1:
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/insight');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/profile');
              break;
          }
        },
      ),
    );
  }
}

String _getDayName(int day) {
  switch (day) {
    case 1:
      return "Monday";
    case 2:
      return "Tuesday";
    case 3:
      return "Wednesday";
    case 4:
      return "Thursday";
    case 5:
      return "Friday";
    case 6:
      return "Saturday";
    case 7:
      return "Sunday";
    default:
      return "";
  }
}

String _getMonthName(int month) {
  switch (month) {
    case 1:
      return "January";
    case 2:
      return "February";
    case 3:
      return "March";
    case 4:
      return "April";
    case 5:
      return "May";
    case 6:
      return "June";
    case 7:
      return "July";
    case 8:
      return "August";
    case 9:
      return "September";
    case 10:
      return "October";
    case 11:
      return "November";
    case 12:
      return "December";
    default:
      return "";
  }
}

/// CustomPainter untuk menggambar gauge (busur) seperti speedometer
class CirclePainter extends CustomPainter {
  final double workValue;
  final double targetValue;
  final bool showRemaining;
  CirclePainter({
    required this.workValue,
    required this.targetValue,
    required this.showRemaining,
  });
  @override
  void paint(Canvas canvas, Size size) {
    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    // Ubah orientasi: mulai dari 150° (5π/6) dan sweep 240° (4π/3)
    double startAngle = 5 * pi / 6;
    double fullSweep = 4 * pi / 3;

    // Hitung progress
    double progress = !showRemaining
        ? workValue / targetValue
        : (targetValue - workValue) / targetValue;
    progress = progress.clamp(0.0, 1.0);

    // Background arc (abu-abu muda)
    Paint backgroundPaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    canvas.drawArc(rect, startAngle, fullSweep, false, backgroundPaint);

    // Foreground arc (biru)
    Paint foregroundPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 8;
    canvas.drawArc(rect, startAngle, fullSweep * progress, false, foregroundPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Widget untuk progress bar (Failed, Progress, Success)
class ProgressBox extends StatelessWidget {
  final String title;
  final String value;
  final String total;
  final double progress;
  final Color color;
  const ProgressBox({
    super.key,
    required this.title,
    required this.value,
    required this.total,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Container(
          width: 80,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(3),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              "/ $total",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }
}

/// Widget untuk indikator titik (3 dots)
class DotIndicator extends StatelessWidget {
  const DotIndicator({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.grey[400],
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Widget untuk kartu Insight & Analytics
class CardWidget extends StatelessWidget {
  final String title;
  final Color titleColor; // New property for title color
  final String dateRange;
  final String imageUrl;
  final String taskCount;
  final String taskLabel;
  final EdgeInsets margin;
  const CardWidget({
    super.key,
    required this.title,
    this.titleColor = Colors.white, // Default title color
    required this.dateRange,
    required this.imageUrl,
    required this.taskCount,
    required this.taskLabel,
    required this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            dateRange,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Image.asset(
            imageUrl, // load asset image
            height: 50,
            width: 100,
          ),
          const SizedBox(height: 8),
          Divider(color: Colors.grey[200]),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              text: taskCount,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
              children: [
                TextSpan(
                  text: ' $taskLabel',
                  style: TextStyle(fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


/// Widget khusus untuk ikon Analytic (3 titik tersusun)
class AnalyticIcon extends StatelessWidget {
  const AnalyticIcon({super.key});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: Stack(
        children: [
          // Titik kiri atas
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Titik kanan atas
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Titik bawah tengah
          const Positioned(
            bottom: 0,
            left: 8,
            child: SizedBox(
              width: 8,
              height: 8,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}