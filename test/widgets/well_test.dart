import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pipe_x/pipe_x.dart';

void main() {
  group('Well', () {
    testWidgets('should build with multiple pipes', (tester) async {
      final pipe1 = Pipe<int>(1);
      final pipe2 = Pipe<int>(2);

      await tester.pumpWidget(
        MaterialApp(
          home: Well(
            pipes: [pipe1, pipe2],
            builder: (context) => Text(
                '${pipe1.value} + ${pipe2.value} = ${pipe1.value + pipe2.value}'),
          ),
        ),
      );

      expect(find.text('1 + 2 = 3'), findsOneWidget);

      pipe1.dispose();
      pipe2.dispose();
    });

    testWidgets('should rebuild when any pipe changes', (tester) async {
      final pipe1 = Pipe<int>(0);
      final pipe2 = Pipe<int>(0);

      await tester.pumpWidget(
        MaterialApp(
          home: Well(
            pipes: [pipe1, pipe2],
            builder: (context) => Text('Sum: ${pipe1.value + pipe2.value}'),
          ),
        ),
      );

      expect(find.text('Sum: 0'), findsOneWidget);

      // Update first pipe
      pipe1.value = 5;
      await tester.pump();
      expect(find.text('Sum: 5'), findsOneWidget);

      // Update second pipe
      pipe2.value = 3;
      await tester.pump();
      expect(find.text('Sum: 8'), findsOneWidget);

      pipe1.dispose();
      pipe2.dispose();
    });

    testWidgets('should track subscriber count for all pipes', (tester) async {
      final pipe1 = Pipe<int>(0);
      final pipe2 = Pipe<int>(0);
      final pipe3 = Pipe<int>(0);

      await tester.pumpWidget(
        MaterialApp(
          home: Well(
            pipes: [pipe1, pipe2, pipe3],
            builder: (context) => const Text('test'),
          ),
        ),
      );

      expect(pipe1.subscriberCount, 1);
      expect(pipe2.subscriberCount, 1);
      expect(pipe3.subscriberCount, 1);

      await tester.pumpWidget(const SizedBox());

      expect(pipe1.subscriberCount, 0);
      expect(pipe2.subscriberCount, 0);
      expect(pipe3.subscriberCount, 0);

      pipe1.dispose();
      pipe2.dispose();
      pipe3.dispose();
    });

    testWidgets('should handle pipe list changes', (tester) async {
      final pipe1 = Pipe<int>(1);
      final pipe2 = Pipe<int>(2);
      final pipe3 = Pipe<int>(3);

      Widget buildWidget(List<Pipe> pipes, String key) {
        return MaterialApp(
          home: Well(
            key: ValueKey(key),
            pipes: pipes,
            builder: (context) {
              final sum = pipes.fold<int>(
                  0, (sum, pipe) => sum + (pipe as Pipe<int>).value);
              return Text('Sum: $sum');
            },
          ),
        );
      }

      // Initial with 2 pipes
      await tester.pumpWidget(buildWidget([pipe1, pipe2], 'two'));
      expect(find.text('Sum: 3'), findsOneWidget);
      expect(pipe1.subscriberCount, 1);
      expect(pipe2.subscriberCount, 1);
      expect(pipe3.subscriberCount, 0);

      // Add third pipe
      await tester.pumpWidget(buildWidget([pipe1, pipe2, pipe3], 'three'));
      await tester.pumpAndSettle();
      expect(find.text('Sum: 6'), findsOneWidget);
      expect(pipe3.subscriberCount, 1);

      // Remove first pipe
      await tester.pumpWidget(buildWidget([pipe2, pipe3], 'two-removed'));
      await tester.pumpAndSettle();
      expect(find.text('Sum: 5'), findsOneWidget);
      expect(pipe1.subscriberCount, 0);

      pipe1.dispose();
      pipe2.dispose();
      pipe3.dispose();
    });

    testWidgets('should work with different types', (tester) async {
      final intPipe = Pipe<int>(42);
      final stringPipe = Pipe<String>('hello');
      final boolPipe = Pipe<bool>(true);

      await tester.pumpWidget(
        MaterialApp(
          home: Well(
            pipes: [intPipe, stringPipe, boolPipe],
            builder: (context) =>
                Text('${intPipe.value} ${stringPipe.value} ${boolPipe.value}'),
          ),
        ),
      );

      expect(find.text('42 hello true'), findsOneWidget);

      stringPipe.value = 'world';
      await tester.pump();

      expect(find.text('42 world true'), findsOneWidget);

      intPipe.dispose();
      stringPipe.dispose();
      boolPipe.dispose();
    });

    testWidgets('should throw assertion error with empty pipe list',
        (tester) async {
      expect(
        () => Well(
          pipes: const [],
          builder: (context) => const Text('empty'),
        ),
        throwsAssertionError,
      );
    });

    testWidgets('should provide context to builder', (tester) async {
      final pipe = Pipe<int>(0);
      BuildContext? capturedContext;

      await tester.pumpWidget(
        MaterialApp(
          home: Well(
            pipes: [pipe],
            builder: (context) {
              capturedContext = context;
              return const Text('test');
            },
          ),
        ),
      );

      expect(capturedContext, isNotNull);
      expect(capturedContext, isA<BuildContext>());
      pipe.dispose();
    });

    testWidgets(
        'should rebuild only once when multiple pipes change simultaneously',
        (tester) async {
      final pipe1 = Pipe<int>(0);
      final pipe2 = Pipe<int>(0);
      var buildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Well(
            pipes: [pipe1, pipe2],
            builder: (context) {
              buildCount++;
              return Text('${pipe1.value} ${pipe2.value}');
            },
          ),
        ),
      );

      expect(buildCount, 1);

      // Change both pipes before pump
      pipe1.value = 1;
      pipe2.value = 2;
      await tester.pump();

      // Should rebuild once for both changes
      expect(buildCount, 2);

      pipe1.dispose();
      pipe2.dispose();
    });

    testWidgets('should work with computed values', (tester) async {
      final pipe1 = Pipe<int>(5);
      final pipe2 = Pipe<int>(10);

      await tester.pumpWidget(
        MaterialApp(
          home: Well(
            pipes: [pipe1, pipe2],
            builder: (context) {
              final sum = pipe1.value + pipe2.value;
              final product = pipe1.value * pipe2.value;
              return Text('Sum: $sum, Product: $product');
            },
          ),
        ),
      );

      expect(find.text('Sum: 15, Product: 50'), findsOneWidget);

      pipe1.value = 3;
      await tester.pump();

      expect(find.text('Sum: 13, Product: 30'), findsOneWidget);

      pipe1.dispose();
      pipe2.dispose();
    });

    testWidgets('should handle complex widget trees', (tester) async {
      final pipe1 = Pipe<String>('A');
      final pipe2 = Pipe<String>('B');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Well(
              pipes: [pipe1, pipe2],
              builder: (context) => Column(
                children: [
                  Text('First: ${pipe1.value}'),
                  Text('Second: ${pipe2.value}'),
                  Text('Combined: ${pipe1.value}${pipe2.value}'),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('First: A'), findsOneWidget);
      expect(find.text('Second: B'), findsOneWidget);
      expect(find.text('Combined: AB'), findsOneWidget);

      pipe1.value = 'X';
      pipe2.value = 'Y';
      await tester.pump();

      expect(find.text('First: X'), findsOneWidget);
      expect(find.text('Second: Y'), findsOneWidget);
      expect(find.text('Combined: XY'), findsOneWidget);

      pipe1.dispose();
      pipe2.dispose();
    });
  });
}
