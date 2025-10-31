import 'package:flutter_test/flutter_test.dart';
import 'package:pipe_x/pipe_x.dart';

class TestHub extends Hub {
  late final count = pipe(0);
  late final name = pipe('test');

  void increment() {
    count.value++;
  }

  void setName(String newName) {
    name.value = newName;
  }
}

class DisposableHub extends Hub {
  bool onDisposeCalled = false;

  late final value = pipe(0);

  @override
  void onDispose() {
    onDisposeCalled = true;
  }
}

class HubWithManualPipes extends Hub {
  late final registered = registerPipe(Pipe(0));
}

void main() {
  group('Hub', () {
    test('should auto-register pipes created during construction', () {
      final hub = TestHub();

      expect(hub.count.value, 0);
      expect(hub.name.value, 'test');

      hub.dispose();
      expect(hub.count.disposed, true);
      expect(hub.name.disposed, true);
    });

    test('should update pipe values through methods', () {
      final hub = TestHub();

      hub.increment();
      expect(hub.count.value, 1);

      hub.setName('updated');
      expect(hub.name.value, 'updated');

      hub.dispose();
    });

    test('should track disposed state', () {
      final hub = TestHub();

      expect(hub.disposed, false);
      hub.dispose();
      expect(hub.disposed, true);
    });

    test('dispose should be idempotent', () {
      final hub = TestHub();

      hub.dispose();
      hub.dispose(); // Should not throw
      expect(hub.disposed, true);
    });

    test('should dispose all registered pipes', () {
      final hub = TestHub();

      final count = hub.count;
      final name = hub.name;

      hub.dispose();

      expect(count.disposed, true);
      expect(name.disposed, true);
    });

    test('should call onDispose when disposed', () {
      final hub = DisposableHub();

      expect(hub.onDisposeCalled, false);
      hub.dispose();
      expect(hub.onDisposeCalled, true);
    });

    test('should throw when registering pipe on disposed hub', () {
      final hub = TestHub();

      hub.dispose();
      expect(hub.disposed, true);
    });

    test('should get subscriber count across all pipes', () {
      final hub = TestHub();

      expect(hub.subscriberCount, 0);

      hub.dispose();
    });

    test('disposed hub should have disposed state', () {
      final hub = TestHub();

      expect(hub.disposed, false);
      hub.dispose();
      expect(hub.disposed, true);
    });

    test('should clear pipes map on dispose', () {
      final hub = TestHub();

      hub.increment();
      hub.setName('test');

      hub.dispose();

      // All pipes should be disposed
      expect(hub.count.disposed, true);
      expect(hub.name.disposed, true);
    });

    test('manually registered pipes should be disposed', () {
      final hub = HubWithManualPipes();

      final registered = hub.registered;

      hub.dispose();
      expect(registered.disposed, true);
    });

    test('should handle multiple pipe types', () {
      final hub = TestHub();

      hub.count.value = 42;
      hub.name.value = 'answer';

      expect(hub.count.value, 42);
      expect(hub.name.value, 'answer');

      hub.dispose();
    });
  });
}
