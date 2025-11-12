import 'package:flutter/material.dart';
import 'core/perf_monitor.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  PerfMonitor.instance.start();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _showOverlay = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter UI Bench',
      debugShowCheckedModeBanner: false,
      showPerformanceOverlay: _showOverlay,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: HomeScreen(
        showOverlay: _showOverlay,
        onToggleOverlay: () => setState(() => _showOverlay = !_showOverlay),
      ),
    );
  }
}
