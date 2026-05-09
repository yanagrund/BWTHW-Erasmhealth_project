import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:application_erasmhealth/providers/app_state.dart';

class RecoveryPage extends StatelessWidget {
  const RecoveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

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
              onTap: () {
                Navigator.pop(context); // close drawer
                Navigator.pop(context); // go back to HomePage
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text("History"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.show_chart),
              title: const Text("Simulation"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.healing),
              title: const Text("Recovery"),
              onTap: () {
                Navigator.pop(context); // close drawer, already here
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
      appBar: AppBar(
        title: const Text("Recovery"),
      ),
      body: const Center(
        child: Text(
          "Recovery Page",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
