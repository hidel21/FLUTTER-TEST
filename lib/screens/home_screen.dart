import 'dart:async';
import 'package:flutter/material.dart';
import '../core/perf_monitor.dart';
import '../core/metrics_log.dart';
import 'buttons_test.dart';
import 'lists_test.dart';
import 'inputs_test.dart';
import 'animations_test.dart';
import 'navigation_test.dart';
import 'stress_test.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.showOverlay, required this.onToggleOverlay});

  final bool showOverlay;
  final VoidCallback onToggleOverlay;

  @override
  Widget build(BuildContext context) {
    final tiles = <_TestTile>[
      _TestTile('Buttons', const ButtonsTestScreen()),
      _TestTile('Lists', const ListsTestScreen()),
      _TestTile('Inputs', const InputsTestScreen()),
      _TestTile('Animations', const AnimationsTestScreen()),
      _TestTile('Navigation', const NavigationTestScreen()),
      _TestTile('Stress Test', const StressTestScreen()),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter UI Bench'),
        actions: [
          IconButton(
            tooltip: showOverlay ? 'Ocultar Performance Overlay' : 'Mostrar Performance Overlay',
            onPressed: onToggleOverlay,
            icon: Icon(showOverlay ? Icons.visibility_off : Icons.visibility),
          ),
          IconButton(
            tooltip: 'Ver logs',
            onPressed: () => _showLogs(context),
            icon: const Icon(Icons.list_alt),
          ),
          IconButton(
            tooltip: 'Reset contadores',
            onPressed: () => PerfMonitor.instance.resetCounters(),
            icon: const Icon(Icons.restart_alt),
          ),
        ],
      ),
      body: Column(
        children: [
          _PerfSummaryBar(),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              itemCount: tiles.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final t = tiles[index];
                return ListTile(
                  title: Text(t.title),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    PerfMonitor.instance.startNavigation(t.title, phase: 'push');
                    await Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => t.screen),
                    );
                    await PerfMonitor.instance.measurePop();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showLogs(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logs de métricas'),
          content: SizedBox(
            width: 600,
            height: 400,
            child: ValueListenableBuilder<int>(
              valueListenable: MetricsLog.instance.changeTick,
              builder: (_, __, ___) {
                final logs = MetricsLog.instance.logs.reversed.toList();
                return ListView.builder(
                  itemCount: logs.length,
                  itemBuilder: (_, i) => Text(logs[i], style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => MetricsLog.instance.clear(),
              child: const Text('Limpiar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }
}

class _TestTile {
  final String title;
  final Widget screen;
  _TestTile(this.title, this.screen);
}

class _PerfSummaryBar extends StatefulWidget {
  @override
  State<_PerfSummaryBar> createState() => _PerfSummaryBarState();
}

class _PerfSummaryBarState extends State<_PerfSummaryBar> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Actualizamos números 2 veces por segundo (menos carga en emuladores)
    _timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pm = PerfMonitor.instance;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          _chip('Frames', pm.totalFrames.toString()),
          const SizedBox(width: 8),
          _chip('>16ms', pm.framesOver16ms.toString()),
          const SizedBox(width: 8),
          _chip('>32ms', pm.framesOver32ms.toString()),
          const SizedBox(width: 8),
          _chip('avgTotal', '${pm.avgTotalMs.toStringAsFixed(2)} ms'),
          const SizedBox(width: 8),
          _chip('build', '${pm.avgBuildMs.toStringAsFixed(2)}'),
          const SizedBox(width: 8),
          _chip('raster', '${pm.avgRasterMs.toStringAsFixed(2)}'),
        ],
      ),
    );
  }

  Widget _chip(String label, String value) {
    return Chip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 6),
          Text(value),
        ],
      ),
    );
  }
}
