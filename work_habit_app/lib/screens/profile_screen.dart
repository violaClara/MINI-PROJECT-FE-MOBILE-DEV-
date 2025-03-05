import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../controllers/auth_controller.dart';
import '../widgets/bottom_navbar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final user = authController.currentUser;
    final String username = user?.username ?? 'Unknown';
    final String memberSince = user != null ? _formatDate(user.memberSince) : '-';
    // For demonstration, using current date

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.grey[100],
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: colorScheme.onPrimary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Image.network(
                          'https://storage.googleapis.com/a1aa/image/J8UN5KBmIrX07kDhIxr16e-HYljswxT4mfo-vf7a-GQ.jpg',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            username,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Member Since $memberSince',
                            style: TextStyle(
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Card for General Section
            Center(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: colorScheme.onPrimary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      color: (isDarkMode ? Colors.black : Colors.grey[100]),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'General',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            decoration: BoxDecoration(
                              color: colorScheme.onPrimary,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                _buildListItem(
                                  context: context,
                                  icon: FontAwesomeIcons.user,
                                  text: 'Profile',
                                  showBorder: true,
                                  onTap: () {
                                    _showUpdateProfileDialog(context, authController);
                                  },
                                ),
                                _buildListItem(
                                  context: context,
                                  icon: FontAwesomeIcons.database,
                                  text: 'Data & Privacy',
                                  showBorder: true,
                                ),
                                _buildListItem(
                                  context: context,
                                  icon: FontAwesomeIcons.creditCard,
                                  text: 'Subscription',
                                  showBorder: true,
                                ),
                                _buildListItem(
                                  context: context,
                                  icon: FontAwesomeIcons.lock,
                                  text: 'Password',
                                  showBorder: true,
                                  onTap: () {
                                    _showUpdatePasswordDialog(context, authController);
                                  },
                                ),
                                _buildListItem(
                                  context: context,
                                  icon: FontAwesomeIcons.signOutAlt,
                                  text: 'Sign Out',
                                  showBorder: false,
                                  onTap: () {
                                    Provider.of<AuthController>(context, listen: false)
                                        .signOut();
                                    Navigator.pushReplacementNamed(context, '/');
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 3, // 0 for Dashboard (HomeScreen)
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
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

  Widget _buildListItem({
    required BuildContext context,
    required IconData icon,
    required String text,
    required bool showBorder,
    VoidCallback? onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: showBorder
              ? const Border(
            bottom: BorderSide(color: Color(0xFFe5e7eb)),
          )
              : null,
        ),
        child: Row(
          children: [
            FaIcon(icon, color: colorScheme.primary, size: 20),
            const SizedBox(width: 16),
            Text(
              text,
              style: TextStyle(
                fontSize: 18,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateProfileDialog(BuildContext context, AuthController authController) {
    final TextEditingController emailController = TextEditingController(text: authController.currentUser?.email ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Profile'),
          content: TextField(
            controller: emailController,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                String newEmail = emailController.text.trim();
                String? result = await authController.updateEmail(newEmail);
                if (result == null) {
                  // Update sukses
                  Navigator.pop(context);
                } else {
                  // Tampilkan pesan error (misal: pakai snackbar)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result)),
                  );
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _showUpdatePasswordDialog(BuildContext context, AuthController authController) {
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ganti Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password Baru'),
              ),
              TextField(
                controller: confirmController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Konfirmasi Password'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                String newPassword = passwordController.text.trim();
                String confirmPassword = confirmController.text.trim();
                if (newPassword != confirmPassword) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password tidak cocok!')),
                  );
                  return;
                }
                String? result = await authController.updatePassword(newPassword);
                if (result == null) {
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result)),
                  );
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }


  String _formatDate(DateTime date) {
    return "${date.day} ${_monthName(date.month)} ${date.year}";
  }

  String _monthName(int month) {
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
}


