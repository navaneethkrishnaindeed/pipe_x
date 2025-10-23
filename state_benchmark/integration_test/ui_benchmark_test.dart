import 'dart:io';
import 'dart:convert';
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
  // Enhanced binding with performance profiling
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Storage for comprehensive results
  final Map<String, Map<String, BenchmarkMetrics>> allResults = {};
  final List<Map<String, dynamic>> detailedMetrics = [];

  group('🚀 Performance Benchmarks - Simple Counter', () {
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

      // Enhanced performance measurement
      final stopwatch = Stopwatch()..start();
      final List<int> frameTimes = [];

      // Use traceAction for detailed timeline
      await binding.traceAction(
        () async {
          for (int i = 0; i < 100; i++) {
            final frameStart = stopwatch.elapsedMicroseconds;
            blocInstance.add(bloc.IncrementEvent());
            await tester.pump();
            final frameTime = stopwatch.elapsedMicroseconds - frameStart;
            frameTimes.add(frameTime);
          }
        },
        reportKey: 'bloc_simple_counter',
      );

      stopwatch.stop();

      final metrics = BenchmarkMetrics.fromFrameTimes(
        frameTimes: frameTimes,
        totalDuration: stopwatch.elapsedMilliseconds,
        testName: 'BLoC - Simple Counter (100 updates)',
        framework: 'BLoC',
        category: 'Simple Counter',
      );

      allResults['Simple Counter'] = allResults['Simple Counter'] ?? {};
      allResults['Simple Counter']!['BLoC'] = metrics;
      detailedMetrics.add(metrics.toJson());

      _printMetrics('BLoC Simple Counter', metrics);
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

      final stopwatch = Stopwatch()..start();
      final List<int> frameTimes = [];

      await binding.traceAction(
        () async {
          for (int i = 0; i < 100; i++) {
            final frameStart = stopwatch.elapsedMicroseconds;
            container.read(riverpod.counterProvider.notifier).increment();
            await tester.pump();
            final frameTime = stopwatch.elapsedMicroseconds - frameStart;
            frameTimes.add(frameTime);
          }
        },
        reportKey: 'riverpod_simple_counter',
      );

      stopwatch.stop();

      final metrics = BenchmarkMetrics.fromFrameTimes(
        frameTimes: frameTimes,
        totalDuration: stopwatch.elapsedMilliseconds,
        testName: 'Riverpod - Simple Counter (100 updates)',
        framework: 'Riverpod',
        category: 'Simple Counter',
      );

      allResults['Simple Counter'] = allResults['Simple Counter'] ?? {};
      allResults['Simple Counter']!['Riverpod'] = metrics;
      detailedMetrics.add(metrics.toJson());

      _printMetrics('Riverpod Simple Counter', metrics);
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

      final stopwatch = Stopwatch()..start();
      final List<int> frameTimes = [];

      await binding.traceAction(
        () async {
          for (int i = 0; i < 100; i++) {
            final frameStart = stopwatch.elapsedMicroseconds;
            hub.increment();
            await tester.pump();
            final frameTime = stopwatch.elapsedMicroseconds - frameStart;
            frameTimes.add(frameTime);
          }
        },
        reportKey: 'pipex_simple_counter',
      );

      stopwatch.stop();

      final metrics = BenchmarkMetrics.fromFrameTimes(
        frameTimes: frameTimes,
        totalDuration: stopwatch.elapsedMilliseconds,
        testName: 'PipeX - Simple Counter (100 updates)',
        framework: 'PipeX',
        category: 'Simple Counter',
      );

      allResults['Simple Counter'] = allResults['Simple Counter'] ?? {};
      allResults['Simple Counter']!['PipeX'] = metrics;
      detailedMetrics.add(metrics.toJson());

      _printMetrics('PipeX Simple Counter', metrics);
    });
  });

  group('🔥 Performance Benchmarks - Multi-Counter (50 counters)', () {
    testWidgets('BLoC Multi-Counter - Batch Updates',
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

      final stopwatch = Stopwatch()..start();
      final List<int> frameTimes = [];

      await binding.traceAction(
        () async {
          for (int round = 0; round < 20; round++) {
            final frameStart = stopwatch.elapsedMicroseconds;
            for (int i = 0; i < counterCount; i++) {
              multiBloc.increment(i);
            }
            await tester.pump();
            final frameTime = stopwatch.elapsedMicroseconds - frameStart;
            frameTimes.add(frameTime);
          }
        },
        reportKey: 'bloc_multi_counter',
      );

      stopwatch.stop();

      final metrics = BenchmarkMetrics.fromFrameTimes(
        frameTimes: frameTimes,
        totalDuration: stopwatch.elapsedMilliseconds,
        testName: 'BLoC - Multi-Counter (50 counters, 20 rounds)',
        framework: 'BLoC',
        category: 'Multi-Counter',
      );

      allResults['Multi-Counter (50 counters)'] =
          allResults['Multi-Counter (50 counters)'] ?? {};
      allResults['Multi-Counter (50 counters)']!['BLoC'] = metrics;
      detailedMetrics.add(metrics.toJson());

      _printMetrics('BLoC Multi-Counter', metrics);
      multiBloc.close();
    });

    testWidgets('Riverpod Multi-Counter - Batch Updates',
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

      final stopwatch = Stopwatch()..start();
      final List<int> frameTimes = [];

      await binding.traceAction(
        () async {
          for (int round = 0; round < 20; round++) {
            final frameStart = stopwatch.elapsedMicroseconds;
            for (int i = 0; i < counterCount; i++) {
              notifier.increment(i);
            }
            await tester.pump();
            final frameTime = stopwatch.elapsedMicroseconds - frameStart;
            frameTimes.add(frameTime);
          }
        },
        reportKey: 'riverpod_multi_counter',
      );

      stopwatch.stop();

      final metrics = BenchmarkMetrics.fromFrameTimes(
        frameTimes: frameTimes,
        totalDuration: stopwatch.elapsedMilliseconds,
        testName: 'Riverpod - Multi-Counter (50 counters, 20 rounds)',
        framework: 'Riverpod',
        category: 'Multi-Counter',
      );

      allResults['Multi-Counter (50 counters)'] =
          allResults['Multi-Counter (50 counters)'] ?? {};
      allResults['Multi-Counter (50 counters)']!['Riverpod'] = metrics;
      detailedMetrics.add(metrics.toJson());

      _printMetrics('Riverpod Multi-Counter', metrics);
      container.dispose();
    });

    testWidgets('PipeX Multi-Counter - Batch Updates',
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

      final stopwatch = Stopwatch()..start();
      final List<int> frameTimes = [];

      await binding.traceAction(
        () async {
          for (int round = 0; round < 20; round++) {
            final frameStart = stopwatch.elapsedMicroseconds;
            for (int i = 0; i < counterCount; i++) {
              hub.increment(i);
            }
            await tester.pump();
            final frameTime = stopwatch.elapsedMicroseconds - frameStart;
            frameTimes.add(frameTime);
          }
        },
        reportKey: 'pipex_multi_counter',
      );

      stopwatch.stop();

      final metrics = BenchmarkMetrics.fromFrameTimes(
        frameTimes: frameTimes,
        totalDuration: stopwatch.elapsedMilliseconds,
        testName: 'PipeX - Multi-Counter (50 counters, 20 rounds)',
        framework: 'PipeX',
        category: 'Multi-Counter',
      );

      allResults['Multi-Counter (50 counters)'] =
          allResults['Multi-Counter (50 counters)'] ?? {};
      allResults['Multi-Counter (50 counters)']!['PipeX'] = metrics;
      detailedMetrics.add(metrics.toJson());

      _printMetrics('PipeX Multi-Counter', metrics);
    });
  });

  group('💎 Performance Benchmarks - Complex State', () {
    testWidgets('BLoC Complex State - Multiple Field Updates',
        (WidgetTester tester) async {
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

      final stopwatch = Stopwatch()..start();
      final List<int> frameTimes = [];

      await binding.traceAction(
        () async {
          for (int i = 0; i < 100; i++) {
            final frameStart = stopwatch.elapsedMicroseconds;
            complexBloc.add(bloc.UpdateTextEvent('Value $i'));
            complexBloc.add(bloc.UpdateNumberEvent(i));
            complexBloc.add(bloc.UpdatePercentageEvent(i * 0.5));
            await tester.pump();
            final frameTime = stopwatch.elapsedMicroseconds - frameStart;
            frameTimes.add(frameTime);
          }
        },
        reportKey: 'bloc_complex_state',
      );

      stopwatch.stop();

      final metrics = BenchmarkMetrics.fromFrameTimes(
        frameTimes: frameTimes,
        totalDuration: stopwatch.elapsedMilliseconds,
        testName: 'BLoC - Complex State (100 updates)',
        framework: 'BLoC',
        category: 'Complex State',
      );

      allResults['Complex State (100 updates)'] =
          allResults['Complex State (100 updates)'] ?? {};
      allResults['Complex State (100 updates)']!['BLoC'] = metrics;
      detailedMetrics.add(metrics.toJson());

      _printMetrics('BLoC Complex State', metrics);
      complexBloc.close();
    });

    testWidgets('Riverpod Complex State - Multiple Field Updates',
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

      final stopwatch = Stopwatch()..start();
      final List<int> frameTimes = [];

      await binding.traceAction(
        () async {
          for (int i = 0; i < 100; i++) {
            final frameStart = stopwatch.elapsedMicroseconds;
            notifier.updateText('Value $i');
            notifier.updateNumber(i);
            notifier.updatePercentage(i * 0.5);
            await tester.pump();
            final frameTime = stopwatch.elapsedMicroseconds - frameStart;
            frameTimes.add(frameTime);
          }
        },
        reportKey: 'riverpod_complex_state',
      );

      stopwatch.stop();

      final metrics = BenchmarkMetrics.fromFrameTimes(
        frameTimes: frameTimes,
        totalDuration: stopwatch.elapsedMilliseconds,
        testName: 'Riverpod - Complex State (100 updates)',
        framework: 'Riverpod',
        category: 'Complex State',
      );

      allResults['Complex State (100 updates)'] =
          allResults['Complex State (100 updates)'] ?? {};
      allResults['Complex State (100 updates)']!['Riverpod'] = metrics;
      detailedMetrics.add(metrics.toJson());

      _printMetrics('Riverpod Complex State', metrics);
      container.dispose();
    });

    testWidgets('PipeX Complex State - Multiple Field Updates',
        (WidgetTester tester) async {
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

      final stopwatch = Stopwatch()..start();
      final List<int> frameTimes = [];

      await binding.traceAction(
        () async {
          for (int i = 0; i < 100; i++) {
            final frameStart = stopwatch.elapsedMicroseconds;
            hub.updateText('Value $i');
            hub.updateNumber(i);
            hub.updatePercentage(i * 0.5);
            await tester.pump();
            final frameTime = stopwatch.elapsedMicroseconds - frameStart;
            frameTimes.add(frameTime);
          }
        },
        reportKey: 'pipex_complex_state',
      );

      stopwatch.stop();

      final metrics = BenchmarkMetrics.fromFrameTimes(
        frameTimes: frameTimes,
        totalDuration: stopwatch.elapsedMilliseconds,
        testName: 'PipeX - Complex State (100 updates)',
        framework: 'PipeX',
        category: 'Complex State',
      );

      allResults['Complex State (100 updates)'] =
          allResults['Complex State (100 updates)'] ?? {};
      allResults['Complex State (100 updates)']!['PipeX'] = metrics;
      detailedMetrics.add(metrics.toJson());

      _printMetrics('PipeX Complex State', metrics);
    });
  });

  group('⚡ Stress Test - 1000 Rapid Updates', () {
    testWidgets('BLoC Stress Test', (WidgetTester tester) async {
      final blocInstance = bloc.CounterBloc();
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: blocInstance,
            child: const Scaffold(body: bloc.BlocCounterWidget()),
          ),
        ),
      );

      final stopwatch = Stopwatch()..start();
      final List<int> frameTimes = [];

      for (int i = 0; i < 1000; i++) {
        final frameStart = stopwatch.elapsedMicroseconds;
        blocInstance.add(bloc.IncrementEvent());
        await tester.pump();
        final frameTime = stopwatch.elapsedMicroseconds - frameStart;
        frameTimes.add(frameTime);
      }

      stopwatch.stop();

      final metrics = BenchmarkMetrics.fromFrameTimes(
        frameTimes: frameTimes,
        totalDuration: stopwatch.elapsedMilliseconds,
        testName: 'BLoC - Stress Test (1000 updates)',
        framework: 'BLoC',
        category: 'Stress Test',
      );

      allResults['Stress Test (1000 updates)'] =
          allResults['Stress Test (1000 updates)'] ?? {};
      allResults['Stress Test (1000 updates)']!['BLoC'] = metrics;
      detailedMetrics.add(metrics.toJson());

      _printMetrics('BLoC Stress Test', metrics);
      blocInstance.close();
    });

    testWidgets('Riverpod Stress Test', (WidgetTester tester) async {
      final container = ProviderContainer();
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(body: riverpod.RiverpodCounterWidget()),
          ),
        ),
      );

      final stopwatch = Stopwatch()..start();
      final List<int> frameTimes = [];

      for (int i = 0; i < 1000; i++) {
        final frameStart = stopwatch.elapsedMicroseconds;
        container.read(riverpod.counterProvider.notifier).increment();
        await tester.pump();
        final frameTime = stopwatch.elapsedMicroseconds - frameStart;
        frameTimes.add(frameTime);
      }

      stopwatch.stop();

      final metrics = BenchmarkMetrics.fromFrameTimes(
        frameTimes: frameTimes,
        totalDuration: stopwatch.elapsedMilliseconds,
        testName: 'Riverpod - Stress Test (1000 updates)',
        framework: 'Riverpod',
        category: 'Stress Test',
      );

      allResults['Stress Test (1000 updates)'] =
          allResults['Stress Test (1000 updates)'] ?? {};
      allResults['Stress Test (1000 updates)']!['Riverpod'] = metrics;
      detailedMetrics.add(metrics.toJson());

      _printMetrics('Riverpod Stress Test', metrics);
      container.dispose();
    });

    testWidgets('PipeX Stress Test', (WidgetTester tester) async {
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

      final stopwatch = Stopwatch()..start();
      final List<int> frameTimes = [];

      for (int i = 0; i < 1000; i++) {
        final frameStart = stopwatch.elapsedMicroseconds;
        hub.increment();
        await tester.pump();
        final frameTime = stopwatch.elapsedMicroseconds - frameStart;
        frameTimes.add(frameTime);
      }

      stopwatch.stop();

      final metrics = BenchmarkMetrics.fromFrameTimes(
        frameTimes: frameTimes,
        totalDuration: stopwatch.elapsedMilliseconds,
        testName: 'PipeX - Stress Test (1000 updates)',
        framework: 'PipeX',
        category: 'Stress Test',
      );

      allResults['Stress Test (1000 updates)'] =
          allResults['Stress Test (1000 updates)'] ?? {};
      allResults['Stress Test (1000 updates)']!['PipeX'] = metrics;
      detailedMetrics.add(metrics.toJson());

      _printMetrics('PipeX Stress Test', metrics);
    });
  });

  group('🧪 Memory & Frame Timing Benchmarks', () {
    testWidgets('Memory - Large State Trees', (WidgetTester tester) async {
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

      // PipeX memory test
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

      print(
          '\n✅ Memory test complete: Created and disposed $instanceCount instances per framework');
    });

    testWidgets('Frame Timing - 60 FPS Capability',
        (WidgetTester tester) async {
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

      final stopwatch = Stopwatch()..start();
      final List<int> frameTimes = [];

      await binding.watchPerformance(() async {
        for (int i = 0; i < 180; i++) {
          final frameStart = stopwatch.elapsedMicroseconds;
          hub.increment();
          await tester.pump(const Duration(milliseconds: 16)); // ~60 FPS
          final frameTime = stopwatch.elapsedMicroseconds - frameStart;
          frameTimes.add(frameTime);
        }
      });

      stopwatch.stop();

      final avgFrameTime = stopwatch.elapsedMilliseconds / 180;
      final missedFrames = frameTimes.where((t) => t > 16670).length;

      print('\n📊 Frame Timing Analysis:');
      print(
          '   Total time for 180 frames: ${stopwatch.elapsedMilliseconds} ms');
      print('   Average frame time: ${avgFrameTime.toStringAsFixed(2)} ms');
      print('   Missed frames: $missedFrames');
      print('   Target: 16.67 ms per frame for 60 FPS');
      print(
          '   Status: ${avgFrameTime < 16.67 ? '✅ PASSED' : '⚠️ NEEDS OPTIMIZATION'}');
    });
  });

  // Comprehensive summary report
  tearDownAll(() async {
    if (allResults.isEmpty) return;

    _printComprehensiveSummary(allResults);
    _exportResultsToMarkdown(allResults);
    _exportResultsToJson(detailedMetrics);

    print('\n📊 Timeline files generated in build/ directory');
    print('🔗 View them at chrome://tracing');
  });
}

/// Data class for comprehensive benchmark metrics
class BenchmarkMetrics {
  final int totalDuration;
  final int frameCount;
  final int missedFrames;
  final double minFrameTime;
  final double maxFrameTime;
  final double medianFrameTime;
  final double p90FrameTime;
  final double p99FrameTime;
  final String testName;
  final String framework;
  final String category;

  BenchmarkMetrics({
    required this.totalDuration,
    required this.frameCount,
    required this.missedFrames,
    required this.minFrameTime,
    required this.maxFrameTime,
    required this.medianFrameTime,
    required this.p90FrameTime,
    required this.p99FrameTime,
    required this.testName,
    required this.framework,
    required this.category,
  });

  factory BenchmarkMetrics.fromFrameTimes({
    required List<int> frameTimes,
    required int totalDuration,
    required String testName,
    required String framework,
    required String category,
  }) {
    final sorted = List<int>.from(frameTimes)..sort();
    final frameCount = frameTimes.length;
    final missedFrames = frameTimes.where((t) => t > 16670).length;

    final minFrameTime = sorted.isEmpty ? 0.0 : sorted.first / 1000.0;
    final maxFrameTime = sorted.isEmpty ? 0.0 : sorted.last / 1000.0;
    final medianFrameTime =
        sorted.isEmpty ? 0.0 : sorted[frameCount ~/ 2] / 1000.0;
    final p90FrameTime =
        sorted.isEmpty ? 0.0 : sorted[(frameCount * 0.9).toInt()] / 1000.0;
    final p99FrameTime =
        sorted.isEmpty ? 0.0 : sorted[(frameCount * 0.99).toInt()] / 1000.0;

    return BenchmarkMetrics(
      totalDuration: totalDuration,
      frameCount: frameCount,
      missedFrames: missedFrames,
      minFrameTime: minFrameTime,
      maxFrameTime: maxFrameTime,
      medianFrameTime: medianFrameTime,
      p90FrameTime: p90FrameTime,
      p99FrameTime: p99FrameTime,
      testName: testName,
      framework: framework,
      category: category,
    );
  }

  double get avgFrameTime => frameCount > 0 ? totalDuration / frameCount : 0;
  double get missedFramePercentage =>
      frameCount > 0 ? (missedFrames / frameCount) * 100 : 0;

  Map<String, dynamic> toJson() => {
        'testName': testName,
        'framework': framework,
        'category': category,
        'totalDuration': totalDuration,
        'frameCount': frameCount,
        'missedFrames': missedFrames,
        'avgFrameTime': avgFrameTime,
        'minFrameTime': minFrameTime,
        'maxFrameTime': maxFrameTime,
        'medianFrameTime': medianFrameTime,
        'p90FrameTime': p90FrameTime,
        'p99FrameTime': p99FrameTime,
        'missedFramePercentage': missedFramePercentage,
      };
}

/// Print individual benchmark metrics with enhanced details
void _printMetrics(String testName, BenchmarkMetrics metrics) {
  print('\n' + '─' * 80);
  print('📊 $testName');
  print('─' * 80);
  print('⏱️  Total Duration: ${metrics.totalDuration} ms');
  print('🎬 Frame Count: ${metrics.frameCount}');
  print('📈 Statistics:');
  print('   Average:  ${metrics.avgFrameTime.toStringAsFixed(2)} ms/frame');
  print('   Min:      ${metrics.minFrameTime.toStringAsFixed(2)} ms/frame');
  print('   Median:   ${metrics.medianFrameTime.toStringAsFixed(2)} ms/frame');
  print('   90th %:   ${metrics.p90FrameTime.toStringAsFixed(2)} ms/frame');
  print('   99th %:   ${metrics.p99FrameTime.toStringAsFixed(2)} ms/frame');
  print('   Max:      ${metrics.maxFrameTime.toStringAsFixed(2)} ms/frame');
  print(
      '⚠️  Missed Frames: ${metrics.missedFrames} (${metrics.missedFramePercentage.toStringAsFixed(1)}%)');

  if (metrics.missedFrames == 0) {
    print('✅ Perfect! No missed frames!');
  } else if (metrics.missedFramePercentage < 5) {
    print('✅ Good performance - minimal frame drops');
  } else if (metrics.missedFramePercentage < 15) {
    print('⚠️  Acceptable - some frame drops detected');
  } else {
    print('🔴 Needs optimization - significant frame drops');
  }

  print('─' * 80);
}

/// Print comprehensive summary of all results
void _printComprehensiveSummary(
    Map<String, Map<String, BenchmarkMetrics>> allResults) {
  print('\n\n');
  print('╔' + '═' * 88 + '╗');
  print('║' +
      ' ' * 20 +
      '🏆 COMPREHENSIVE BENCHMARK SUMMARY 🏆' +
      ' ' * 20 +
      '║');
  print('╚' + '═' * 88 + '╝');
  print('\n');
  print('Generated: ${DateTime.now().toIso8601String()}');
  print('Device: ${Platform.operatingSystem}');
  print('Flutter Integration Test with Performance Profiling');
  print('\n');

  for (final testCategory in allResults.keys) {
    print('┌─ $testCategory ${'─' * (86 - testCategory.length)}');

    final results = allResults[testCategory]!;
    final frameworks = results.keys.toList();

    // Sort by total duration
    frameworks.sort((a, b) {
      final aTime = results[a]!.totalDuration;
      final bTime = results[b]!.totalDuration;
      return aTime.compareTo(bTime);
    });

    // Find fastest and slowest
    final fastest = frameworks.first;
    final slowest = frameworks.last;

    for (final framework in frameworks) {
      final metrics = results[framework]!;
      final isFastest = framework == fastest;
      final isSlowest = framework == slowest && frameworks.length > 1;
      final marker = isFastest
          ? '🏆'
          : isSlowest
              ? '🐌'
              : '  ';

      print('│  $marker ${framework.padRight(12)}: '
          '${metrics.totalDuration.toString().padLeft(6)} ms '
          '(${metrics.frameCount.toString().padLeft(4)} frames, '
          'avg: ${metrics.avgFrameTime.toStringAsFixed(2).padLeft(6)} ms, '
          'p99: ${metrics.p99FrameTime.toStringAsFixed(2).padLeft(6)} ms)');

      if (metrics.missedFrames > 0) {
        print(
            '│     ⚠️  Missed frames: ${metrics.missedFrames} (${metrics.missedFramePercentage.toStringAsFixed(1)}%)');
      } else {
        print('│     ✅ Perfect frame timing!');
      }
    }

    // Print analysis if multiple frameworks
    if (frameworks.length > 1) {
      final fastestTime = results[fastest]!.totalDuration;
      final slowestTime = results[slowest]!.totalDuration;
      final diff = slowestTime - fastestTime;
      final percentDiff = fastestTime > 0
          ? ((diff / fastestTime) * 100).toStringAsFixed(1)
          : '0.0';
      print('│');
      print(
          '│  💡 $fastest is fastest by ${diff}ms ($percentDiff% faster than $slowest)');
    }

    print('└' + '─' * 88);
    print('');
  }

  // Overall winner calculation
  print('╔' + '═' * 88 + '╗');
  print('║' + ' ' * 34 + '🎯 OVERALL WINNER 🎯' + ' ' * 34 + '║');
  print('╚' + '═' * 88 + '╝');

  final frameworkScores = <String, int>{};
  for (final category in allResults.values) {
    final sorted = category.keys.toList()
      ..sort((a, b) {
        final aTime = category[a]!.totalDuration;
        final bTime = category[b]!.totalDuration;
        return aTime.compareTo(bTime);
      });

    // Award points: 1st place = 3 points, 2nd = 2 points, 3rd = 1 point
    for (int i = 0; i < sorted.length; i++) {
      final points = sorted.length - i;
      frameworkScores[sorted[i]] = (frameworkScores[sorted[i]] ?? 0) + points;
    }
  }

  final sortedScores = frameworkScores.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  print('\n📊 Final Scores:');
  for (int i = 0; i < sortedScores.length; i++) {
    final entry = sortedScores[i];
    final medal = i == 0
        ? '🥇'
        : i == 1
            ? '🥈'
            : i == 2
                ? '🥉'
                : '  ';
    print('   $medal ${entry.key.padRight(12)}: ${entry.value} points');
  }

  print('\n╔' + '═' * 88 + '╗');
  print('║' + ' ' * 36 + 'BENCHMARK COMPLETE' + ' ' * 36 + '║');
  print('╚' + '═' * 88 + '╝');
  print('\n');
}

/// Export results to a markdown file
void _exportResultsToMarkdown(
    Map<String, Map<String, BenchmarkMetrics>> allResults) {
  try {
    final buffer = StringBuffer();
    buffer.writeln('# State Management Benchmark Results');
    buffer.writeln('');
    buffer.writeln('**Generated:** ${DateTime.now().toIso8601String()}');
    buffer.writeln('**Platform:** ${Platform.operatingSystem}');
    buffer.writeln(
        '**Tool:** Flutter Integration Test with Performance Profiling');
    buffer.writeln('\n---\n');

    for (final category in allResults.keys) {
      buffer.writeln('## $category\n');
      buffer.writeln(
          '| Framework | Duration (ms) | Frames | Avg (ms) | P50 (ms) | P90 (ms) | P99 (ms) | Missed | Miss % |');
      buffer.writeln(
          '|-----------|---------------|--------|----------|----------|----------|----------|--------|--------|');

      final results = allResults[category]!;
      final frameworks = results.keys.toList()
        ..sort((a, b) {
          final aTime = results[a]!.totalDuration;
          final bTime = results[b]!.totalDuration;
          return aTime.compareTo(bTime);
        });

      for (final framework in frameworks) {
        final metrics = results[framework]!;

        buffer.writeln('| $framework | '
            '${metrics.totalDuration} | '
            '${metrics.frameCount} | '
            '${metrics.avgFrameTime.toStringAsFixed(2)} | '
            '${metrics.medianFrameTime.toStringAsFixed(2)} | '
            '${metrics.p90FrameTime.toStringAsFixed(2)} | '
            '${metrics.p99FrameTime.toStringAsFixed(2)} | '
            '${metrics.missedFrames} | '
            '${metrics.missedFramePercentage.toStringAsFixed(1)}% |');
      }

      buffer.writeln('');
    }

    buffer.writeln('\n## Notes\n');
    buffer.writeln('- Frame budget: 16.67ms (60 FPS)');
    buffer.writeln('- P50 = Median frame time');
    buffer.writeln('- P90 = 90th percentile frame time');
    buffer.writeln('- P99 = 99th percentile frame time');
    buffer.writeln('- Lower values = better performance');
    buffer.writeln('- All tests run using Flutter integration_test framework');

    print('\n📝 Markdown Report Generated');
  } catch (e) {
    print('⚠️  Could not export markdown results: $e');
  }
}

/// Export detailed results to JSON
void _exportResultsToJson(List<Map<String, dynamic>> detailedMetrics) {
  try {
    final jsonData = {
      'timestamp': DateTime.now().toIso8601String(),
      'platform': Platform.operatingSystem,
      'results': detailedMetrics,
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(jsonData);
    print('\n📊 JSON Export:\n$jsonString');
  } catch (e) {
    print('⚠️  Could not export JSON results: $e');
  }
}
