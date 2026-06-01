import 'package:flutter_test/flutter_test.dart';
import 'package:wd_cust_mobile_app/utils/debouncer.dart';

void main() {
  group('Debouncer', () {
    test('fires the action once after the delay', () async {
      final debouncer = Debouncer(delay: const Duration(milliseconds: 50));
      var count = 0;

      debouncer.run(() => count++);

      // Not yet fired immediately.
      expect(count, 0);

      await Future<void>.delayed(const Duration(milliseconds: 90));
      expect(count, 1);

      debouncer.dispose();
    });

    test('a rapid second call resets the timer (action fires once)', () async {
      final debouncer = Debouncer(delay: const Duration(milliseconds: 80));
      var first = 0;
      var second = 0;

      debouncer.run(() => first++);
      // Re-trigger before the first timer elapses -> cancels the first.
      await Future<void>.delayed(const Duration(milliseconds: 30));
      debouncer.run(() => second++);

      // Wait past the reset delay.
      await Future<void>.delayed(const Duration(milliseconds: 120));

      expect(first, 0); // first call was cancelled
      expect(second, 1); // only the latest call fired

      debouncer.dispose();
    });

    test('dispose cancels a pending call', () async {
      final debouncer = Debouncer(delay: const Duration(milliseconds: 50));
      var count = 0;

      debouncer.run(() => count++);
      debouncer.dispose();

      await Future<void>.delayed(const Duration(milliseconds: 90));
      expect(count, 0);
    });

    test('uses the default 500ms delay when none supplied', () {
      final debouncer = Debouncer();
      expect(debouncer.delay, const Duration(milliseconds: 500));
      debouncer.dispose();
    });
  });
}
