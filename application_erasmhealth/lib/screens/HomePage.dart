import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:application_erasmhealth/providers/app_state.dart';
import 'package:application_erasmhealth/screens/HistoryPage.dart';
import 'package:application_erasmhealth/screens/RecoveryPage.dart';
import 'package:application_erasmhealth/screens/SimulationPage.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  /// Get color based on score
  Color getColor(double score) {
    if (score <= 50) {
      return Colors.red;
    } else if (score <= 75) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  /// Get message based on score
  String getMessage(double score) {
    if (score <= 50) {
      return "⚠️ Your body needs recovery. Take it easy today. It's okay not to go to every party!";
    } else if (score <= 75) {
      return "🙂 You're doing okay. Stay hydrated, rest well and don't drink too much tonight";
    } else {
      return "💪 You're in great shape! Keep going!";
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final score = appState.score;

    final color = getColor(score);
    final message = getMessage(score);

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              child: Text("Menu", style: TextStyle(fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Home"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text("History"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HistoryScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.show_chart),
              title: const Text("Simulation"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (_) => const SimulationPage(),),
                 );
              },
            ),
            ListTile(
              leading: const Icon(Icons.healing),
              title: const Text("Recovery"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RecoveryPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () {
                appState.logout();
              },
            ),
          ],
        ),
      ),

      appBar: AppBar(title: const Text("Home"), backgroundColor: color),

      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: color, // FULL SCREEN COLOR
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// SCORE
            Text(
              "${score.toInt()}/100",
              style: const TextStyle(
                fontSize: 80,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 20),

            /// MESSAGE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
