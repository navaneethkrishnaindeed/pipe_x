import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pipe_x/pipe_x.dart';

class CounterHub extends Hub {
  late final Pipe<int> count;

  CounterHub() {
    count = Pipe(0);
  }

  void increment() {
    count.value++;
  }
}

class NameHub extends Hub {
  late final Pipe<String> name;

  NameHub() {
    name = Pipe('test');
  }
}

void main() {
  group('HubBuildContextExtension', () {
    testWidgets('context.read should work', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HubProvider<CounterHub>(
            create: () => CounterHub(),
            child: Builder(
              builder: (context) {
                final hub = context.read<CounterHub>();
                return Text('${hub.count.value}');
              },
            ),
          ),
        ),
      );

      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('context.read should not create dependency', (tester) async {
      var buildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: HubProvider<CounterHub>(
            create: () => CounterHub(),
            child: Builder(
              builder: (context) {
                buildCount++;
                final hub = context.read<CounterHub>();
                return Text('${hub.count.value}');
              },
            ),
          ),
        ),
      );

      expect(buildCount, 1);
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('context.read should work with multiple hub types',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HubProvider<CounterHub>(
            create: () => CounterHub(),
            child: HubProvider<NameHub>(
              create: () => NameHub(),
              child: Builder(
                builder: (context) {
                  final counterHub = context.read<CounterHub>();
                  final nameHub = context.read<NameHub>();
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

    testWidgets('context.read should work in callbacks', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HubProvider<CounterHub>(
            create: () => CounterHub(),
            child: Builder(
              builder: (context) {
                return Column(
                  children: [
                    Builder(
                      builder: (innerContext) {
                        final hub = context.read<CounterHub>();
                        return Sink<int>(
                          pipe: hub.count,
                          builder: (context, value) => Text('Count: $value'),
                        );
                      },
                    ),
                    ElevatedButton(
                      onPressed: () {
                        context.read<CounterHub>().increment();
                      },
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

    testWidgets('context.read should work with MultiHubProvider',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MultiHubProvider(
            hubs: [
              () => CounterHub(),
              () => NameHub(),
            ],
            child: Builder(
              builder: (context) {
                final counterHub = context.read<CounterHub>();
                final nameHub = context.read<NameHub>();
                return Text('${counterHub.count.value} ${nameHub.name.value}');
              },
            ),
          ),
        ),
      );

      expect(find.text('0 test'), findsOneWidget);
    });

    testWidgets('context.read should throw when hub not found', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              context.read<CounterHub>();
              return const Text('test');
            },
          ),
        ),
      );

      expect(tester.takeException(), isA<StateError>());
    });

    testWidgets('context.read should be equivalent to HubProvider.read',
        (tester) async {
      CounterHub? hub1;
      CounterHub? hub2;

      await tester.pumpWidget(
        MaterialApp(
          home: HubProvider<CounterHub>(
            create: () => CounterHub(),
            child: Builder(
              builder: (context) {
                hub1 = context.read<CounterHub>();
                hub2 = HubProvider.read<CounterHub>(context);
                return const Text('test');
              },
            ),
          ),
        ),
      );

      expect(hub1, isNotNull);
      expect(hub2, isNotNull);
      expect(hub1, equals(hub2)); // Should be the same instance
    });

    testWidgets('context.read should work in deeply nested widgets',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HubProvider<CounterHub>(
            create: () => CounterHub(),
            child: Column(
              children: [
                Row(
                  children: [
                    Builder(
                      builder: (context) {
                        final hub = context.read<CounterHub>();
                        return Text('${hub.count.value}');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('context.read should work with Sink', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HubProvider<CounterHub>(
            create: () => CounterHub(),
            child: Builder(
              builder: (context) {
                final hub = context.read<CounterHub>();
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

    testWidgets('context.read should work with Well', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MultiHubProvider(
            hubs: [
              () => CounterHub(),
              () => NameHub(),
            ],
            child: Builder(
              builder: (context) {
                final counterHub = context.read<CounterHub>();
                final nameHub = context.read<NameHub>();
                return Well(
                  pipes: [counterHub.count, nameHub.name],
                  builder: (context) =>
                      Text('${counterHub.count.value} ${nameHub.name.value}'),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('0 test'), findsOneWidget);
    });

    testWidgets('multiple context.read calls should return same instance',
        (tester) async {
      CounterHub? hub1;
      CounterHub? hub2;
      CounterHub? hub3;

      await tester.pumpWidget(
        MaterialApp(
          home: HubProvider<CounterHub>(
            create: () => CounterHub(),
            child: Builder(
              builder: (context) {
                hub1 = context.read<CounterHub>();
                hub2 = context.read<CounterHub>();
                hub3 = context.read<CounterHub>();
                return const Text('test');
              },
            ),
          ),
        ),
      );

      expect(hub1, equals(hub2));
      expect(hub2, equals(hub3));
      expect(hub1, equals(hub3));
    });
  });
}
