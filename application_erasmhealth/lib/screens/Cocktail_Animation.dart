import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CocktailAnimation extends StatefulWidget {
  final VoidCallback onDone;
  const CocktailAnimation({super.key, required this.onDone});

  @override
  State<CocktailAnimation> createState() => _CocktailAnimationState();
}

class _CocktailAnimationState extends State<CocktailAnimation> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 5), () {
      if (mounted) widget.onDone();
    });
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