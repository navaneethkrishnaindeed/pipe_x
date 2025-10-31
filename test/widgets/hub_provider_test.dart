import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pipe_x/pipe_x.dart';

class CounterHub extends Hub {
  late final count = pipe(0);

  void increment() {
    count.value++;
  }
}

class NameHub extends Hub {
  late final name = pipe('test');

  void setName(String newName) {
    name.value = newName;
  }
}

void main() {
  group('HubProvider', () {
    testWidgets('should provide hub to descendants using create',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HubProvider<CounterHub>(
            create: () => CounterHub(),
            child: Builder(
              builder: (context) {
                final hub = HubProvider.of<CounterHub>(context);
                return Text('${hub.count.value}');
              },
            ),
          ),
        ),
      );

      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('should provide hub using value constructor', (tester) async {
      final hub = CounterHub();

      await tester.pumpWidget(
        MaterialApp(
          home: HubProvider<CounterHub>.value(
            value: hub,
            child: Builder(
              builder: (context) {
                final providedHub = HubProvider.of<CounterHub>(context);
                return Text('${providedHub.count.value}');
              },
            ),
          ),
        ),
      );

      expect(find.text('0'), findsOneWidget);

      // Hub should not be disposed by provider
      await tester.pumpWidget(const SizedBox());
      expect(hub.disposed, false);

      hub.dispose();
    });

    testWidgets('should dispose hub created with create', (tester) async {
      CounterHub? hub;

      await tester.pumpWidget(
        MaterialApp(
          home: HubProvider<CounterHub>(
            create: () {
              hub = CounterHub();
              return hub!;
            },
            child: const Text('test'),
          ),
        ),
      );

      expect(hub, isNotNull);
      expect(hub!.disposed, false);

      // Remove provider
      await tester.pumpWidget(const SizedBox());

      expect(hub!.disposed, true);
    });

    testWidgets('should NOT dispose hub provided with value', (tester) async {
      final hub = CounterHub();

      await tester.pumpWidget(
        MaterialApp(
          home: HubProvider<CounterHub>.value(
            value: hub,
            child: const Text('test'),
          ),
        ),
      );

      expect(hub.disposed, false);

      // Remove provider
      await tester.pumpWidget(const SizedBox());

      // Hub should NOT be disposed
      expect(hub.disposed, false);

      hub.dispose();
    });

    testWidgets('HubProvider.of should create dependency', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HubProvider<CounterHub>(
            create: () => CounterHub(),
            child: Builder(
              builder: (context) {
                final hub = HubProvider.of<CounterHub>(context);
                return Text('${hub.count.value}');
              },
            ),
          ),
        ),
      );

      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('HubProvider.read should work', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HubProvider<CounterHub>(
            create: () => CounterHub(),
            child: Builder(
              builder: (context) {
                final hub = HubProvider.read<CounterHub>(context);
                return Text('${hub.count.value}');
              },
            ),
          ),
        ),
      );

      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('should update when hub methods are called', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HubProvider<CounterHub>(
            create: () => CounterHub(),
            child: Builder(
              builder: (context) {
                final hub = HubProvider.read<CounterHub>(context);
                return Column(
                  children: [
                    Sink<int>(
                      pipe: hub.count,
                      builder: (context, value) => Text('Count: $value'),
                    ),
                    ElevatedButton(
                      onPressed: hub.increment,
                      child: const Text('Increment'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Count: 0'), findsOneWidget);

      await tester.tap(find.text('Increment'));
      await tester.pump();

      expect(find.text('Count: 1'), findsOneWidget);
    });

    testWidgets('should throw when hub not found', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              // No provider in tree
              HubProvider.of<CounterHub>(context);
              return const Text('test');
            },
          ),
        ),
      );

      expect(tester.takeException(), isA<StateError>());
    });

    testWidgets('should support nested providers of different types',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HubProvider<CounterHub>(
            create: () => CounterHub(),
            child: HubProvider<NameHub>(
              create: () => NameHub(),
              child: Builder(
                builder: (context) {
                  final counterHub = HubProvider.of<CounterHub>(context);
                  final nameHub = HubProvider.of<NameHub>(context);
                  return Text(
                      '${counterHub.count.value} ${nameHub.name.value}');
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('0 test'), findsOneWidget);
    });

    testWidgets('should throw error if disposed hub is provided via value',
        (tester) async {
      final hub = CounterHub();
      hub.dispose();

      await tester.pumpWidget(
        MaterialApp(
          home: HubProvider<CounterHub>.value(
            value: hub,
            child: const Text('test'),
          ),
        ),
      );

      expect(tester.takeException(), isA<FlutterError>());
    });

    testWidgets('should throw error if create returns disposed hub',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HubProvider<CounterHub>(
            create: () {
              final hub = CounterHub();
              hub.dispose();
              return hub;
            },
            child: const Text('test'),
          ),
        ),
      );

      expect(tester.takeException(), isA<FlutterError>());
    });

    testWidgets('should work with Sink and Well', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HubProvider<CounterHub>(
            create: () => CounterHub(),
            child: Builder(
              builder: (context) {
                final hub = HubProvider.read<CounterHub>(context);
                return Sink<int>(
                  pipe: hub.count,
                  builder: (context, value) => Text('$value'),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('multiple widgets can access same hub', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HubProvider<CounterHub>(
            create: () => CounterHub(),
            child: Column(
              children: [
                Builder(
                  builder: (context) {
                    final hub = HubProvider.read<CounterHub>(context);
                    return Sink<int>(
                      pipe: hub.count,
                      builder: (context, value) => Text('A: $value'),
                    );
                  },
                ),
                Builder(
                  builder: (context) {
                    final hub = HubProvider.read<CounterHub>(context);
                    return Sink<int>(
                      pipe: hub.count,
                      builder: (context, value) => Text('B: $value'),
                    );
                  },
                ),
                Builder(
                  builder: (context) {
                    final hub = HubProvider.read<CounterHub>(context);
                    return ElevatedButton(
                      onPressed: hub.increment,
                      child: const Text('Increment'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('A: 0'), findsOneWidget);
      expect(find.text('B: 0'), findsOneWidget);

      await tester.tap(find.text('Increment'));
      await tester.pump();

      expect(find.text('A: 1'), findsOneWidget);
      expect(find.text('B: 1'), findsOneWidget);
    });
  });
}
