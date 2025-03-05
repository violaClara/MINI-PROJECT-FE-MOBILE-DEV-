import 'package:flutter/material.dart';
import '../screens/home_screen.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({Key? key, required this.currentIndex, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.onPrimary,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Dashboard
          GestureDetector(
            onTap: () => onTap(0),
            child: NavBarItem(
              icon: Icons.dashboard,
              label: "Dashboard",
              iconColor: currentIndex == 0 ? colorScheme.primary : Colors.grey,
            ),
          ),
          // Work Log
          GestureDetector(
            onTap: () => onTap(1),
            child: NavBarItem(
              assetName: 'assets/icons/worklog.png',
              label: "Work Log",
              iconColor: currentIndex == 1 ? colorScheme.primary : Colors.grey,
            ),
          ),
          // Analytic
          GestureDetector(
            onTap: () => onTap(2),
            child: NavBarItem(
              assetName: 'assets/icons/analytic.png',
              label: "Analytic",
              iconColor: currentIndex == 2 ? colorScheme.primary : Colors.grey,
            ),
          ),
          // Profile
          GestureDetector(
            onTap: () => onTap(3),
            child: NavBarItem(
              icon: Icons.more_horiz,
              label: "Profile",
              iconColor: currentIndex == 3 ? colorScheme.primary : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class NavBarItem extends StatelessWidget {
  final String? assetName; // optional image asset
  final IconData? icon; // optional icon
  final String label;
  final Color iconColor;

  const NavBarItem({
    Key? key,
    this.assetName,
    this.icon,
    required this.label,
    required this.iconColor,
  })  : assert(assetName != null || icon != null,
  'Either assetName or icon must be provided'),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget iconWidget;
    if (assetName != null) {
      iconWidget = Image.asset(
        assetName!,
        width: 20,
        height: 20,
        // Uncomment the following line to apply a color filter:
        // color: iconColor,
      );
    } else {
      iconWidget = Icon(
        icon,
        color: iconColor,
        size: 20,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        iconWidget,
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: iconColor),
        ),
      ],
    );
  }
}
