import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ============================================================================
// Riverpod Case: Counter with rapid updates
// ============================================================================

class CounterNotifier extends StateNotifier<int> {
  CounterNotifier() : super(0);

  void increment() => state++;
  void decrement() => state--;
  void setValue(int value) => state = value;
}

final counterProvider = StateNotifierProvider<CounterNotifier, int>((ref) {
  return CounterNotifier();
});

// ============================================================================
// Riverpod Case: Multi-Counter (Many independent counters)
// ============================================================================

// FAIR IMPLEMENTATION: Using family providers for true isolation (like PipeX's pipes)
final individualCounterProvider =
    StateProvider.family<int, int>((ref, id) => 0);

// Legacy implementation for comparison
class MultiCounterNotifier extends StateNotifier<Map<int, int>> {
  MultiCounterNotifier(int count)
      : super(Map.fromIterable(List.generate(count, (i) => i),
            key: (i) => i, value: (_) => 0));

  void increment(int id) {
    state = {...state, id: (state[id] ?? 0) + 1};
  }
}

final multiCounterProvider =
    StateNotifierProvider.family<MultiCounterNotifier, Map<int, int>, int>(
  (ref, count) => MultiCounterNotifier(count),
);

// ============================================================================
// Riverpod Case: Complex State (Large object with nested data)
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

class ComplexNotifier extends StateNotifier<ComplexData> {
  ComplexNotifier()
      : super(const ComplexData(
          text: 'Initial',
          number: 0,
          percentage: 0.0,
          flag: false,
          items: [],
          metadata: {},
        ));

  void updateText(String text) => state = state.copyWith(text: text);
  void updateNumber(int number) => state = state.copyWith(number: number);
  void updatePercentage(double percentage) =>
      state = state.copyWith(percentage: percentage);
}

final complexProvider =
    StateNotifierProvider<ComplexNotifier, ComplexData>((ref) {
  return ComplexNotifier();
});

// ============================================================================
// Riverpod Case: Async Stream (Simulates rapid async updates)
// ============================================================================

class AsyncCounterNotifier extends StateNotifier<int> {
  AsyncCounterNotifier() : super(0);

  Future<void> incrementAsync() async {
    await Future.delayed(const Duration(microseconds: 100));
    state++;
  }
}

final asyncCounterProvider =
    StateNotifierProvider<AsyncCounterNotifier, int>((ref) {
  return AsyncCounterNotifier();
});

final rapidStreamProvider = StreamProvider.family<int, int>((ref, count) {
  return Stream.periodic(const Duration(microseconds: 100), (i) => i)
      .take(count);
});

// ============================================================================
// Riverpod Case: Derived/Computed State (Riverpod's STRENGTH)
// ============================================================================

// Base counter
final baseCounterProvider = StateProvider<int>((ref) => 0);

// Computed states - automatically recompute when base changes
final doubleCountProvider = Provider<int>((ref) {
  final count = ref.watch(baseCounterProvider);
  return count * 2;
});

final squareCountProvider = Provider<int>((ref) {
  final count = ref.watch(baseCounterProvider);
  return count * count;
});

final isEvenProvider = Provider<bool>((ref) {
  final count = ref.watch(baseCounterProvider);
  return count % 2 == 0;
});

final factorialProvider = Provider<int>((ref) {
  final count = ref.watch(baseCounterProvider);
  if (count <= 0) return 1;
  int result = 1;
  for (int i = 1; i <= count && i <= 20; i++) {
    result *= i;
  }
  return result;
});

// Complex computed state depending on multiple providers
final summaryProvider = Provider<String>((ref) {
  final count = ref.watch(baseCounterProvider);
  final double = ref.watch(doubleCountProvider);
  final isEven = ref.watch(isEvenProvider);
  return 'Count: $count, Double: $double, ${isEven ? "Even" : "Odd"}';
});

// ============================================================================
// Riverpod UI Components
// ============================================================================

class RiverpodCounterWidget extends ConsumerWidget {
  const RiverpodCounterWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);
    final notifier = ref.read(counterProvider.notifier);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Riverpod: $count',
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: notifier.decrement,
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: notifier.increment,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RiverpodMultiCounterWidget extends ConsumerWidget {
  final int count;
  final bool useIsolation;

  const RiverpodMultiCounterWidget({
    super.key,
    required this.count,
    this.useIsolation = true, // Default to fair implementation
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (useIsolation) {
      // FAIR: Each counter is isolated (like PipeX pipes)
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text('Riverpod Multi-Counter ($count) [Isolated]',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: List.generate(
                  count,
                  (i) => Consumer(
                    builder: (context, ref, _) {
                      final value = ref.watch(individualCounterProvider(i));
                      return Chip(
                        label: Text('$value'),
                        onDeleted: () => ref
                            .read(individualCounterProvider(i).notifier)
                            .state++,
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
    } else {
      // LEGACY: All counters in single map (not fair vs PipeX)
      final counters = ref.watch(multiCounterProvider(count));
      final notifier = ref.read(multiCounterProvider(count).notifier);

      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text('Riverpod Multi-Counter ($count) [Batch]',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: List.generate(
                  count,
                  (i) => Chip(
                    label: Text('${counters[i]}'),
                    onDeleted: () => notifier.increment(i),
                    deleteIcon: const Icon(Icons.add, size: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}

class RiverpodComplexWidget extends ConsumerWidget {
  const RiverpodComplexWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(complexProvider);
    final notifier = ref.read(complexProvider.notifier);

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
                Text('Riverpod Complex: ${data.text}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Number: ${data.number}'),
                const SizedBox(height: 4),
                Text('Percentage: ${data.percentage.toStringAsFixed(2)}%'),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.update, size: 18),
                  onPressed: () => notifier.updateNumber(data.number + 1),
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

class RiverpodDerivedStateWidget extends ConsumerWidget {
  const RiverpodDerivedStateWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(baseCounterProvider);
    final double = ref.watch(doubleCountProvider);
    final square = ref.watch(squareCountProvider);
    final isEven = ref.watch(isEvenProvider);
    final factorial = ref.watch(factorialProvider);
    final summary = ref.watch(summaryProvider);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Riverpod Derived State (Automatic Recomputation)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Base', '$count', Icons.looks_one),
                    const SizedBox(height: 8),
                    _buildInfoRow('Double', '$double', Icons.looks_two),
                    const SizedBox(height: 8),
                    _buildInfoRow('Square', '$square', Icons.crop_square),
                    const SizedBox(height: 8),
                    _buildInfoRow('Is Even', '$isEven', Icons.check_circle),
                    const SizedBox(height: 8),
                    _buildInfoRow('Factorial', '$factorial', Icons.calculate),
                    const Divider(height: 24),
                    Row(
                      children: [
                        Icon(Icons.summarize,
                            size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(summary,
                              style: const TextStyle(
                                  fontSize: 12, fontStyle: FontStyle.italic)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.add, size: 18),
                  onPressed: () =>
                      ref.read(baseCounterProvider.notifier).state++,
                  label: const Text('Increment'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh, size: 18),
                  onPressed: () =>
                      ref.read(baseCounterProvider.notifier).state = 0,
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
