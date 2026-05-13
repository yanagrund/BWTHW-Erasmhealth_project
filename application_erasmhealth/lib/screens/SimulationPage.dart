import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:application_erasmhealth/providers/app_state.dart';
import 'package:application_erasmhealth/screens/RecoveryPage.dart';

class SimulationPage extends StatefulWidget {
  const SimulationPage({super.key});

  @override
  State<SimulationPage> createState() => _SimulationPageState();
}

class _SimulationPageState extends State<SimulationPage> {
  double simulatedScore = 0;
  double initialScore = 0;

  int alcoholDrinks = 0;
  int waterGlasses = 0;
  int sleepHours = 0;
  int activitySessions = 0;

  String funnyMessage =
      "🧪 Simulation mode activated. Let's see what happens to your body.";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final appState = Provider.of<AppState>(context);

    if (initialScore == 0) {
      initialScore = appState.score;
      simulatedScore = appState.score;
    }
  }

  Color getColor(double score) {
    if (score <= 50) {
      return Colors.red;
    } else if (score <= 75) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  /// ALCOHOL
  void addAlcohol() {
    setState(() {
      alcoholDrinks++;

      double penalty = 0;

      if (alcoholDrinks <= 2) {
        penalty = 5;
      } else if (alcoholDrinks <= 4) {
        penalty = 8;
      } else {
        penalty = 12;
      }

      penalty -= waterGlasses * 0.5;

      simulatedScore -= penalty;

      if (simulatedScore < 0) {
        simulatedScore = 0;
      }

      if (alcoholDrinks == 1) {
        funnyMessage = "🍺 One drink. Still socially acceptable.";
      } else if (alcoholDrinks == 3) {
        funnyMessage =
            "🥴 You're starting to make suspicious decisions.";
      } else if (alcoholDrinks == 5) {
        funnyMessage =
            "💀 Tomorrow morning is going to be a difficult experience.";
      } else if (alcoholDrinks >= 7) {
        funnyMessage =
            "🚨 Bro thinks this is a university movie montage.";
      }
    });
  }

  /// WATER
  void addWater() {
    setState(() {
      waterGlasses++;

      double bonus = alcoholDrinks >= 3 ? 4 : 2;

      simulatedScore += bonus;

      if (simulatedScore > 100) {
        simulatedScore = 100;
      }

      if (waterGlasses == 1) {
        funnyMessage = "💧 Hydration restored.";
      } else if (waterGlasses == 3) {
        funnyMessage =
            "🚰 Your kidneys are extremely proud of you.";
      } else if (waterGlasses >= 5) {
        funnyMessage =
            "🚽 You now spend more time in the bathroom than outside.";
      }
    });
  }

  /// SLEEP
  void addSleep() {
    setState(() {
      sleepHours++;

      double bonus = simulatedScore < 50 ? 9 : 6;

      simulatedScore += bonus;

      if (simulatedScore > 100) {
        simulatedScore = 100;
      }

      if (sleepHours == 1) {
        funnyMessage =
            "😴 Your body appreciates the recovery.";
      } else if (sleepHours == 3) {
        funnyMessage =
            "🛌 Sleep is carrying your entire lifestyle right now.";
      } else if (sleepHours >= 6) {
        funnyMessage =
            "📱 Your phone almost filed a missing person report.";
      }
    });
  }

  /// SPORT
  void addActivity() {
    setState(() {
      activitySessions++;

      double bonus = activitySessions >= 5 ? -3 : 5;

      simulatedScore += bonus;

      if (simulatedScore > 100) {
        simulatedScore = 100;
      }

      if (simulatedScore < 0) {
        simulatedScore = 0;
      }

      if (activitySessions == 1) {
        funnyMessage = "🏃 Healthy behavior detected.";
      } else if (activitySessions == 3) {
        funnyMessage = "🔥 Athlete arc unlocked.";
      } else if (activitySessions >= 5) {
        funnyMessage =
            "🦵 STOP PLEASE. I HAVE A CRAMP.";
      }
    });
  }

  /// RESET
  void resetSimulation() {
    setState(() {
      simulatedScore = initialScore;

      alcoholDrinks = 0;
      waterGlasses = 0;
      sleepHours = 0;
      activitySessions = 0;

      funnyMessage =
          "🔄 Simulation reset. Your original health state has been restored.";
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    final color = getColor(simulatedScore);

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              child: Text(
                "Menu",
                style: TextStyle(fontSize: 24),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Home"),
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
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
              onTap: () => Navigator.pop(context),
            ),

            ListTile(
              leading: const Icon(Icons.healing),
              title: const Text("Recovery"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RecoveryPage(),
                  ),
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

      appBar: AppBar(
        title: const Text("Simulation"),
        backgroundColor: color,
      ),

      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: color,

        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),

              child: Column(
                children: [

                  /// GLASS
                  Container(
                    width: 170,
                    height: 230,

                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),

                      borderRadius: BorderRadius.circular(35),

                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 4,
                      ),
                    ),

                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [

                        /// LIQUID
                        AnimatedContainer(
                          duration:
                              const Duration(milliseconds: 700),

                          curve: Curves.easeInOut,

                          width: double.infinity,

                          height:
                              (simulatedScore / 100) * 220,

                          decoration: BoxDecoration(
                            color:
                                Colors.white.withOpacity(0.85),

                            borderRadius: BorderRadius.only(
                              bottomLeft:
                                  const Radius.circular(30),

                              bottomRight:
                                  const Radius.circular(30),

                              topLeft: Radius.circular(
                                simulatedScore > 10 ? 22 : 0,
                              ),

                              topRight: Radius.circular(
                                simulatedScore > 10 ? 22 : 0,
                              ),
                            ),
                          ),
                        ),

                        /// ICE CUBES
                        Positioned(
                          left: 30,
                          bottom:
                              (simulatedScore / 100) * 120,

                          child: AnimatedOpacity(
                            opacity:
                                simulatedScore > 30 ? 1 : 0,

                            duration:
                                const Duration(milliseconds: 400),

                            child: Transform.rotate(
                              angle: 0.3,
                              child: Container(
                                width: 18,
                                height: 18,

                                decoration: BoxDecoration(
                                  color: Colors.white
                                      .withOpacity(0.7),

                                  borderRadius:
                                      BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ),

                        Positioned(
                          right: 35,
                          bottom:
                              (simulatedScore / 100) * 80,

                          child: AnimatedOpacity(
                            opacity:
                                simulatedScore > 55 ? 1 : 0,

                            duration:
                                const Duration(milliseconds: 400),

                            child: Transform.rotate(
                              angle: -0.4,
                              child: Container(
                                width: 16,
                                height: 16,

                                decoration: BoxDecoration(
                                  color: Colors.white
                                      .withOpacity(0.65),

                                  borderRadius:
                                      BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ),

                        /// BUBBLES
                        Positioned(
                          left: 55,
                          bottom:
                              (simulatedScore / 100) * 170,

                          child: AnimatedOpacity(
                            opacity:
                                simulatedScore > 70 ? 1 : 0,

                            duration:
                                const Duration(milliseconds: 500),

                            child: Container(
                              width: 10,
                              height: 10,

                              decoration: BoxDecoration(
                                color: Colors.white
                                    .withOpacity(0.5),

                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),

                        /// SCORE
                        Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,

                          children: [
                            Text(
                              "${simulatedScore.toInt()}",

                              style: TextStyle(
                                fontSize: 52,
                                fontWeight: FontWeight.bold,

                                color: simulatedScore > 45
                                    ? color
                                    : Colors.white,
                              ),
                            ),

                            Text(
                              "HEALTH",

                              style: TextStyle(
                                fontSize: 14,
                                letterSpacing: 2,
                                fontWeight: FontWeight.bold,

                                color: simulatedScore > 45
                                    ? color.withOpacity(0.8)
                                    : Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  /// WARNING
                  Container(
                    padding: const EdgeInsets.all(14),

                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(18),
                    ),

                    child: const Text(
                      "⚠️ Simulation only. This is not medical advice and results are only approximations.",

                      textAlign: TextAlign.center,

                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  /// BUTTONS
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,

                    children: [
                      ElevatedButton.icon(
                        onPressed: addAlcohol,
                        icon: const Icon(Icons.local_bar),
                        label: const Text("+1 Alcohol"),
                      ),

                      ElevatedButton.icon(
                        onPressed: addWater,
                        icon: const Icon(Icons.water_drop),
                        label: const Text("+1 Water"),
                      ),

                      ElevatedButton.icon(
                        onPressed: addSleep,
                        icon: const Icon(Icons.bed),
                        label: const Text("+1h Sleep"),
                      ),

                      ElevatedButton.icon(
                        onPressed: addActivity,
                        icon: const Icon(Icons.fitness_center),
                        label: const Text("+30min Sport"),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  /// MESSAGE
                  Container(
                    width: double.infinity,

                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 22,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: Text(
                      funnyMessage,

                      textAlign: TextAlign.center,

                      style: const TextStyle(
                        fontSize: 17,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        height: 1.4,
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  /// RESET
                  ElevatedButton.icon(
                    onPressed: resetSimulation,

                    icon: const Icon(Icons.refresh),

                    label: const Text("Reset Simulation"),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: color,

                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 14,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}