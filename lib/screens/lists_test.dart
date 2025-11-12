import 'package:flutter/material.dart';
import '../core/perf_monitor.dart';
import '../core/metrics_log.dart';
import '../utils/mock_data.dart';

class ListsTestScreen extends StatefulWidget {
  const ListsTestScreen({super.key});

  @override
  State<ListsTestScreen> createState() => _ListsTestScreenState();
}

class _ListsTestScreenState extends State<ListsTestScreen> {
  final List<int> sizes = const [1000, 5000, 10000];
  int _size = 1000;
  bool _grid = false;
  late List<String> _items;

  @override
  void initState() {
    super.initState();
    PerfMonitor.instance.endNavigation('Lists', phase: 'push');
    _items = MockData.generateItems(_size);
  }

  void _apply() {
    setState(() {
      _items = MockData.generateItems(_size);
      MetricsLog.instance.log('LIST', 'size=$_size grid=${_grid ? 'ON' : 'OFF'}');
    });
  }

  @override
  Widget build(BuildContext context) {
    final pm = PerfMonitor.instance;
    return Scaffold(
      appBar: AppBar(title: const Text('Lists Test')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Text('Items:'),
                const SizedBox(width: 8),
                DropdownButton<int>(
                  value: _size,
                  items: sizes.map((s) => DropdownMenuItem(value: s, child: Text('$s'))).toList(),
                  onChanged: (v) { if (v != null) { _size = v; _apply(); } },
                ),
                const SizedBox(width: 16),
                const Text('Grid:'),
                Switch(value: _grid, onChanged: (v) { _grid = v; _apply(); }),
                const Spacer(),
                Text('>16ms ${pm.framesOver16ms}  >32ms ${pm.framesOver32ms}  avg ${pm.avgTotalMs.toStringAsFixed(2)}ms'),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _grid
                ? GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 3),
                    itemCount: _items.length,
                    itemBuilder: (_, i) => _cell(_items[i]),
                  )
                : ListView.builder(
                    itemCount: _items.length,
                    itemBuilder: (_, i) => _cell(_items[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _cell(String text) {
    return ListTile(
      title: Text(text),
      subtitle: const Text('Lorem ipsum dolor sit amet'),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
