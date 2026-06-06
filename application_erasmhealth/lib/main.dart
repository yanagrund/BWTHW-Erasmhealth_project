import 'package:application_erasmhealth/screens/Cocktail_Animation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:application_erasmhealth/screens/homePage.dart';
import 'package:application_erasmhealth/providers/app_state.dart';
import 'package:application_erasmhealth/utils/impact.dart';
import 'package:application_erasmhealth/screens/Cocktail_Animation.dart';


/// Entry point of the app
/// // Initializes the Provider for state management and runs the app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appState = AppState(Impact());

  await appState.restoreLoginState();

  runApp(
    ChangeNotifierProvider(
      create: (_) => appState,
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

          if (appState.isLoggedIn) {
              return const HomePage();
          }

          return const CocktailAnimation();
          },
      ),
    );
  }
}