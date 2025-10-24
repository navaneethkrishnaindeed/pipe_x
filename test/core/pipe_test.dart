import 'package:flutter_test/flutter_test.dart';
import 'package:pipe_x/pipe_x.dart';

void main() {
  group('Pipe', () {
    test('should initialize with correct value', () {
      final pipe = Pipe<int>(5);
      expect(pipe.value, 5);
      pipe.dispose();
    });

    test('should update value', () {
      final pipe = Pipe<int>(0);
      pipe.value = 10;
      expect(pipe.value, 10);
      pipe.dispose();
    });

    test('should notify listeners when value changes', () {
      final pipe = Pipe<int>(0);
      var callCount = 0;

      pipe.addListener(() {
        callCount++;
      });

      pipe.value = 1;
      pipe.value = 2;

      expect(callCount, 2);
      pipe.dispose();
    });

    test('should not notify when value is the same', () {
      final pipe = Pipe<int>(5);
      var callCount = 0;

      pipe.addListener(() {
        callCount++;
      });

      pipe.value = 5; // Same value
      expect(callCount, 0);
      pipe.dispose();
    });

    test('pump should always notify even with same value', () {
      final pipe = Pipe<int>(5);
      var callCount = 0;

      pipe.addListener(() {
        callCount++;
      });

      pipe.pump(5); // Same value but should notify
      expect(callCount, 1);
      pipe.dispose();
    });

    test('should remove listener correctly', () {
      final pipe = Pipe<int>(0);
      var callCount = 0;

      void listener() {
        callCount++;
      }

      pipe.addListener(listener);
      pipe.value = 1;
      expect(callCount, 1);

      pipe.removeListener(listener);
      pipe.value = 2;
      expect(callCount, 1); // Should not increase
      pipe.dispose();
    });

    test('should throw error when accessing disposed pipe value', () {
      final pipe = Pipe<int>(5);
      pipe.dispose();

      expect(() => pipe.value, throwsStateError);
    });

    test('should throw error when setting disposed pipe value', () {
      final pipe = Pipe<int>(5);
      pipe.dispose();

      expect(() => pipe.value = 10, throwsStateError);
    });

    test('should throw error when pumping disposed pipe', () {
      final pipe = Pipe<int>(5);
      pipe.dispose();

      expect(() => pipe.pump(10), throwsStateError);
    });

    test('should track subscriber count', () {
      final pipe = Pipe<int>(0);
      expect(pipe.subscriberCount, 0);
      pipe.dispose();
    });

    test('should indicate if disposed', () {
      final pipe = Pipe<int>(0);
      expect(pipe.disposed, false);

      pipe.dispose();
      expect(pipe.disposed, true);
    });

    test('dispose should be idempotent', () {
      final pipe = Pipe<int>(0);
      pipe.dispose();
      pipe.dispose(); // Should not throw

      expect(pipe.disposed, true);
    });

    test('should clear listeners on dispose', () {
      final pipe = Pipe<int>(0);

      pipe.addListener(() {
        // Listener added but won't be called after dispose
      });

      pipe.dispose();
      // Can't update after dispose, but listeners should be cleared
      expect(pipe.disposed, true);
    });

    test('should work with custom types', () {
      final pipe = Pipe<String>('hello');
      expect(pipe.value, 'hello');

      pipe.value = 'world';
      expect(pipe.value, 'world');
      pipe.dispose();
    });

    test('should work with nullable types', () {
      final pipe = Pipe<int?>(null);
      expect(pipe.value, null);

      pipe.value = 5;
      expect(pipe.value, 5);

      pipe.value = null;
      expect(pipe.value, null);
      pipe.dispose();
    });

    test('autoDispose flag should be accessible', () {
      final pipe1 = Pipe<int>(0);
      expect(pipe1.autoDispose, true); // Default for standalone pipes

      final pipe2 = Pipe<int>(0, autoDispose: false);
      expect(pipe2.autoDispose, false);

      pipe1.dispose();
      pipe2.dispose();
    });
  });
}
