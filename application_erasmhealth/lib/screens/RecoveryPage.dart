import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:application_erasmhealth/providers/app_state.dart';
import 'package:application_erasmhealth/screens/HistoryPage.dart';
import 'package:application_erasmhealth/screens/SimulationPage.dart';
import 'package:application_erasmhealth/screens/HomePage.dart';

class RecoveryPage extends StatefulWidget {
  const RecoveryPage({super.key});

  @override
  State<RecoveryPage> createState() => _RecoveryPageState();
}

class _RecoveryPageState extends State<RecoveryPage> {
  late Timer _timer;

  // Assumed recovery rate used to estimate time to full health. (Could be made more precise later)
  static const double _recoveryRatePerHour = 5.0;

  @override
  void initState() {
    super.initState();
    // Rebuild every minute so the "X hours remaining" countdown stays fresh.
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Color _getColor(double score) {
    if (score <= 50) return Colors.red;
    if (score <= 75) return Colors.orange;
    return Colors.green;
  }

  String _getEmoji(double score) {
    if (score >= 100) return '🏆';
    if (score >= 75) return '💚';
    if (score >= 50) return '🟡';
    return '❤️‍🩹';
  }

  String _getMotivation(double score) {
    if (score >= 100) return '🎉 You\'re fully recovered — you\'re at your best today!';

    final double hoursLeft = (100 - score) / _recoveryRatePerHour;

    if (hoursLeft < 1) {
      final int minutesLeft = (hoursLeft * 60).round();
      return '⏰ In $minutesLeft minutes you will be at 100% — your healthiest self!';
    }
    if (hoursLeft < 2) {
      return '⏰ In about 1 hour you will be at 100% — your healthiest self!';
    }
    return '⏰ In ${hoursLeft.round()} hours you will be at 100% — your healthiest self!';
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final score = appState.score;
    final improvement = score - appState.yesterdayScore;
    final color = _getColor(score);

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              child: Text('Menu', style: TextStyle(fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HomePage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('History'),
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
              title: const Text('Simulation'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SimulationPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.healing),
              title: const Text('Recovery'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                appState.logout();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('Recovery'),
        backgroundColor: color,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: color,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_getEmoji(score), style: const TextStyle(fontSize: 64)),

            const SizedBox(height: 16),

            Text(
              '${score.toInt()}%',
              style: const TextStyle(
                fontSize: 80,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const Text(
              'Recovery',
              style: TextStyle(fontSize: 20, color: Colors.white70),
            ),

            const SizedBox(height: 28),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: LinearProgressIndicator(
                  value: score / 100,
                  minHeight: 18,
                  backgroundColor: Colors.white30,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              improvement >= 0
                  ? '📈 +${improvement.toInt()}% from yesterday'
                  : '📉 ${improvement.toInt()}% from yesterday',
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),

            const SizedBox(height: 32),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                _getMotivation(score),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
