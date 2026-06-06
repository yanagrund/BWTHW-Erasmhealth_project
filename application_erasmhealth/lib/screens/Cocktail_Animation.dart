import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'LoginPage.dart';

class CocktailAnimation extends StatefulWidget {
  const CocktailAnimation({super.key});

  @override
  State<CocktailAnimation> createState() => _CocktailAnimationState();
}

class _CocktailAnimationState extends State<CocktailAnimation> {
  @override
  void initState() {
    super.initState();

    Timer(
      const Duration(seconds: 5),
      () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginPage(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6A11CB),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Lottie.asset(
              'assets/animations/cocktail_loading.json',
              width: 250,
              repeat: true,
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}