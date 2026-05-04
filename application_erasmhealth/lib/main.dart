import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:application_erasmhealth/screens/loginPage.dart';
import 'package:application_erasmhealth/screens/homePage.dart';
import 'package:application_erasmhealth/providers/app_state.dart';
import 'package:application_erasmhealth/utils/impact.dart';


/// Entry point of the app
void main() {
  runApp( //initialize Provider at the root of the app
    ChangeNotifierProvider(
      // Inject ImpactService into AppState
      create: (_) => AppState(Impact()),
      child: const MyApp(),
    ), 
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Erasmhealth App',
      debugShowCheckedModeBanner: false,
      home: Consumer<AppState>(
        builder: (context, appState, _) {
          // Switch screen based on login state
          return appState.isLoggedIn
              ? const HomePage()
              : LoginPage();
        },
      ),
    );
  }
}