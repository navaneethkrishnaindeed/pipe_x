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

class FlagHub extends Hub {
  late final Pipe<bool> flag;

  FlagHub() {
    flag = Pipe(false);
  }
}

void main() {
  group('MultiHubProvider', () {
    testWidgets('should provide multiple hubs with factories', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MultiHubProvider(
            hubs: [
              () => CounterHub(),
              () => NameHub(),
              () => FlagHub(),
            ],
            child: Builder(
              builder: (context) {
                final counterHub = HubProvider.of<CounterHub>(context);
                final nameHub = HubProvider.of<NameHub>(context);
                final flagHub = HubProvider.of<FlagHub>(context);
                return Text(
                    '${counterHub.count.value} ${nameHub.name.value} ${flagHub.flag.value}');
              },
            ),
          ),
        ),
      );

      expect(find.text('0 test false'), findsOneWidget);
    });

    testWidgets('should provide hubs using instances', (tester) async {
      final counterHub = CounterHub();
      final nameHub = NameHub();
      counterHub.completeConstruction();
      nameHub.completeConstruction();

      await tester.pumpWidget(
        MaterialApp(
          home: MultiHubProvider(
            hubs: [counterHub, nameHub],
            child: Builder(
              builder: (context) {
                final counter = HubProvider.of<CounterHub>(context);
                final name = HubProvider.of<NameHub>(context);
                return Text('${counter.count.value} ${name.name.value}');
              },
            ),
          ),
        ),
      );

      expect(find.text('0 test'), findsOneWidget);

      // Remove provider
      await tester.pumpWidget(const SizedBox());

      // Hubs should NOT be disposed
      expect(counterHub.disposed, false);
      expect(nameHub.disposed, false);

      counterHub.dispose();
      nameHub.dispose();
    });

    testWidgets('should mix factories and instances', (tester) async {
      final existingHub = CounterHub();
      existingHub.completeConstruction();

      await tester.pumpWidget(
        MaterialApp(
          home: MultiHubProvider(
            hubs: [
              existingHub,
              () => NameHub(),
            ],
            child: Builder(
              builder: (context) {
                final counter = HubProvider.of<CounterHub>(context);
                final name = HubProvider.of<NameHub>(context);
                return Text('${counter.count.value} ${name.name.value}');
              },
            ),
          ),
        ),
      );

      expect(find.text('0 test'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());

      // Existing hub should not be disposed
      expect(existingHub.disposed, false);

      existingHub.dispose();
    });

    testWidgets('should dispose hubs created by factories', (tester) async {
      CounterHub? counterHub;
      NameHub? nameHub;

      await tester.pumpWidget(
        MaterialApp(
          home: MultiHubProvider(
            hubs: [
              () {
                counterHub = CounterHub();
                return counterHub!;
              },
              () {
                nameHub = NameHub();
                return nameHub!;
              },
            ],
            child: const Text('test'),
          ),
        ),
      );

      expect(counterHub, isNotNull);
      expect(nameHub, isNotNull);
      expect(counterHub!.disposed, false);
      expect(nameHub!.disposed, false);

      // Remove provider
      await tester.pumpWidget(const SizedBox());

      expect(counterHub!.disposed, true);
      expect(nameHub!.disposed, true);
    });

    testWidgets('should NOT dispose hubs provided as instances',
        (tester) async {
      final counterHub = CounterHub();
      final nameHub = NameHub();
      counterHub.completeConstruction();
      nameHub.completeConstruction();

      await tester.pumpWidget(
        MaterialApp(
          home: MultiHubProvider(
            hubs: [counterHub, nameHub],
            child: const Text('test'),
          ),
        ),
      );

      // Remove provider
      await tester.pumpWidget(const SizedBox());

      expect(counterHub.disposed, false);
      expect(nameHub.disposed, false);

      counterHub.dispose();
      nameHub.dispose();
    });

    testWidgets('should work with empty list', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MultiHubProvider(
            hubs: [],
            child: Text('test'),
          ),
        ),
      );

      expect(find.text('test'), findsOneWidget);
    });

    testWidgets('should work with single hub', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MultiHubProvider(
            hubs: [() => CounterHub()],
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

    testWidgets('should provide hubs in correct order', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MultiHubProvider(
            hubs: [
              () => CounterHub(),
              () => NameHub(),
              () => FlagHub(),
            ],
            child: Builder(
              builder: (context) {
                // Should be able to access all in any order
                final flag = HubProvider.of<FlagHub>(context);
                final counter = HubProvider.of<CounterHub>(context);
                final name = HubProvider.of<NameHub>(context);
                return Text(
                    '${counter.count.value} ${name.name.value} ${flag.flag.value}');
              },
            ),
          ),
        ),
      );

      expect(find.text('0 test false'), findsOneWidget);
    });

    testWidgets('should throw error for invalid type', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MultiHubProvider(
            hubs: [
              'invalid', // Not a Hub or factory
            ],
            child: const Text('test'),
          ),
        ),
      );

      expect(tester.takeException(), isA<FlutterError>());
    });

    testWidgets('should throw error if disposed hub is provided',
        (tester) async {
      final hub = CounterHub();
      hub.completeConstruction();
      hub.dispose();

      await tester.pumpWidget(
        MaterialApp(
          home: MultiHubProvider(
            hubs: [hub],
            child: const Text('test'),
          ),
        ),
      );

      expect(tester.takeException(), isA<FlutterError>());
    });

    testWidgets('should throw error if factory returns disposed hub',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MultiHubProvider(
            hubs: [
              () {
                final hub = CounterHub();
                hub.completeConstruction();
                hub.dispose();
                return hub;
              },
            ],
            child: const Text('test'),
          ),
        ),
      );

      expect(tester.takeException(), isA<FlutterError>());
    });

    testWidgets('should work with complex widget tree', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MultiHubProvider(
            hubs: [
              () => CounterHub(),
              () => NameHub(),
            ],
            child: Builder(
              builder: (context) {
                final counterHub = HubProvider.read<CounterHub>(context);
                final nameHub = HubProvider.read<NameHub>(context);
                return Column(
                  children: [
                    Sink<int>(
                      pipe: counterHub.count,
                      builder: (context, value) => Text('Count: $value'),
                    ),
                    Sink<String>(
                      pipe: nameHub.name,
                      builder: (context, value) => Text('Name: $value'),
                    ),
                    ElevatedButton(
                      onPressed: counterHub.increment,
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
      expect(find.text('Name: test'), findsOneWidget);

      await tester.tap(find.text('Increment'));
      await tester.pump();

      expect(find.text('Count: 1'), findsOneWidget);
    });

    testWidgets('should be equivalent to nested HubProviders', (tester) async {
      // Using MultiHubProvider
      await tester.pumpWidget(
        MaterialApp(
          home: MultiHubProvider(
            hubs: [
              () => CounterHub(),
              () => NameHub(),
            ],
            child: Builder(
              builder: (context) {
                final counter = HubProvider.of<CounterHub>(context);
                final name = HubProvider.of<NameHub>(context);
                return Text('${counter.count.value} ${name.name.value}');
              },
            ),
          ),
        ),
      );

      expect(find.text('0 test'), findsOneWidget);

      // Using nested HubProviders
      await tester.pumpWidget(
        MaterialApp(
          home: HubProvider<CounterHub>(
            create: () => CounterHub(),
            child: HubProvider<NameHub>(
              create: () => NameHub(),
              child: Builder(
                builder: (context) {
                  final counter = HubProvider.of<CounterHub>(context);
                  final name = HubProvider.of<NameHub>(context);
                  return Text('${counter.count.value} ${name.name.value}');
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('0 test'), findsOneWidget);
    });
  });
}
