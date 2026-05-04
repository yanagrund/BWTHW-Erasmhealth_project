import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:application_erasmhealth/providers/app_state.dart';


//Process:
// user: open app, login with credentials and click on log-in
// app: sent to IMPACT, IMPACT validation, tokens, log in, homepage

/// Login UI
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;

  /// Handle login button
  Future<void> _login() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final appState = Provider.of<AppState>(context, listen: false);

    final success = await appState.login(
      usernameController.text,
      passwordController.text,
    );

    setState(() {
      isLoading = false;
    });

    if (!success) {
      setState(() {
        errorMessage = "Invalid credentials or network error";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF6A11CB), // purple
              Color(0xFFCF5CF6), // pink
              Color(0xFF2575FC), // blue
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
       ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
               padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                 color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(24),
                 border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Column(
                 mainAxisSize: MainAxisSize.min,
                  children: [
                  const Text(
                      "Welcome Back",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                       letterSpacing: 1.2,
                      ),
                   ),
                    const SizedBox(height: 8),
                    const Text(
                      "Login to continue",
                     style: TextStyle(
                       color: Colors.white70,
                       fontSize: 14,
                      ),
                   ),

                    const SizedBox(height: 30),

                    /// Username
                   TextField(
                      controller: usernameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                      hintText: "Username",
                        hintStyle: const TextStyle(color: Colors.white70),
                        prefixIcon:
                            const Icon(Icons.person, color: Colors.white),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// Password
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Password",
                        hintStyle: const TextStyle(color: Colors.white70),
                        prefixIcon:
                            const Icon(Icons.lock, color: Colors.white),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// Error
                    if (errorMessage != null)
                      Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          errorMessage!,
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      ),

                    const SizedBox(height: 10),

                    /// Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.deepPurple,
                          shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 5,
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.deepPurple,
                                ),
                              )
                            : const Text(
                               "Login",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                               ),
                              ),
                      ),
                   ),
                  ],
                ),
              ),
            ),
          ),
        ),
     ),
    );
  }
}