import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import 'login_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Color getBackground(double score) {
    if (score > 70) return Colors.green.shade300;
    if (score > 40) return Colors.orange.shade300;
    return Colors.red.shade300;
  }

  String getCharacter(double score) {
    if (score > 70) return "😄";
    if (score > 40) return "😐";
    return "😵";
  }

  String getMessage(double score) {
    if (score > 70) return "You're good to go 🎉";
    if (score > 40) return "Be careful tonight ⚠️";
    return "Not your day 🚫";
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final score = state.score;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [getBackground(score), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              // Character
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white,
                child: Text(
                  getCharacter(score),
                  style: const TextStyle(fontSize: 50),
                ),
              ),

              const SizedBox(height: 20),

              // Score
              Text(
                score.toInt().toString(),
                style: const TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              // Message
              Text(
                getMessage(score),
                style: const TextStyle(fontSize: 18),
              ),

              const SizedBox(height: 30),

              // Add drink
              ElevatedButton(
                onPressed: () => state.addDrink(),
                child: const Text("Add Drink 🍹"),
              ),

              const SizedBox(height: 10),

              // Recover
              ElevatedButton(
                onPressed: () => state.recover(),
                child: const Text("Recover 😴"),
              ),

              const SizedBox(height: 20),

              // Logout
              TextButton(
                onPressed: () {
                  state.logout();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const LoginPage()),
                  );
                },
                child: const Text("Logout"),
              )
            ],
          ),
        ),
      ),
    );
  }
}