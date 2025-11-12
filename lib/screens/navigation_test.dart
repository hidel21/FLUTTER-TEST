import 'dart:async';
import 'package:flutter/material.dart';
import '../core/perf_monitor.dart';
import '../core/metrics_log.dart';

class NavigationTestScreen extends StatefulWidget {
  const NavigationTestScreen({super.key});

  @override
  State<NavigationTestScreen> createState() => _NavigationTestScreenState();
}

class _NavigationTestScreenState extends State<NavigationTestScreen> {
  bool _running = false;
  int _cycles = 20;
  final List<int> _pushLat = [];
  final List<int> _popLat = [];

  @override
  void initState() {
    super.initState();
    PerfMonitor.instance.endNavigation('Navigation', phase: 'push');
  }

  Future<void> _runCycles() async {
    if (_running) return;
    setState(() {
      _running = true;
      _pushLat.clear();
      _popLat.clear();
    });

    for (int i = 0; i < _cycles; i++) {
      final label = 'nav-cycle-$i';
      PerfMonitor.instance.startNavigation(label, phase: 'push');
      final started = DateTime.now();
  await Navigator.of(context).push(MaterialPageRoute(builder: (_) => _AutoPopPage(label: label)));
      final popElapsed = DateTime.now().difference(started).inMilliseconds;
      // measurePop() ya registra latencia de frame tras pop
      final popLat = (await PerfMonitor.instance.measurePop()).inMilliseconds;
      _popLat.add(popLat);
      MetricsLog.instance.log('NAV', 'cycle $i pop-elapsed=$popElapsed pop-lat=$popLat');
      setState(() {});
    }

    setState(() { _running = false; });
  }

  @override
  Widget build(BuildContext context) {
    double avg(List<int> xs) => xs.isEmpty ? 0 : xs.reduce((a,b)=>a+b) / xs.length;
    return Scaffold(
      appBar: AppBar(title: const Text('Navigation Test')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Text('Ciclos:'),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: _cycles,
                items: const [10,20,30,50].map((e)=>DropdownMenuItem(value:e, child: Text('$e'))).toList(),
                onChanged: _running ? null : (v){ if(v!=null) setState(()=>_cycles=v); },
              ),
              const SizedBox(width: 16),
              ElevatedButton(onPressed: _running?null:_runCycles, child: Text(_running?'Running...':'Run')),
            ]),
            const SizedBox(height: 12),
            Text('Push avg: ${avg(_pushLat).toStringAsFixed(1)} ms (${_pushLat.length} muestras)'),
            Text('Pop avg: ${avg(_popLat).toStringAsFixed(1)} ms (${_popLat.length} muestras)'),
            const SizedBox(height: 12),
            const Text('Notas:'),
            const Text('- Push se mide como tiempo hasta initState de la nueva pantalla.'),
            const Text('- Pop se mide como tiempo hasta el siguiente frame tras el pop.'),
          ],
        ),
      ),
    );
  }
}

class _AutoPopPage extends StatefulWidget {
  const _AutoPopPage({required this.label});
  final String label;

  @override
  State<_AutoPopPage> createState() => _AutoPopPageState();
}

class _AutoPopPageState extends State<_AutoPopPage> {
  @override
  void initState() {
    super.initState();
    // Finalizamos medición de push
    final d = PerfMonitor.instance.endNavigation(widget.label, phase: 'push');
    if (d != null) {
      MetricsLog.instance.log('NAV', 'push ${widget.label} ${d.inMilliseconds}ms');
    }
    // Auto pop tras breve delay para simular interacción
    Future<void>.delayed(const Duration(milliseconds: 150), () {
      if (!mounted) return;
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Auto-pop page')),
      body: const Center(child: Text('Auto-pop...')),
    );
  }
}
