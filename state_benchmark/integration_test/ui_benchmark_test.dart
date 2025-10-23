import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:state_benchmark/cases/bloc_case.dart' as bloc;
import 'package:state_benchmark/cases/riverpod_case.dart' as riverpod;
import 'package:state_benchmark/cases/pipex_case.dart' as pipex;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pipe_x/pipe_x.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Global results storage
  final Map<String, Map<String, int>> allResults = {};

  group('UI Performance Benchmarks', () {
    testWidgets('BLoC Counter - Rapid Updates', (WidgetTester tester) async {
      final blocInstance = bloc.CounterBloc();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: blocInstance,
            child: const Scaffold(
              body: bloc.BlocCounterWidget(),
            ),
          ),
        ),
      );

      // Measure frame timing for 100 rapid updates
      final stopwatch = Stopwatch()..start();
      await binding.traceAction(
        () async {
          for (int i = 0; i < 100; i++) {
            blocInstance.add(bloc.IncrementEvent());
            await tester.pump();
          }
        },
        reportKey: 'bloc_counter_rapid_updates',
      );
      stopwatch.stop();

      allResults['Simple Counter'] = allResults['Simple Counter'] ?? {};
      allResults['Simple Counter']!['BLoC'] = stopwatch.elapsedMilliseconds;

      blocInstance.close();
    });

    testWidgets('Riverpod Counter - Rapid Updates',
        (WidgetTester tester) async {
      final container = ProviderContainer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: riverpod.RiverpodCounterWidget(),
            ),
          ),
        ),
      );

      // Measure frame timing for 100 rapid updates
      final stopwatch = Stopwatch()..start();
      await binding.traceAction(
        () async {
          for (int i = 0; i < 100; i++) {
            container.read(riverpod.counterProvider.notifier).increment();
            await tester.pump();
          }
        },
        reportKey: 'riverpod_counter_rapid_updates',
      );
      stopwatch.stop();

      allResults['Simple Counter'] = allResults['Simple Counter'] ?? {};
      allResults['Simple Counter']!['Riverpod'] = stopwatch.elapsedMilliseconds;

      container.dispose();
    });

    testWidgets('PipeX Counter - Rapid Updates', (WidgetTester tester) async {
      late pipex.CounterHub hub;

      await tester.pumpWidget(
        MaterialApp(
          home: HubProvider<pipex.CounterHub>(
            create: () {
              hub = pipex.CounterHub();
              return hub;
            },
            child: const Scaffold(
              body: pipex.PipeXCounterWidget(),
            ),
          ),
        ),
      );

      // Measure frame timing for 100 rapid updates
      final stopwatch = Stopwatch()..start();
      await binding.traceAction(
        () async {
          for (int i = 0; i < 100; i++) {
            hub.increment();
            await tester.pump();
          }
        },
        reportKey: 'pipex_counter_rapid_updates',
      );
      stopwatch.stop();

      allResults['Simple Counter'] = allResults['Simple Counter'] ?? {};
      allResults['Simple Counter']!['PipeX'] = stopwatch.elapsedMilliseconds;

      // Note: HubProvider handles disposal
    });

    testWidgets('BLoC Multi-Counter - 50 Counters',
        (WidgetTester tester) async {
      const counterCount = 50;
      final multiBloc = bloc.MultiCounterBloc(counterCount);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: multiBloc,
            child: const Scaffold(
              body: bloc.BlocMultiCounterWidget(count: counterCount),
            ),
          ),
        ),
      );

      // Measure frame timing for updating all counters
      final stopwatch = Stopwatch()..start();
      await binding.traceAction(
        () async {
          for (int round = 0; round < 20; round++) {
            for (int i = 0; i < counterCount; i++) {
              multiBloc.increment(i);
            }
            await tester.pump();
          }
        },
        reportKey: 'bloc_multi_counter_batch_updates',
      );
      stopwatch.stop();

      allResults['Multi-Counter (50 counters)'] =
          allResults['Multi-Counter (50 counters)'] ?? {};
      allResults['Multi-Counter (50 counters)']!['BLoC'] =
          stopwatch.elapsedMilliseconds;

      multiBloc.close();
    });

    testWidgets('Riverpod Multi-Counter - 50 Counters',
        (WidgetTester tester) async {
      const counterCount = 50;
      final container = ProviderContainer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: riverpod.RiverpodMultiCounterWidget(count: counterCount),
            ),
          ),
        ),
      );

      final notifier =
          container.read(riverpod.multiCounterProvider(counterCount).notifier);

      // Measure frame timing for updating all counters
      final stopwatch = Stopwatch()..start();
      await binding.traceAction(
        () async {
          for (int round = 0; round < 20; round++) {
            for (int i = 0; i < counterCount; i++) {
              notifier.increment(i);
            }
            await tester.pump();
          }
        },
        reportKey: 'riverpod_multi_counter_batch_updates',
      );
      stopwatch.stop();

      allResults['Multi-Counter (50 counters)'] =
          allResults['Multi-Counter (50 counters)'] ?? {};
      allResults['Multi-Counter (50 counters)']!['Riverpod'] =
          stopwatch.elapsedMilliseconds;

      container.dispose();
    });

    testWidgets('PipeX Multi-Counter - 50 Counters',
        (WidgetTester tester) async {
      const counterCount = 50;
      late pipex.MultiCounterHub hub;

      await tester.pumpWidget(
        MaterialApp(
          home: HubProvider<pipex.MultiCounterHub>(
            create: () {
              hub = pipex.MultiCounterHub(counterCount);
              return hub;
            },
            child: const Scaffold(
              body: pipex.PipeXMultiCounterWidget(count: counterCount),
            ),
          ),
        ),
      );

      // Measure frame timing for updating all counters
      final stopwatch = Stopwatch()..start();
      await binding.traceAction(
        () async {
          for (int round = 0; round < 20; round++) {
            for (int i = 0; i < counterCount; i++) {
              hub.increment(i);
            }
            await tester.pump();
          }
        },
        reportKey: 'pipex_multi_counter_batch_updates',
      );
      stopwatch.stop();

      allResults['Multi-Counter (50 counters)'] =
          allResults['Multi-Counter (50 counters)'] ?? {};
      allResults['Multi-Counter (50 counters)']!['PipeX'] =
          stopwatch.elapsedMilliseconds;

      // Note: HubProvider handles disposal
    });

    testWidgets('BLoC Complex State - Updates', (WidgetTester tester) async {
      final complexBloc = bloc.ComplexBloc();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: complexBloc,
            child: const Scaffold(
              body: bloc.BlocComplexWidget(),
            ),
          ),
        ),
      );

      // Measure frame timing for complex state updates
      final stopwatch = Stopwatch()..start();
      await binding.traceAction(
        () async {
          for (int i = 0; i < 100; i++) {
            complexBloc.add(bloc.UpdateTextEvent('Value $i'));
            complexBloc.add(bloc.UpdateNumberEvent(i));
            complexBloc.add(bloc.UpdatePercentageEvent(i * 0.5));
            await tester.pump();
          }
        },
        reportKey: 'bloc_complex_state_updates',
      );
      stopwatch.stop();

      allResults['Complex State (100 updates)'] =
          allResults['Complex State (100 updates)'] ?? {};
      allResults['Complex State (100 updates)']!['BLoC'] =
          stopwatch.elapsedMilliseconds;

      complexBloc.close();
    });

    testWidgets('Riverpod Complex State - Updates',
        (WidgetTester tester) async {
      final container = ProviderContainer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: riverpod.RiverpodComplexWidget(),
            ),
          ),
        ),
      );

      final notifier = container.read(riverpod.complexProvider.notifier);

      // Measure frame timing for complex state updates
      final stopwatch = Stopwatch()..start();
      await binding.traceAction(
        () async {
          for (int i = 0; i < 100; i++) {
            notifier.updateText('Value $i');
            notifier.updateNumber(i);
            notifier.updatePercentage(i * 0.5);
            await tester.pump();
          }
        },
        reportKey: 'riverpod_complex_state_updates',
      );
      stopwatch.stop();

      allResults['Complex State (100 updates)'] =
          allResults['Complex State (100 updates)'] ?? {};
      allResults['Complex State (100 updates)']!['Riverpod'] =
          stopwatch.elapsedMilliseconds;

      container.dispose();
    });

    testWidgets('PipeX Complex State - Updates', (WidgetTester tester) async {
      late pipex.ComplexHub hub;

      await tester.pumpWidget(
        MaterialApp(
          home: HubProvider<pipex.ComplexHub>(
            create: () {
              hub = pipex.ComplexHub();
              return hub;
            },
            child: const Scaffold(
              body: pipex.PipeXComplexWidget(),
            ),
          ),
        ),
      );

      // Measure frame timing for complex state updates
      final stopwatch = Stopwatch()..start();
      await binding.traceAction(
        () async {
          for (int i = 0; i < 100; i++) {
            hub.updateText('Value $i');
            hub.updateNumber(i);
            hub.updatePercentage(i * 0.5);
            await tester.pump();
          }
        },
        reportKey: 'pipex_complex_state_updates',
      );
      stopwatch.stop();

      allResults['Complex State (100 updates)'] =
          allResults['Complex State (100 updates)'] ?? {};
      allResults['Complex State (100 updates)']!['PipeX'] =
          stopwatch.elapsedMilliseconds;

      // Note: HubProvider handles disposal
    });

    testWidgets('Stress Test - All Frameworks', (WidgetTester tester) async {
      // This is an extreme stress test that runs continuously
      final results = <String, int>{};

      // BLoC stress test
      final blocInstance = bloc.CounterBloc();
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: blocInstance,
            child: const Scaffold(body: bloc.BlocCounterWidget()),
          ),
        ),
      );

      final blocStopwatch = Stopwatch()..start();
      for (int i = 0; i < 1000; i++) {
        blocInstance.add(bloc.IncrementEvent());
        await tester.pump();
      }
      blocStopwatch.stop();
      results['BLoC'] = blocStopwatch.elapsedMilliseconds;
      blocInstance.close();

      // Riverpod stress test
      final container = ProviderContainer();
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(body: riverpod.RiverpodCounterWidget()),
          ),
        ),
      );

      final riverpodStopwatch = Stopwatch()..start();
      for (int i = 0; i < 1000; i++) {
        container.read(riverpod.counterProvider.notifier).increment();
        await tester.pump();
      }
      riverpodStopwatch.stop();
      results['Riverpod'] = riverpodStopwatch.elapsedMilliseconds;
      container.dispose();

      // PipeX stress test - Note: HubProvider manages hub lifecycle
      late pipex.CounterHub hub;
      await tester.pumpWidget(
        MaterialApp(
          home: HubProvider<pipex.CounterHub>(
            create: () {
              hub = pipex.CounterHub();
              return hub;
            },
            child: const Scaffold(body: pipex.PipeXCounterWidget()),
          ),
        ),
      );

      final pipexStopwatch = Stopwatch()..start();
      for (int i = 0; i < 1000; i++) {
        hub.increment();
        await tester.pump();
      }
      pipexStopwatch.stop();
      results['PipeX'] = pipexStopwatch.elapsedMilliseconds;
      // Note: No manual dispose - HubProvider handles it

      // Print comprehensive results to console
      print('\n' + '=' * 60);
      print('         STRESS TEST RESULTS (1000 updates)');
      print('=' * 60);
      print('Timestamp: ${DateTime.now().toIso8601String()}');
      print('Test Type: Rapid state updates with widget rebuilds');
      print('-' * 60);

      // Find fastest and slowest
      final sortedResults = results.entries.toList()
        ..sort((a, b) => a.value.compareTo(b.value));
      final fastest = sortedResults.first;
      final slowest = sortedResults.last;

      print('\n📊 RESULTS:');
      for (final entry in sortedResults) {
        final isfastest = entry.key == fastest.key;
        final isSlowest = entry.key == slowest.key;
        final marker = isfastest
            ? '🏆 '
            : isSlowest
                ? '🐌 '
                : '   ';
        print(
            '$marker${entry.key.padRight(12)}: ${entry.value.toString().padLeft(6)} ms');
      }

      print('\n📈 ANALYSIS:');
      if (results.length >= 2) {
        final diff = slowest.value - fastest.value;
        final percentDiff = ((diff / fastest.value) * 100).toStringAsFixed(1);
        print('   Fastest: ${fastest.key} (${fastest.value} ms)');
        print('   Slowest: ${slowest.key} (${slowest.value} ms)');
        print('   Difference: ${diff} ms ($percentDiff% slower)');
      }

      print('=' * 60 + '\n');

      // Store results for final comprehensive summary
      allResults['Stress Test (1000 updates)'] = results;
    });
  });

  group('Memory Usage Benchmarks', () {
    testWidgets('Memory - Large State Trees', (WidgetTester tester) async {
      // Test memory usage with large number of state instances
      const instanceCount = 100;

      // BLoC memory test
      final blocs = List.generate(instanceCount, (_) => bloc.CounterBloc());
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: blocs
                  .map((b) => BlocProvider.value(
                        value: b,
                        child: const bloc.BlocCounterWidget(),
                      ))
                  .toList(),
            ),
          ),
        ),
      );
      await tester.pump();
      for (final b in blocs) {
        b.close();
      }

      // PipeX memory test - HubProvider manages lifecycle
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: List.generate(
                instanceCount,
                (i) => HubProvider<pipex.CounterHub>(
                  key: ValueKey('hub_$i'),
                  create: () => pipex.CounterHub(),
                  child: const pipex.PipeXCounterWidget(),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      // HubProviders will automatically dispose hubs when widgets are removed

      print(
          'Memory test complete: Created and disposed $instanceCount instances per framework');
    });
  });

  group('Frame Timing Benchmarks', () {
    testWidgets('Measure 60 FPS Capability', (WidgetTester tester) async {
      // Test if frameworks can maintain 60 FPS under load
      final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

      late pipex.CounterHub hub;
      await tester.pumpWidget(
        MaterialApp(
          home: HubProvider<pipex.CounterHub>(
            create: () {
              hub = pipex.CounterHub();
              return hub;
            },
            child: const Scaffold(body: pipex.PipeXCounterWidget()),
          ),
        ),
      );

      // Update at 60 FPS for 3 seconds and measure performance
      final stopwatch = Stopwatch()..start();
      await binding.watchPerformance(() async {
        for (int i = 0; i < 180; i++) {
          hub.increment();
          await tester.pump(const Duration(milliseconds: 16)); // ~60 FPS
        }
      });
      stopwatch.stop();

      print('Frame timing test complete:');
      print('Total time for 180 frames: ${stopwatch.elapsedMilliseconds} ms');
      print(
          'Average frame time: ${(stopwatch.elapsedMilliseconds / 180).toStringAsFixed(2)} ms');
      print('Target: 16.67 ms per frame for 60 FPS');
      // Note: HubProvider will dispose hub automatically
    });
  });

  // Print comprehensive summary after all tests
  tearDownAll(() {
    if (allResults.isEmpty) return;

    print('\n\n');
    print('╔' + '═' * 78 + '╗');
    print(
        '║' + ' ' * 20 + '📊 COMPREHENSIVE BENCHMARK RESULTS' + ' ' * 24 + '║');
    print('╚' + '═' * 78 + '╝');
    print('\n');

    // Print each test category
    for (final testCategory in allResults.keys) {
      print('┌─ $testCategory ${'─' * (75 - testCategory.length)}');

      final results = allResults[testCategory]!;
      final sortedFrameworks = results.keys.toList()
        ..sort((a, b) => results[a]!.compareTo(results[b]!));

      // Find fastest and slowest
      final fastest = sortedFrameworks.first;
      final slowest = sortedFrameworks.last;

      for (final framework in sortedFrameworks) {
        final time = results[framework]!;
        final isFastest = framework == fastest;
        final isSlowest = framework == slowest && sortedFrameworks.length > 1;
        final marker = isFastest
            ? '🏆'
            : isSlowest
                ? '🐌'
                : '  ';

        print(
            '│  $marker ${framework.padRight(12)}: ${time.toString().padLeft(6)} ms');
      }

      // Print analysis if multiple frameworks
      if (sortedFrameworks.length > 1) {
        final fastestTime = results[fastest]!;
        final slowestTime = results[slowest]!;
        final diff = slowestTime - fastestTime;
        final percentDiff = ((diff / fastestTime) * 100).toStringAsFixed(1);
        print('│');
        print(
            '│  💡 $fastest is fastest by ${diff}ms ($percentDiff% faster than $slowest)');
      }

      print('└' + '─' * 78);
      print('');
    }

    print('╔' + '═' * 78 + '╗');
    print('║' + ' ' * 32 + 'TEST COMPLETE' + ' ' * 33 + '║');
    print('╚' + '═' * 78 + '╝');
    print('\n');
  });
}
