import 'dart:async';
import 'package:flutter/scheduler.dart';
import 'metrics_log.dart';

class PerfMonitor {
  PerfMonitor._();
  static final PerfMonitor instance = PerfMonitor._();

  bool _started = false;
  int framesOver16ms = 0;
  int framesOver32ms = 0;
  int totalFrames = 0;
  double avgTotalMs = 0.0;
  double avgBuildMs = 0.0;
  double avgRasterMs = 0.0;

  final Map<String, Stopwatch> _navStopwatches = {};

  void start() {
    if (_started) return;
    _started = true;
    SchedulerBinding.instance.addTimingsCallback(_onTimings);
    MetricsLog.instance.add('PerfMonitor started');
  }

  void stop() {
    if (!_started) return;
    _started = false;
    SchedulerBinding.instance.removeTimingsCallback(_onTimings);
    MetricsLog.instance.add('PerfMonitor stopped');
  }

  void resetCounters() {
    framesOver16ms = 0;
    framesOver32ms = 0;
    totalFrames = 0;
    avgTotalMs = 0;
    avgBuildMs = 0;
    avgRasterMs = 0;
    MetricsLog.instance.add('Perf counters reset');
  }

  void _onTimings(List<FrameTiming> timings) {
    for (final t in timings) {
      final buildMs = t.buildDuration.inMicroseconds / 1000.0;
      final rasterMs = t.rasterDuration.inMicroseconds / 1000.0;
      final totalMs = buildMs + rasterMs;

      totalFrames++;
      if (totalMs > 16.0) framesOver16ms++;
      if (totalMs > 32.0) framesOver32ms++;

      // Exponential moving averages for stability
      const a = 0.1;
      avgTotalMs = avgTotalMs == 0 ? totalMs : (1 - a) * avgTotalMs + a * totalMs;
      avgBuildMs = avgBuildMs == 0 ? buildMs : (1 - a) * avgBuildMs + a * buildMs;
      avgRasterMs = avgRasterMs == 0 ? rasterMs : (1 - a) * avgRasterMs + a * rasterMs;

      // Log sparingly every ~120 frames
      if (totalFrames % 120 == 0) {
        MetricsLog.instance.log(
          'FRAME',
          'n=$totalFrames avgTotal=${avgTotalMs.toStringAsFixed(2)}ms build=${avgBuildMs.toStringAsFixed(2)}ms raster=${avgRasterMs.toStringAsFixed(2)}ms >16ms=$framesOver16ms >32ms=$framesOver32ms',
        );
      }
    }
  }

  // Navigation measurements
  void startNavigation(String label, {String phase = 'push'}) {
    final key = _navKey(label, phase);
    _navStopwatches[key] = Stopwatch()..start();
    MetricsLog.instance.log('NAV', 'start $phase "$label"');
  }

  Duration? endNavigation(String label, {String phase = 'push'}) {
    final key = _navKey(label, phase);
    final sw = _navStopwatches.remove(key);
    if (sw == null) return null;
    sw.stop();
    MetricsLog.instance.log('NAV', 'end $phase "$label" ${sw.elapsedMilliseconds}ms');
    return sw.elapsed;
  }

  Future<Duration> measurePop() async {
    final sw = Stopwatch()..start();
    // Wait at least one frame after pop completes
    await SchedulerBinding.instance.endOfFrame;
    sw.stop();
    MetricsLog.instance.log('NAV', 'pop latency ${sw.elapsedMilliseconds}ms');
    return sw.elapsed;
  }

  String _navKey(String label, String phase) => '$phase::$label';
}
