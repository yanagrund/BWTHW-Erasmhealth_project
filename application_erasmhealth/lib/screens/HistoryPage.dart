import 'package:application_erasmhealth/screens/homePage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:application_erasmhealth/providers/app_state.dart';
import 'package:application_erasmhealth/screens/RecoveryPage.dart';
import 'package:application_erasmhealth/screens/SimulationPage.dart';
import 'package:application_erasmhealth/services/History_service.dart';
import 'package:application_erasmhealth/services/health_score.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  HistoryService? _historyService;
  final List<double> _scores = [0.0, 0.0, 0.0];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Create once, reuse the authenticated Impact instance from AppState.
    _historyService ??= HistoryService(
      Provider.of<AppState>(context, listen: false).impactService,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _updateScore(int tabIndex, double score) {
    if (mounted) setState(() => _scores[tabIndex] = score);
  }

  Color _getColor(double score) {
    if (score <= 50) return Colors.red;
    if (score <= 75) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final color = _getColor(_scores[_tabController.index]);

    return Scaffold(
      backgroundColor: color,
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
              onTap: () => Navigator.pop(context),
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
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RecoveryPage()),
                );
              },
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
        title: const Text('History'),
        backgroundColor: color,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Yesterday'),
            Tab(text: 'Last Week'),
            Tab(text: 'Last Month'),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          HistorySubPage(
            tabIndex: 0,
            period: 'Yesterday',
            tabController: _tabController,
            historyService: _historyService!,
            onScoreLoaded: (s) => _updateScore(0, s),
          ),
          HistorySubPage(
            tabIndex: 1,
            period: 'Last Week',
            tabController: _tabController,
            historyService: _historyService!,
            onScoreLoaded: (s) => _updateScore(1, s),
          ),
          HistorySubPage(
            tabIndex: 2,
            period: 'Last Month',
            tabController: _tabController,
            historyService: _historyService!,
            onScoreLoaded: (s) => _updateScore(2, s),
          ),
        ],
      ),
    );
  }
}

class HistorySubPage extends StatefulWidget {
  final int tabIndex;
  final String period;
  final TabController tabController;
  final HistoryService historyService;
  final void Function(double) onScoreLoaded;

  const HistorySubPage({
    super.key,
    required this.tabIndex,
    required this.period,
    required this.tabController,
    required this.historyService,
    required this.onScoreLoaded,
  });

  @override
  State<HistorySubPage> createState() => _HistorySubPageState();
}

class _HistorySubPageState extends State<HistorySubPage>
    with AutomaticKeepAliveClientMixin {
  bool _loadStarted = false;
  bool isLoading = false;
  double score = 0.0;
  Map<String, dynamic> data = {};

  // Keep loaded tabs alive so switching back does not re-fetch.
  @override
  bool get wantKeepAlive => _loadStarted;

  @override
  void initState() {
    super.initState();
    widget.tabController.addListener(_onTabChanged);
    // If this tab is already visible, start loading immediately.
    // Set fields directly — setState must not be called during initState.
    if (widget.tabController.index == widget.tabIndex) {
      _loadStarted = true;
      isLoading = true;
      _loadHistoricalData();
    }
  }

  @override
  void dispose() {
    widget.tabController.removeListener(_onTabChanged);
    super.dispose();
  }

  void _onTabChanged() {
    // Only triggered after the widget is fully mounted, so setState is safe.
    if (widget.tabController.index == widget.tabIndex && !_loadStarted) {
      setState(() {
        _loadStarted = true;
        isLoading = true;
      });
      _loadHistoricalData();
    }
  }

  Future<void> _loadHistoricalData() async {
    Map<String, dynamic> fetchedData;
    if (widget.period == 'Yesterday') {
      // Day -1 is "today" (most recent IMPACT data). Yesterday is day -2.
      fetchedData = await widget.historyService.fetchHistoryData(
        DateTime.now().subtract(const Duration(days: 2)),
      );
    } else {
      final days = (widget.period == 'Last Week') ? 7 : 30;
      fetchedData = await widget.historyService.fetchRangeData(days);
    }

    final computedScore = HealthScoreService.compute(
      sleep: (fetchedData['sleep'] as num).toDouble(),
      currentHR: (fetchedData['heart'] as num).toDouble(),
      restingHR: (fetchedData['resting'] as num).toDouble(),
      steps: fetchedData['steps'] as int,
    );

    if (mounted) {
      setState(() {
        data = fetchedData;
        score = computedScore;
        isLoading = false;
      });
      widget.onScoreLoaded(computedScore);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // required by AutomaticKeepAliveClientMixin

    final color = score <= 50
        ? Colors.red
        : score <= 75
            ? Colors.orange
            : Colors.green;

    if (!_loadStarted || isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    final sleep = (data['sleep'] as num).toDouble();
    final steps = data['steps'] as int;
    final heart = (data['heart'] as num).toDouble();
    final resting = (data['resting'] as num).toDouble();

    return Container(
      color: color,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                Text(
                  '${score.toInt()}',
                  style: const TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${widget.period} score',
                  style: const TextStyle(fontSize: 20, color: Colors.white70),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: LinearProgressIndicator(
                      value: score / 100,
                      minHeight: 18,
                      backgroundColor: Colors.white30,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                _buildMetricCard(
                  Icons.bed,
                  'Sleep',
                  '${sleep.toStringAsFixed(1)} hrs',
                  sleep / 8,
                ),
                const SizedBox(height: 12),
                _buildMetricCard(
                  Icons.directions_run,
                  'Steps',
                  '$steps steps',
                  steps / 10000,
                ),
                const SizedBox(height: 12),
                _buildMetricCard(
                  Icons.favorite,
                  'Heart Rate',
                  '${heart.toInt()} bpm',
                  heart / 150,
                ),
                const SizedBox(height: 12),
                _buildMetricCard(
                  Icons.monitor_heart,
                  'Resting HR',
                  '${resting.toInt()} bpm',
                  resting / 100,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    IconData icon,
    String label,
    String valueText,
    double progress,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      valueText,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    minHeight: 8,
                    backgroundColor: Colors.white30,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
