import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pipe_x/pipe_x.dart';

void main() {
  group('Sink', () {
    testWidgets('should build with initial value', (tester) async {
      final pipe = Pipe<int>(0);

      await tester.pumpWidget(
        MaterialApp(
          home: Sink<int>(
            pipe: pipe,
            builder: (context, value) => Text('Count: $value'),
          ),
        ),
      );

      expect(find.text('Count: 0'), findsOneWidget);
      pipe.dispose();
    });

    testWidgets('should rebuild when pipe value changes', (tester) async {
      final pipe = Pipe<int>(0);

      await tester.pumpWidget(
        MaterialApp(
          home: Sink<int>(
            pipe: pipe,
            builder: (context, value) => Text('Count: $value'),
          ),
        ),
      );

      expect(find.text('Count: 0'), findsOneWidget);

      pipe.value = 5;
      await tester.pump();

      expect(find.text('Count: 5'), findsOneWidget);
      expect(find.text('Count: 0'), findsNothing);

      pipe.dispose();
    });

    testWidgets('should rebuild multiple times', (tester) async {
      final pipe = Pipe<int>(0);

      await tester.pumpWidget(
        MaterialApp(
          home: Sink<int>(
            pipe: pipe,
            builder: (context, value) => Text('$value'),
          ),
        ),
      );

      for (var i = 1; i <= 5; i++) {
        pipe.value = i;
        await tester.pump();
        expect(find.text('$i'), findsOneWidget);
      }

      pipe.dispose();
    });

    testWidgets('should not rebuild when value is same', (tester) async {
      final pipe = Pipe<int>(0);
      var buildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Sink<int>(
            pipe: pipe,
            builder: (context, value) {
              buildCount++;
              return Text('$value');
            },
          ),
        ),
      );

      expect(buildCount, 1);

      pipe.value = 0; // Same value
      await tester.pump();

      expect(buildCount, 1); // Should not rebuild

      pipe.dispose();
    });

    testWidgets('should handle pipe changes', (tester) async {
      var pipe1 = Pipe<int>(0, autoDispose: false);
      var pipe2 = Pipe<int>(100, autoDispose: false);

      Widget buildWidget(Pipe<int> pipe) {
        return MaterialApp(
          home: Sink<int>(
            key: ValueKey(pipe),
            pipe: pipe,
            builder: (context, value) => Text('$value'),
          ),
        );
      }

      await tester.pumpWidget(buildWidget(pipe1));
      expect(find.text('0'), findsOneWidget);
      expect(pipe1.subscriberCount, 1);

      // Change to different pipe
      await tester.pumpWidget(buildWidget(pipe2));
      await tester.pumpAndSettle();
      expect(find.text('100'), findsOneWidget);
      expect(pipe1.subscriberCount, 0);
      expect(pipe2.subscriberCount, 1);

      // Update new pipe
      pipe2.value = 200;
      await tester.pump();
      expect(find.text('200'), findsOneWidget);

      pipe1.dispose();
      pipe2.dispose();
    });

    testWidgets('should unsubscribe when disposed', (tester) async {
      final pipe = Pipe<int>(0);

      await tester.pumpWidget(
        MaterialApp(
          home: Sink<int>(
            pipe: pipe,
            builder: (context, value) => Text('$value'),
          ),
        ),
      );

      expect(pipe.subscriberCount, 1);

      await tester.pumpWidget(const SizedBox());

      expect(pipe.subscriberCount, 0);
      pipe.dispose();
    });

    testWidgets('should work with different types', (tester) async {
      final stringPipe = Pipe<String>('hello');

      await tester.pumpWidget(
        MaterialApp(
          home: Sink<String>(
            pipe: stringPipe,
            builder: (context, value) => Text(value),
          ),
        ),
      );

      expect(find.text('hello'), findsOneWidget);

      stringPipe.value = 'world';
      await tester.pump();

      expect(find.text('world'), findsOneWidget);
      stringPipe.dispose();
    });

    testWidgets('should provide context to builder', (tester) async {
      final pipe = Pipe<int>(0);
      BuildContext? capturedContext;

      await tester.pumpWidget(
        MaterialApp(
          home: Sink<int>(
            pipe: pipe,
            builder: (context, value) {
              capturedContext = context;
              return Text('$value');
            },
          ),
        ),
      );

      expect(capturedContext, isNotNull);
      expect(capturedContext, isA<BuildContext>());
      pipe.dispose();
    });

    testWidgets('multiple Sinks can subscribe to same pipe', (tester) async {
      final pipe = Pipe<int>(0);

      await tester.pumpWidget(
        MaterialApp(
          home: Column(
            children: [
              Sink<int>(
                pipe: pipe,
                builder: (context, value) => Text('A: $value'),
              ),
              Sink<int>(
                pipe: pipe,
                builder: (context, value) => Text('B: $value'),
              ),
            ],
          ),
        ),
      );

      expect(find.text('A: 0'), findsOneWidget);
      expect(find.text('B: 0'), findsOneWidget);
      expect(pipe.subscriberCount, 2);

      pipe.value = 5;
      await tester.pump();

      expect(find.text('A: 5'), findsOneWidget);
      expect(find.text('B: 5'), findsOneWidget);

      pipe.dispose();
    });

    testWidgets('should handle complex widget trees', (tester) async {
      final pipe = Pipe<int>(0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Sink<int>(
                pipe: pipe,
                builder: (context, value) => Column(
                  children: [
                    Text('Count: $value'),
                    Text('Double: ${value * 2}'),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Count: 0'), findsOneWidget);
      expect(find.text('Double: 0'), findsOneWidget);

      pipe.value = 3;
      await tester.pump();

      expect(find.text('Count: 3'), findsOneWidget);
      expect(find.text('Double: 6'), findsOneWidget);

      pipe.dispose();
    });

    testWidgets(
        'standalone pipe with autoDispose should auto-dispose when last subscriber unmounts',
        (tester) async {
      // Create a standalone pipe with autoDispose enabled (default)
      final pipe = Pipe<int>(0);
      expect(pipe.autoDispose, true,
          reason:
              'Standalone pipes should have autoDispose enabled by default');
      expect(pipe.disposed, false);

      await tester.pumpWidget(
        MaterialApp(
          home: Sink<int>(
            pipe: pipe,
            builder: (context, value) => Text('$value'),
          ),
        ),
      );

      expect(pipe.subscriberCount, 1);
      expect(pipe.disposed, false);

      // Remove the widget (unmount the subscriber)
      await tester.pumpWidget(const SizedBox());

      // Wait for microtask to complete
      await tester.pumpAndSettle();
      await tester.idle();

      // Check if pipe auto-disposed
      expect(pipe.subscriberCount, 0);
      expect(pipe.disposed, true,
          reason:
              'Standalone pipe with autoDispose should automatically dispose when last subscriber unmounts');
    });

    testWidgets('pipe with autoDispose=false should NOT auto-dispose',
        (tester) async {
      // Create a pipe with autoDispose disabled
      final pipe = Pipe<int>(0, autoDispose: false);
      expect(pipe.autoDispose, false);
      expect(pipe.disposed, false);

      await tester.pumpWidget(
        MaterialApp(
          home: Sink<int>(
            pipe: pipe,
            builder: (context, value) => Text('$value'),
          ),
        ),
      );

      expect(pipe.subscriberCount, 1);

      // Remove the widget
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      await tester.idle();

      // Should NOT be disposed
      expect(pipe.subscriberCount, 0);
      expect(pipe.disposed, false,
          reason:
              'Pipe with autoDispose=false should not automatically dispose');

      // Manual cleanup
      pipe.dispose();
    });

    testWidgets('standalone pipe should NOT auto-dispose if it has listeners',
        (tester) async {
      // Create a standalone pipe with autoDispose enabled
      final pipe = Pipe<int>(0);
      expect(pipe.autoDispose, true);

      // Add a listener
      void listener() {}
      pipe.addListener(listener);

      await tester.pumpWidget(
        MaterialApp(
          home: Sink<int>(
            pipe: pipe,
            builder: (context, value) => Text('$value'),
          ),
        ),
      );

      expect(pipe.subscriberCount, 1);

      // Remove the widget (subscriber unmounts)
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      await tester.idle();

      // Should NOT be disposed because listener still exists
      expect(pipe.subscriberCount, 0);
      expect(pipe.disposed, false,
          reason: 'Pipe should not auto-dispose if listeners still exist');

      // Remove listener and it should auto-dispose on next detach
      // But there are no more subscribers, so we need to manually dispose
      pipe.removeListener(listener);
      pipe.dispose();
    });

    testWidgets(
        'standalone pipe should auto-dispose when both subscribers and listeners are removed',
        (tester) async {
      // Create a standalone pipe
      final pipe = Pipe<int>(0);
      int listenerCallCount = 0;

      void listener() {
        listenerCallCount++;
      }

      pipe.addListener(listener);

      await tester.pumpWidget(
        MaterialApp(
          home: Sink<int>(
            pipe: pipe,
            builder: (context, value) => Text('$value'),
          ),
        ),
      );

      expect(pipe.subscriberCount, 1);

      // Update value to trigger listener
      pipe.value = 5;
      await tester.pump();
      expect(listenerCallCount, 1);

      // Remove listener first
      pipe.removeListener(listener);

      // Now remove the widget (subscriber unmounts)
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      await tester.idle();

      // Should auto-dispose now that both subscribers and listeners are empty
      expect(pipe.subscriberCount, 0);
      expect(pipe.disposed, true,
          reason:
              'Pipe should auto-dispose when both subscribers and listeners are empty');
    });

    testWidgets(
        'comprehensive auto-dispose test: subscribers unmount, then listeners removed',
        (tester) async {
      // This test demonstrates the bug fix: removeListener now triggers auto-dispose
      final pipe = Pipe<int>(0);
      int listenerCallCount = 0;

      void listener() {
        listenerCallCount++;
      }

      pipe.addListener(listener);

      await tester.pumpWidget(
        MaterialApp(
          home: Sink<int>(
            pipe: pipe,
            builder: (context, value) => Text('$value'),
          ),
        ),
      );

      expect(pipe.subscriberCount, 1);
      expect(pipe.disposed, false);

      // Update value
      pipe.value = 5;
      await tester.pump();
      expect(listenerCallCount, 1);

      // Widget unmounts (subscriber detaches)
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      await tester.idle();

      // Should NOT be disposed yet because listener still exists
      expect(pipe.subscriberCount, 0);
      expect(pipe.disposed, false,
          reason: 'Pipe should not dispose while listener exists');

      // Now remove the listener - THIS IS THE BUG FIX
      // Before fix: removeListener didn't check for auto-dispose
      // After fix: removeListener triggers auto-dispose check
      pipe.removeListener(listener);
      await Future.delayed(Duration.zero); // Wait for microtask

      // Should NOW be disposed because both subscribers and listeners are empty
      expect(pipe.disposed, true,
          reason: 'Pipe should auto-dispose after last listener removed');
    });
  });
}
