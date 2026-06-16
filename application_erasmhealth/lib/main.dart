import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:application_erasmhealth/providers/app_state.dart';
import 'package:application_erasmhealth/utils/impact.dart';
import 'package:application_erasmhealth/screens/Cocktail_Animation.dart';
import 'package:application_erasmhealth/screens/HomePage.dart';
import 'package:application_erasmhealth/screens/LoginPage.dart';

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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _splashDone = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Erasmhealth App',
      debugShowCheckedModeBanner: false,
      home: Consumer<AppState>(
        builder: (context, appState, _) {
          if (appState.isLoggedIn) return const HomePage();
          if (!_splashDone) {
            return CocktailAnimation(
              onDone: () => setState(() => _splashDone = true),
            );
          }
          return const LoginPage();
        },
      ),
    );
  }
}
