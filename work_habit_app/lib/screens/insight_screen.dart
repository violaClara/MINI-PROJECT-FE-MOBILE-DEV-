import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controllers/insight_controller.dart'; // Import file logika insight
import '../widgets/bottom_navbar.dart';
import '../widgets/yearly_grid.dart';
import '../widgets/habits_circle_painter.dart';

class InsightScreen extends StatelessWidget {
  const InsightScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double minWhiteHeight = MediaQuery.of(context).size.height - 112;
    return FutureBuilder<InsightData>(
      future: loadInsightData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: Colors.blue[100],
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        InsightData data = snapshot.data!;
        List<String> monthNames = [
          'January', 'February', 'March', 'April', 'May', 'June',
          'July', 'August', 'September', 'October', 'November', 'December'
        ];
        String currentMonthName = monthNames[data.currentMonth - 1];
        final now = DateTime.now();
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        return Scaffold(
          backgroundColor: Colors.blue[100],
          body: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 28),
                  // Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    color: Colors.blue[100],
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.chevron_left, color: Colors.black),
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/home');
                          },
                        ),
                        Text(
                          'Habits',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colorScheme.onSecondary),
                        ),
                        IconButton(
                          icon: Icon(Icons.chevron_left, color: Colors.transparent),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  // Konten Utama
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    constraints: BoxConstraints(minHeight: minWhiteHeight),
                    decoration: BoxDecoration(
                      color: colorScheme.onPrimary,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Judul Insight
                        Column(
                          children: [
                            Container(
                              width: 64,
                              height: 4,
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            const Text(
                              'Insight & Data',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Divider(thickness: 1, color: Colors.grey[200]),
                        const SizedBox(height: 16),
                        // Lingkaran Tracked Rate (warna biru mengikuti persentase)
                        Center(
                          child: SizedBox(
                            width: 192,
                            height: 192,
                            child: Stack(
                              children: [
                                CustomPaint(
                                  size: const Size(192, 192),
                                  painter: HabitsCirclePainter(
                                    trackedPercentage: data.trackedPercentage,
                                  ),
                                ),
                                Positioned.fill(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${data.trackedPercentage.toStringAsFixed(0)}%',
                                        style: const TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        currentMonthName,
                                        style: TextStyle(color: Colors.grey[500]),
                                      ),
                                      Text(
                                        'Tracked Rate',
                                        style: TextStyle(color: Colors.grey[500]),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Work Streaks
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Work Streaks',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/icons/streak.png',
                                  width: 48,
                                  height: 48,
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Longest & Current',
                                      style: TextStyle(color: Colors.grey[500]),
                                    ),
                                    RichText(
                                      text: TextSpan(
                                        text: '${data.currentStreak}',
                                        style: TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.primary,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: 'Days',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.normal,
                                              color: Colors.grey[500],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '${DateFormat('dd MMM yyyy').format(now.subtract(Duration(days: data.currentStreak - 1)))} - Today',
                                      style: TextStyle(color: Colors.grey[500]),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Yearly View (Contribution Grid)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Yearly View',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      margin: const EdgeInsets.only(right: 4),
                                      color: Colors.blue[500],
                                    ),
                                    const Text(
                                      'Tracked',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 16),
                                Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      margin: const EdgeInsets.only(right: 4),
                                      color: Colors.grey[200],
                                    ),
                                    const Text(
                                      'Untracked',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                Text(
                                '${DateTime.now().year}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: colorScheme.primary,
                                ),

                              ),],
                            ),
                            const SizedBox(height: 8),

                            YearlyGrid(trackedMap: data.yearlyTrackedMap),
                          ],
                        ),

                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: BottomNavBar(
            currentIndex: 2, // 0 for Dashboard (HomeScreen)
            onTap: (index) {
              switch (index) {
                case 0:
                  Navigator.pushReplacementNamed(context, '/home');
                  break;
                case 1:
                // Navigate to Work Log (if you have a screen, otherwise show a placeholder)
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Scaffold(
                        appBar: AppBar(title: const Text("Work Log")),
                        body: const Center(child: Text("Work Log Screen")),
                      ),
                    ),
                  );
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
      },
    );
  }

}


