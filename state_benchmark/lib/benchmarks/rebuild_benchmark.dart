import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../cases/bloc_case.dart' as bloc;
import '../cases/riverpod_case.dart' as riverpod;
import '../cases/pipex_case.dart' as pipex;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pipe_x/pipe_x.dart';

// ============================================================================
// Rebuild Count Benchmark
// Tests how many times widgets rebuild during rapid state changes
// ============================================================================

class BlocRebuildBenchmark extends BenchmarkBase {
  late int rebuildCount;

  BlocRebuildBenchmark() : super('BLoC Rebuild Count');

  @override
  void setup() {
    rebuildCount = 0;
  }

  @override
  void run() {
    testWidgets('BLoC rebuild test', (WidgetTester tester) async {
      final blocInstance = bloc.CounterBloc();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: blocInstance,
            child: BlocBuilder<bloc.CounterBloc, bloc.CounterState>(
              builder: (context, state) {
                rebuildCount++;
                return Text('${state.value}');
              },
            ),
          ),
        ),
      );

      // Perform 100 rapid updates
      for (int i = 0; i < 100; i++) {
        blocInstance.add(bloc.IncrementEvent());
        await tester.pump();
      }

      blocInstance.close();
    });
  }

  @override
  void report() {
    print('$name: $rebuildCount rebuilds for 100 updates');
  }
}

class RiverpodRebuildBenchmark extends BenchmarkBase {
  late int rebuildCount;

  RiverpodRebuildBenchmark()
      : super('Riverpod Rebuild Count (Fair - Isolated)');

  @override
  void setup() {
    rebuildCount = 0;
  }

  @override
  void run() {
    testWidgets('Riverpod rebuild test', (WidgetTester tester) async {
      final container = ProviderContainer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, _) {
                rebuildCount++;
                final count = ref.watch(riverpod.counterProvider);
                return Text('$count');
              },
            ),
          ),
        ),
      );

      // Perform 100 rapid updates
      for (int i = 0; i < 100; i++) {
        container.read(riverpod.counterProvider.notifier).increment();
        await tester.pump();
      }

      container.dispose();
    });
  }

  @override
  void report() {
    print('$name: $rebuildCount rebuilds for 100 updates');
  }
}

class PipeXRebuildBenchmark extends BenchmarkBase {
  late int rebuildCount;

  PipeXRebuildBenchmark() : super('PipeX Rebuild Count');

  @override
  void setup() {
    rebuildCount = 0;
  }

  @override
  void run() {
    testWidgets('PipeX rebuild test', (WidgetTester tester) async {
      final hub = pipex.CounterHub();

      await tester.pumpWidget(
        MaterialApp(
          home: HubProvider<pipex.CounterHub>(
            create: () => hub,
            child: Builder(
              builder: (context) {
                return Sink<int>(
                  pipe: hub.count,
                  builder: (context, value) {
                    rebuildCount++;
                    return Text('$value');
                  },
                );
              },
            ),
          ),
        ),
      );

      // Perform 100 rapid updates
      for (int i = 0; i < 100; i++) {
        hub.increment();
        await tester.pump();
      }

      hub.dispose();
    });
  }

  @override
  void report() {
    print('$name: $rebuildCount rebuilds for 100 updates');
  }
}

// ============================================================================
// Multi-Widget Rebuild Benchmark
// Tests rebuild isolation when multiple widgets share state
// ============================================================================

class MultiWidgetRebuildTracker {
  int widget1Rebuilds = 0;
  int widget2Rebuilds = 0;
  int widget3Rebuilds = 0;

  void reset() {
    widget1Rebuilds = 0;
    widget2Rebuilds = 0;
    widget3Rebuilds = 0;
  }

  int get total => widget1Rebuilds + widget2Rebuilds + widget3Rebuilds;
}

class BlocMultiWidgetBenchmark extends BenchmarkBase {
  final tracker = MultiWidgetRebuildTracker();

  BlocMultiWidgetBenchmark() : super('BLoC Multi-Widget Rebuild');

  @override
  void setup() {
    tracker.reset();
  }

  @override
  void run() {
    testWidgets('BLoC multi-widget test', (WidgetTester tester) async {
      final blocInstance = bloc.CounterBloc();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: blocInstance,
            child: Column(
              children: [
                BlocBuilder<bloc.CounterBloc, bloc.CounterState>(
                  builder: (context, state) {
                    tracker.widget1Rebuilds++;
                    return Text('W1: ${state.value}');
                  },
                ),
                BlocBuilder<bloc.CounterBloc, bloc.CounterState>(
                  builder: (context, state) {
                    tracker.widget2Rebuilds++;
                    return Text('W2: ${state.value}');
                  },
                ),
                BlocBuilder<bloc.CounterBloc, bloc.CounterState>(
                  builder: (context, state) {
                    tracker.widget3Rebuilds++;
                    return Text('W3: ${state.value}');
                  },
                ),
              ],
            ),
          ),
        ),
      );

      // Update once - should rebuild all 3 widgets
      for (int i = 0; i < 50; i++) {
        blocInstance.add(bloc.IncrementEvent());
        await tester.pump();
      }

      blocInstance.close();
    });
  }

  @override
  void report() {
    print(
        '$name: ${tracker.total} total rebuilds (W1: ${tracker.widget1Rebuilds}, W2: ${tracker.widget2Rebuilds}, W3: ${tracker.widget3Rebuilds})');
  }
}

class PipeXMultiWidgetBenchmark extends BenchmarkBase {
  final tracker = MultiWidgetRebuildTracker();

  PipeXMultiWidgetBenchmark() : super('PipeX Multi-Widget Rebuild');

  @override
  void setup() {
    tracker.reset();
  }

  @override
  void run() {
    testWidgets('PipeX multi-widget test', (WidgetTester tester) async {
      final hub = pipex.CounterHub();

      await tester.pumpWidget(
        MaterialApp(
          home: HubProvider<pipex.CounterHub>(
            create: () => hub,
            child: Column(
              children: [
                Sink<int>(
                  pipe: hub.count,
                  builder: (context, value) {
                    tracker.widget1Rebuilds++;
                    return Text('W1: $value');
                  },
                ),
                Sink<int>(
                  pipe: hub.count,
                  builder: (context, value) {
                    tracker.widget2Rebuilds++;
                    return Text('W2: $value');
                  },
                ),
                Sink<int>(
                  pipe: hub.count,
                  builder: (context, value) {
                    tracker.widget3Rebuilds++;
                    return Text('W3: $value');
                  },
                ),
              ],
            ),
          ),
        ),
      );

      // Update once - should rebuild all 3 widgets
      for (int i = 0; i < 50; i++) {
        hub.increment();
        await tester.pump();
      }

      hub.dispose();
    });
  }

  @override
  void report() {
    print(
        '$name: ${tracker.total} total rebuilds (W1: ${tracker.widget1Rebuilds}, W2: ${tracker.widget2Rebuilds}, W3: ${tracker.widget3Rebuilds})');
  }
}

// ============================================================================
// Run all rebuild benchmarks
// ============================================================================

void runRebuildBenchmarks() {
  print('\n=== REBUILD BENCHMARKS ===\n');

  print('Single Widget Rebuilds:');
  BlocRebuildBenchmark().report();
  RiverpodRebuildBenchmark().report();
  PipeXRebuildBenchmark().report();

  print('\nMulti-Widget Rebuilds (50 updates):');
  BlocMultiWidgetBenchmark().report();
  PipeXMultiWidgetBenchmark().report();
}
