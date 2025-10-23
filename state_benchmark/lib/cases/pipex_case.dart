import 'package:flutter/material.dart';
import 'package:pipe_x/pipe_x.dart';

// ============================================================================
// PipeX Case: Counter with rapid updates
// ============================================================================

class CounterHub extends Hub {
  late final Pipe<int> count;

  CounterHub() {
    count = registerPipe(Pipe(0));
  }

  void increment() => count.value++;
  void decrement() => count.value--;
  void setValue(int value) => count.value = value;
}

// ============================================================================
// PipeX Case: Multi-Counter (Many independent counters)
// ============================================================================

class MultiCounterHub extends Hub {
  late final Map<int, Pipe<int>> counters;

  MultiCounterHub(int count) {
    counters = {};
    for (int i = 0; i < count; i++) {
      counters[i] = registerPipe(Pipe(0));
    }
  }

  void increment(int id) {
    counters[id]?.value = (counters[id]?.value ?? 0) + 1;
  }
}

// ============================================================================
// PipeX Case: Complex State (Large object with nested data)
// ============================================================================

class ComplexData {
  final String text;
  final int number;
  final double percentage;
  final bool flag;
  final List<String> items;
  final Map<String, dynamic> metadata;

  const ComplexData({
    required this.text,
    required this.number,
    required this.percentage,
    required this.flag,
    required this.items,
    required this.metadata,
  });

  ComplexData copyWith({
    String? text,
    int? number,
    double? percentage,
    bool? flag,
    List<String>? items,
    Map<String, dynamic>? metadata,
  }) {
    return ComplexData(
      text: text ?? this.text,
      number: number ?? this.number,
      percentage: percentage ?? this.percentage,
      flag: flag ?? this.flag,
      items: items ?? this.items,
      metadata: metadata ?? this.metadata,
    );
  }
}

class ComplexHub extends Hub {
  late final Pipe<String> text;
  late final Pipe<int> number;
  late final Pipe<double> percentage;
  late final Pipe<bool> flag;
  late final Pipe<List<String>> items;
  late final Pipe<Map<String, dynamic>> metadata;

  ComplexHub() {
    text = registerPipe(Pipe('Initial'));
    number = registerPipe(Pipe(0));
    percentage = registerPipe(Pipe(0.0));
    flag = registerPipe(Pipe(false));
    items = registerPipe(Pipe([]));
    metadata = registerPipe(Pipe({}));
  }

  void updateText(String value) => text.value = value;
  void updateNumber(int value) => number.value = value;
  void updatePercentage(double value) => percentage.value = value;
}

// ============================================================================
// PipeX Case: Async Stream (Simulates rapid async updates)
// ============================================================================

class AsyncCounterHub extends Hub {
  late final Pipe<int> count;

  AsyncCounterHub() {
    count = registerPipe(Pipe(0));
  }

  Future<void> incrementAsync() async {
    await Future.delayed(const Duration(microseconds: 100));
    count.value++;
  }

  Stream<int> rapidStream(int total) async* {
    for (int i = 0; i < total; i++) {
      await Future.delayed(const Duration(microseconds: 100));
      yield i;
    }
  }
}

// ============================================================================
// PipeX Case: Derived State (Manual computed values)
// ============================================================================

class DerivedStateHub extends Hub {
  late final Pipe<int> baseCount;
  late final Pipe<int> doubleCount;
  late final Pipe<int> squareCount;
  late final Pipe<bool> isEven;
  late final Pipe<int> factorial;
  late final Pipe<String> summary;

  DerivedStateHub() {
    baseCount = registerPipe(Pipe(0));
    doubleCount = registerPipe(Pipe(0));
    squareCount = registerPipe(Pipe(0));
    isEven = registerPipe(Pipe(true));
    factorial = registerPipe(Pipe(1));
    summary = registerPipe(Pipe('Count: 0, Double: 0, Even'));

    // Listen to base and update derived values
    baseCount.addListener(_updateDerivedValues);
  }

  void _updateDerivedValues() {
    final value = baseCount.value;
    doubleCount.value = value * 2;
    squareCount.value = value * value;
    isEven.value = value % 2 == 0;

    // Calculate factorial
    if (value <= 0) {
      factorial.value = 1;
    } else {
      int result = 1;
      for (int i = 1; i <= value && i <= 20; i++) {
        result *= i;
      }
      factorial.value = result;
    }

    summary.value =
        'Count: $value, Double: ${doubleCount.value}, ${isEven.value ? "Even" : "Odd"}';
  }

  void increment() {
    baseCount.value++;
  }

  void reset() {
    baseCount.value = 0;
  }
}

// ============================================================================
// PipeX UI Components
// ============================================================================

class PipeXCounterWidget extends StatelessWidget {
  const PipeXCounterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final hub = HubProvider.read<CounterHub>(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Sink<int>(
            pipe: hub.count,
            builder: (context, value) {
              return Text('PipeX: $value',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold));
            },
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: hub.decrement,
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: hub.increment,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PipeXMultiCounterWidget extends StatelessWidget {
  final int count;
  const PipeXMultiCounterWidget({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    final hub = HubProvider.read<MultiCounterHub>(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('PipeX Multi-Counter ($count)',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: List.generate(
                count,
                (i) => Sink<int>(
                  pipe: hub.counters[i]!,
                  builder: (context, value) {
                    return Chip(
                      label: Text('$value'),
                      onDeleted: () => hub.increment(i),
                      deleteIcon: const Icon(Icons.add, size: 16),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PipeXComplexWidget extends StatelessWidget {
  const PipeXComplexWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final hub = HubProvider.read<ComplexHub>(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Well(
                  pipes: [hub.text, hub.number, hub.percentage],
                  builder: (context) {
                    return Column(
                      children: [
                        Text('PipeX Complex: ${hub.text.value}',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('Number: ${hub.number.value}'),
                        const SizedBox(height: 4),
                        Text(
                            'Percentage: ${hub.percentage.value.toStringAsFixed(2)}%'),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.update, size: 18),
                  onPressed: () => hub.updateNumber(hub.number.value + 1),
                  label: const Text('Update'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PipeXDerivedStateWidget extends StatelessWidget {
  const PipeXDerivedStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final hub = HubProvider.read<DerivedStateHub>(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'PipeX Derived State (Manual Listeners)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Well(
                  pipes: [
                    hub.baseCount,
                    hub.doubleCount,
                    hub.squareCount,
                    hub.isEven,
                    hub.factorial,
                    hub.summary,
                  ],
                  builder: (context) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(
                            'Base', '${hub.baseCount.value}', Icons.looks_one),
                        const SizedBox(height: 8),
                        _buildInfoRow('Double', '${hub.doubleCount.value}',
                            Icons.looks_two),
                        const SizedBox(height: 8),
                        _buildInfoRow('Square', '${hub.squareCount.value}',
                            Icons.crop_square),
                        const SizedBox(height: 8),
                        _buildInfoRow('Is Even', '${hub.isEven.value}',
                            Icons.check_circle),
                        const SizedBox(height: 8),
                        _buildInfoRow('Factorial', '${hub.factorial.value}',
                            Icons.calculate),
                        const Divider(height: 24),
                        Row(
                          children: [
                            Icon(Icons.summarize,
                                size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(hub.summary.value,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic)),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.add, size: 18),
                  onPressed: hub.increment,
                  label: const Text('Increment'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh, size: 18),
                  onPressed: hub.reset,
                  label: const Text('Reset'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.blue),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
        Text(value, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
