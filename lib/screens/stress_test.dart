import 'dart:async';
import 'package:flutter/material.dart';
import '../core/perf_monitor.dart';
import '../core/metrics_log.dart';
import '../utils/mock_data.dart';

class StressTestScreen extends StatefulWidget {
  const StressTestScreen({super.key});

  @override
  State<StressTestScreen> createState() => _StressTestScreenState();
}

class _StressTestScreenState extends State<StressTestScreen> with SingleTickerProviderStateMixin {
  final ScrollController _scroll = ScrollController();
  late AnimationController _controller;
  late Animation<double> _anim;
  bool _running = false;
  int _seconds = 30;
  late List<String> _items;
  Timer? _timer;
  int _remaining = 0;

  @override
  void initState() {
    super.initState();
    PerfMonitor.instance.endNavigation('Stress Test', phase: 'push');
    _items = MockData.generateItems(5000, prefix: 'Stress');
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _anim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    if (_running) return;
    PerfMonitor.instance.resetCounters();
    MetricsLog.instance.log('STRESS', 'start ${_seconds}s');
    setState(() {
      _running = true;
      _remaining = _seconds;
    });
    _controller.repeat(reverse: true);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _remaining--);
      if (_remaining <= 0) {
        t.cancel();
        _stop();
      }
    });

    // Scroll alternante up/down
    double dir = 1;
    while (mounted && _running) {
      final target = (_scroll.position.maxScrollExtent) * (dir > 0 ? 1.0 : 0.0);
      try {
        await _scroll.animateTo(
          target,
          duration: const Duration(milliseconds: 1800),
          curve: Curves.linear,
        );
      } catch (_) {}
      dir *= -1;
    }
  }

  void _stop() {
    if (!_running) return;
    _running = false;
    _controller.stop();
    _timer?.cancel();
    setState(() {});
    MetricsLog.instance.log('STRESS', 'end avgTotal=${PerfMonitor.instance.avgTotalMs.toStringAsFixed(2)}ms');
  }

  @override
  Widget build(BuildContext context) {
    final pm = PerfMonitor.instance;
    return Scaffold(
      appBar: AppBar(title: const Text('Stress Test')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Text('Duración:'),
                const SizedBox(width: 8),
                DropdownButton<int>(
                  value: _seconds,
                  items: const [15, 30, 45, 60].map((e) => DropdownMenuItem(value: e, child: Text('$e s'))).toList(),
                  onChanged: _running ? null : (v) { if (v != null) setState(() => _seconds = v); },
                ),
                const SizedBox(width: 16),
                ElevatedButton(onPressed: _running ? null : _start, child: const Text('Start')),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _running ? _stop : null, child: const Text('Stop')),
                const Spacer(),
                Text('Rem: ${_running ? _remaining : 0}s  avg ${pm.avgTotalMs.toStringAsFixed(2)}ms  >16 ${pm.framesOver16ms}'),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: Stack(
              children: [
                ListView.builder(
                  controller: _scroll,
                  itemCount: _items.length,
                  itemBuilder: (_, i) => ListTile(
                    leading: const Icon(Icons.bolt),
                    title: Text(_items[i]),
                    subtitle: const Text('Scroll + animación superpuesta'),
                  ),
                ),
                IgnorePointer(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: AnimatedBuilder(
                      animation: _anim,
                      builder: (_, __) {
                        final w = 60 + 40 * _anim.value;
                        final c = Color.lerp(Colors.red, Colors.green, _anim.value)!;
                        return Container(
                          margin: const EdgeInsets.only(top: 8),
                          width: w,
                          height: 12,
                          decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(6)),
                        );
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
