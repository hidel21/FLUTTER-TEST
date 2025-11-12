import 'dart:async';
import 'package:flutter/material.dart';
import '../core/perf_monitor.dart';
import '../core/metrics_log.dart';

class InputsTestScreen extends StatefulWidget {
  const InputsTestScreen({super.key});

  @override
  State<InputsTestScreen> createState() => _InputsTestScreenState();
}

class _InputsTestScreenState extends State<InputsTestScreen> {
  final TextEditingController _controller = TextEditingController();
  String _status = 'Esperando...';
  Timer? _validator;

  @override
  void initState() {
    super.initState();
    PerfMonitor.instance.endNavigation('Inputs', phase: 'push');
  }

  @override
  void dispose() {
    _validator?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    final len = value.length;
    MetricsLog.instance.log('INPUT', 'len=$len');
    _validator?.cancel();
    _validator = Timer(const Duration(milliseconds: 120), () {
      final valid = len % 7 != 0; // validación tonta para generar carga
      setState(() {
        _status = valid ? 'OK' : 'Error de validación';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final pm = PerfMonitor.instance;
    return Scaffold(
      appBar: AppBar(title: const Text('Inputs Test')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Escribe 100 chars en ~5s y observa latencia de teclado/validación'),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              onChanged: _onChanged,
              decoration: const InputDecoration(labelText: 'Input', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            Text('Estado: $_status'),
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
