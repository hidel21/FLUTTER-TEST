import 'dart:async';
import 'package:flutter/material.dart';
import '../core/perf_monitor.dart';
import '../core/metrics_log.dart';

class ButtonsTestScreen extends StatefulWidget {
  const ButtonsTestScreen({super.key});

  @override
  State<ButtonsTestScreen> createState() => _ButtonsTestScreenState();
}

class _ButtonsTestScreenState extends State<ButtonsTestScreen> {
  int taps = 0;
  bool debounce = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    PerfMonitor.instance.endNavigation('Buttons', phase: 'push');
  }

  void _onTap() {
    if (!debounce) {
      setState(() => taps++);
      return;
    }
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 150), () {
      if (!mounted) return;
      setState(() => taps++);
    });
  }

  void _burst50() async {
    MetricsLog.instance.log('BTN', 'Burst 50 taps (debounce=${debounce ? 'ON' : 'OFF'})');
    for (int i = 0; i < 50; i++) {
      _onTap();
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pm = PerfMonitor.instance;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buttons Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Switch(
                  value: debounce,
                  onChanged: (v) => setState(() => debounce = v),
                ),
                const Text('Debounce (150ms)'),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton(
                  onPressed: _onTap,
                  child: const Text('Tap me'),
                ),
                ElevatedButton(
                  onPressed: _burst50,
                  child: const Text('Auto burst x50'),
                ),
                ElevatedButton(
                  onPressed: () => setState(() => taps = 0),
                  child: const Text('Reset counter'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Taps: $taps'),
            const SizedBox(height: 16),
            const Divider(),
            Text('Frames >16ms: ${pm.framesOver16ms}'),
            Text('Frames >32ms: ${pm.framesOver32ms}'),
            Text('avgTotal: ${pm.avgTotalMs.toStringAsFixed(2)} ms'),
          ],
        ),
      ),
    );
  }
}
