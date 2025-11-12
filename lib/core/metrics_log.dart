import 'package:flutter/foundation.dart';

class MetricsLog {
  MetricsLog._();
  static final MetricsLog instance = MetricsLog._();

  final List<String> _logs = <String>[];
  final ValueNotifier<int> changeTick = ValueNotifier<int>(0);

  List<String> get logs => List.unmodifiable(_logs);

  void clear() {
    _logs.clear();
    changeTick.value++;
  }

  void add(String message) {
    final ts = DateTime.now().toIso8601String();
    _logs.add('[$ts] $message');
    if (_logs.length > 5000) {
      _logs.removeRange(0, _logs.length - 5000);
    }
    changeTick.value++;
  }

  void log(String tag, String message) => add('$tag: $message');
}
