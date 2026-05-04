import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:application_erasmhealth/providers/app_state.dart';

/// Home screen after login
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              appState.logout();
            },
          ),
        ],
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Score: ${appState.score}",
              style: const TextStyle(fontSize: 24),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: appState.addDrink,
              child: const Text("Add Drink (-10)"),
            ),
          ],
        ),
      ),
    );
  }
}