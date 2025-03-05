import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import 'home_screen.dart';
import 'package:flutter/gestures.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController(text: "");
  final TextEditingController passwordController = TextEditingController(text: "");
  bool isLoginMode = true; // Current mode (Login/Sign Up)


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final authController = Provider.of<AuthController>(context, listen: false);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;


    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 32.0, right: 32.0, top: 80.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Work Focus",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Track your activity work",
                style: TextStyle(
                  fontSize: 16,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  // Login button (toggle)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isLoginMode
                          ? (isDarkMode ? Colors.white : colorScheme.primary)
                          : (isDarkMode ? Colors.grey[900] : colorScheme.secondary),
                      foregroundColor: isLoginMode
                          ? (isDarkMode ? Colors.black : colorScheme.onPrimary)
                          : (isDarkMode ? Colors.white : colorScheme.onSecondary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      elevation: 0,
                    ),
                    onPressed: () {
                      setState(() {
                        isLoginMode = true;
                      });
                    },
                    child: const Text("Login"),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: !isLoginMode
                          ? colorScheme.primary
                          : (isDarkMode ? Colors.grey[900] : colorScheme.secondary),
                      foregroundColor: !isLoginMode
                          ?  colorScheme.onPrimary
                          : (isDarkMode ? Colors.white : colorScheme.onSecondary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      elevation: 0,
                    ),
                    onPressed: () {
                      setState(() {
                        isLoginMode = false;
                      });
                    },
                    child: const Text("Sign Up"),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                isLoginMode ? "Login" : "Sign Up",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: "Email",
                  filled: true,
                  fillColor: theme.scaffoldBackgroundColor,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: colorScheme.onSurface),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: colorScheme.onSurface),
                  ),
                ),
                style: TextStyle(color: textColor),
              ),
              const SizedBox(height: 16),
              Text(
                "Password",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Password",
                  filled: true,
                  fillColor: theme.scaffoldBackgroundColor,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: colorScheme.onSurface),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: colorScheme.onSurface),
                  ),
                ),
                style: TextStyle(color: textColor),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    "Forgot Password?",
                    style: TextStyle(
                      color: colorScheme.onBackground.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              // This is the bottom action button.
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () async {
                    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please fill in all fields.")),
                      );
                      return;
                    }
                    if (isLoginMode) {
                      String? error = await authController.login(
                        emailController.text,
                        passwordController.text,
                      );
                      if (error != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(error)),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                        );
                      }
                    } else {
                      String? error = await authController.signUp(
                        emailController.text,
                        passwordController.text,
                      );
                      if (error != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(error)),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Account created. Please login.")),
                        );
                        setState(() {
                          isLoginMode = true;
                        });
                      }
                    }
                  },
                  child: Text(
                    isLoginMode ? "Login" : "Sign Up",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: RichText(
                  text: TextSpan(
                    text: isLoginMode
                        ? "Don't have an account? "
                        : "Already have an account? ",
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 14,
                    ),
                    children: [
                      TextSpan(
                        text: isLoginMode ? "Sign Up" : "Login",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            setState(() {
                              isLoginMode = !isLoginMode;
                            });
                          },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
