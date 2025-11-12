import 'package:flutter/material.dart';
import '../core/perf_monitor.dart';

class AnimationsTestScreen extends StatefulWidget {
  const AnimationsTestScreen({super.key});

  @override
  State<AnimationsTestScreen> createState() => _AnimationsTestScreenState();
}

class _AnimationsTestScreenState extends State<AnimationsTestScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim;
  int _durationMs = 300;
  bool _running = false;

  @override
  void initState() {
    super.initState();
    PerfMonitor.instance.endNavigation('Animations', phase: 'push');
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: _durationMs));
    _anim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _running = !_running;
      if (_running) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
      }
    });
  }

  void _setDuration(int ms) {
    setState(() {
      _durationMs = ms;
      _controller.duration = Duration(milliseconds: _durationMs);
    });
  }

  @override
  Widget build(BuildContext context) {
    final pm = PerfMonitor.instance;
    return Scaffold(
      appBar: AppBar(title: const Text('Animations Test')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Text('Duration:'),
                const SizedBox(width: 8),
                DropdownButton<int>(
                  value: _durationMs,
                  items: const [300, 800, 1500].map((e) => DropdownMenuItem(value: e, child: Text('${e}ms'))).toList(),
                  onChanged: (v) { if (v != null) _setDuration(v); },
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _toggle,
                  child: Text(_running ? 'Stop' : 'Start'),
                ),
                const Spacer(),
                Text('avg ${pm.avgTotalMs.toStringAsFixed(2)}ms  >16ms ${pm.framesOver16ms}'),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size = constraints.biggest;
                  return AnimatedBuilder(
                    animation: _anim,
                    builder: (_, __) {
                      final x = (size.width - 80) * _anim.value;
                      final y = (size.height - 80) * (1 - _anim.value);
                      return Stack(
                        children: [
                          Positioned(
                            left: x,
                            top: y,
                            child: Container(width: 80, height: 80, decoration: BoxDecoration(color: Colors.indigo, borderRadius: BorderRadius.circular(12))),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
