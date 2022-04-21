import 'package:rate_limit/rate_limit.dart';
import 'package:test/test.dart';

import 'common.dart';

void main() {
  late RateLimit rateLimit;
  late Stopwatch stopwatch;

  setUp(() {
    rateLimit = RateLimit(
      requestCount: 3,
      timeMs: 1000,
    );

    stopwatch = Stopwatch();
  });

  void expectTime(int value) {
    final int min = value - 10;
    final int max = value + 50;

    stopwatch.stop();
    expect(stopwatch.elapsedMilliseconds, inExclusiveRange(min, max));
    stopwatch.start();
  }

  // 'i: _|_|_|_'
  // 'o: _|_|_|_',
  test(
    'RateLimit, _|_|_|_',
    () async {
      stopwatch.start();

      await rateLimit.waitAccess();
      expect(await resourceRequest(0), 3);
      await sleep(300);
      await rateLimit.waitAccess();
      expect(await resourceRequest(1), 1);
      await sleep(300);
      await rateLimit.waitAccess();
      expect(await resourceRequest(2), 4);
      expectTime(600);
    },
  );

  // 'i: _|||___|_'
  // 'o: _|||______|_',
  test(
    'RateLimit, _|||___|_',
    () async {
      stopwatch.start();

      await rateLimit.waitAccess();
      expect(await resourceRequest(0), 3);
      await rateLimit.waitAccess();
      expect(await resourceRequest(1), 1);
      await rateLimit.waitAccess();
      expect(await resourceRequest(2), 4);
      await sleep(500);
      await rateLimit.waitAccess();
      expect(await resourceRequest(3), 1);
      expectTime(1000);
    },
  );

  // 'i: _|_|_|_____||_'
  // 'o: _|_|_|_____|_|_',
  test(
    'RateLimit, _|_|_|_____||_',
    () async {
      stopwatch.start();

      await rateLimit.waitAccess();
      expect(await resourceRequest(0), 3);
      await sleep(100);
      await rateLimit.waitAccess();
      expect(await resourceRequest(1), 1);
      await sleep(100);
      await rateLimit.waitAccess();
      expect(await resourceRequest(2), 4);
      await sleep(100);
      await rateLimit.waitAccess();
      expect(await resourceRequest(3), 1);
      expectTime(1000);
      await rateLimit.waitAccess();
      expect(await resourceRequest(4), 5);
      expectTime(1100);
    },
  );

  // 'i: _|_|_|___________________||||_'
  // 'o: _|_|_|___________________|||______|',
  test(
    'RateLimit, _|_|_|___________________||||_',
    () async {
      stopwatch.start();

      await rateLimit.waitAccess();
      expect(await resourceRequest(0), 3);
      await sleep(100);
      await rateLimit.waitAccess();
      expect(await resourceRequest(1), 1);
      await sleep(100);
      await rateLimit.waitAccess();
      expect(await resourceRequest(2), 4);
      await sleep(1800);
      await rateLimit.waitAccess();
      expect(await resourceRequest(3), 1);
      expectTime(2000);
      await rateLimit.waitAccess();
      expect(await resourceRequest(1), 1);
      expectTime(2000);
      await rateLimit.waitAccess();
      expect(await resourceRequest(2), 4);
      expectTime(2000);
      await rateLimit.waitAccess();
      expect(await resourceRequest(2), 4);
      expectTime(3000);
    },
  );

  // 'i: _|_|__|____|||||||_'
  // 'o: _|_|__|_______|_|__|_______|_|__|_______|_',
  test(
    'RateLimit, _|_|__|____|||||||_',
    () async {
      stopwatch.start();

      await rateLimit.waitAccess();
      expect(await resourceRequest(0), 3);
      await sleep(100);
      await rateLimit.waitAccess();
      expect(await resourceRequest(1), 1);
      await sleep(200);
      await rateLimit.waitAccess();
      expect(await resourceRequest(2), 4);
      expectTime(300);
      await rateLimit.waitAccess();
      expect(await resourceRequest(3), 1);
      expectTime(1000);
      await rateLimit.waitAccess();
      expect(await resourceRequest(4), 5);
      expectTime(1100);
      await rateLimit.waitAccess();
      expect(await resourceRequest(0), 3);
      expectTime(1300);
      await rateLimit.waitAccess();
      expect(await resourceRequest(1), 1);
      expectTime(2000);
      await rateLimit.waitAccess();
      expect(await resourceRequest(2), 4);
      expectTime(2100);
      await rateLimit.waitAccess();
      expect(await resourceRequest(3), 1);
      expectTime(2300);
      await rateLimit.waitAccess();
      expect(await resourceRequest(4), 5);
      expectTime(3000);
    },
  );
}
