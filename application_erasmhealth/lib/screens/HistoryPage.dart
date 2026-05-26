import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:application_erasmhealth/states/app_state.dart'; 
import 'package:application_erasmhealth/utils/impact.dart';
import 'package:application_erasmhealth/services/history_service.dart';
import 'package:application_erasmhealth/services/health_score.dart';// Adjust path
// --- PLACEHOLDER: Import your actual service file here ---
// import 'package:your_app/services/score_service.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("History"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Yesterday"),
              Tab(text: "Last Week"),
              Tab(text: "Last Month"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            HistorySubPage(period: "Yesterday"),
            HistorySubPage(period: "Last Week"),
            HistorySubPage(period: "Last Month"),
          ],
        ),
      ),
    );
  }
}


class HistorySubPage extends StatefulWidget {
  final String period;
  const HistorySubPage({super.key, required this.period});

  @override
  State<HistorySubPage> createState() => _HistorySubPageState();
}

class _HistorySubPageState extends State<HistorySubPage> {
  // Local state for historical data
  bool isLoading = true;
  double score = 0.0;
  Map<String, dynamic> data = {};

  @override
  void initState() {
    super.initState();
    _loadHistoricalData();
  }

  // Calculate the target date based on the tab period
  DateTime _getTargetDate() {
    final now = DateTime.now();
    if (widget.period == "Yesterday") return now.subtract(const Duration(days: 1));
    if (widget.period == "Last Week") return now.subtract(const Duration(days: 7));
    return now.subtract(const Duration(days: 30)); // Last Month
  }

  Future<void> _loadHistoricalData() async {
    final historyService = HistoryService(Impact());
    Map<String, dynamic> fetchedData;

    if (widget.period == "Yesterday") {
      fetchedData = await historyService.fetchHistoryData(DateTime.now().subtract(const Duration(days: 1)));
    } else {
    // "Last Week" (7) or "Last Month" (30)
      int days = (widget.period == "Last Week") ? 7 : 30;
      fetchedData = await historyService.fetchRangeData(days);
    }
    // Compute score locally
    final computedScore = HealthScoreService.compute(
      sleep: fetchedData["sleep"],
      currentHR: fetchedData["heart"],
      restingHR: fetchedData["resting"],
      steps: fetchedData["steps"],
    );

    if (mounted) {
      setState(() {
        data = fetchedData;
        score = computedScore;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Text("History", style: Theme.of(context).textTheme.headlineMedium),
        Text("Period: ${widget.period}", style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 30),
        
        // Circular Score
        Center(
          child: Column(
            children: [
              Text("${widget.period}'s score"),
              const SizedBox(height: 10),
              SizedBox(
                width: 120, height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(value: score / 100, strokeWidth: 8),
                    Text("${score.toInt()}%", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 50),
        
        // Metrics based on the local 'data' map
        _buildScoreItem(Icons.bed, "Sleep", (data["sleep"] ?? 0) / 8),
        _buildScoreItem(Icons.directions_run, "Steps", (data["steps"] ?? 0) / 10000),
        _buildScoreItem(Icons.favorite, "Heart Rate", (data["heart"] ?? 70) / 150),
        _buildScoreItem(Icons.monitor_heart, "Resting HR", (data["resting"] ?? 70) / 100),
      ],
    );
  }

  Widget _buildScoreItem(IconData icon, String label, double progress) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          SizedBox(width: 50, child: Icon(icon)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label),
                const SizedBox(height: 4),
                LinearProgressIndicator(value: progress.clamp(0.0, 1.0), minHeight: 8),
              ],
            ),
          ),
          const SizedBox(width: 15),
          Text("${(progress * 100).toInt()}%"),
        ],
      ),
    );
  }
}