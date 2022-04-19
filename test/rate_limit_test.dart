import 'dart:async';

import 'package:rate_limit/rate_limit.dart';
import 'package:test/test.dart';

const List<int> kPreciousResource = <int>[3, 1, 4, 1, 5];

int resourceRequest(int index) => kPreciousResource[index];

void main() {
  late RateLimit rateLimit;
  late Stopwatch stopwatch;

  setUp(() {
    rateLimit = RateLimit<int, int>(
      resourceRequest: resourceRequest,
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

  Future<void> sleep(int ms) => Future<void>.delayed(Duration(milliseconds: ms));

  // 'i: _|_|_|_'
  // 'o: _|_|_|_',
  test(
    'RateLimit, _|_|_|_',
    () async {
      stopwatch.start();

      expect(await rateLimit.request(0), 3);
      await sleep(300);
      expect(await rateLimit.request(1), 1);
      await sleep(300);
      expect(await rateLimit.request(2), 4);
      expectTime(600);
    },
  );

  // 'i: _|||___|_'
  // 'o: _|||______|_',
  test(
    'RateLimit, _|||___|_',
    () async {
      stopwatch.start();

      expect(await rateLimit.request(0), 3);
      expect(await rateLimit.request(1), 1);
      expect(await rateLimit.request(2), 4);
      await sleep(500);
      expect(await rateLimit.request(3), 1);
      expectTime(1000);
    },
  );

  // 'i: _|_|_|_____||_'
  // 'o: _|_|_|_____|_|_',
  test(
    'RateLimit, _|_|_|_____||_',
    () async {
      stopwatch.start();

      expect(await rateLimit.request(0), 3);
      await sleep(100);
      expect(await rateLimit.request(1), 1);
      await sleep(100);
      expect(await rateLimit.request(2), 4);
      await sleep(100);
      expect(await rateLimit.request(3), 1);
      expectTime(1000);
      expect(await rateLimit.request(4), 5);
      expectTime(1100);
    },
  );

  // 'i: _|_|_|___________________||||_'
  // 'o: _|_|_|___________________|||______|',
  test(
    'RateLimit, _|_|_|___________________||||_',
    () async {
      stopwatch.start();

      expect(await rateLimit.request(0), 3);
      await sleep(100);
      expect(await rateLimit.request(1), 1);
      await sleep(100);
      expect(await rateLimit.request(2), 4);
      await sleep(1800);
      expect(await rateLimit.request(3), 1);
      expectTime(2000);
      expect(await rateLimit.request(1), 1);
      expectTime(2000);
      expect(await rateLimit.request(2), 4);
      expectTime(2000);
      expect(await rateLimit.request(2), 4);
      expectTime(3000);
    },
  );

  // 'i: _|_|__|____|||||||_'
  // 'o: _|_|__|_______|_|__|_______|_|__|_______|_',
  test(
    'RateLimit, _|_|__|____|||||||_',
    () async {
      stopwatch.start();

      expect(await rateLimit.request(0), 3);
      await sleep(100);
      expect(await rateLimit.request(1), 1);
      await sleep(200);
      expect(await rateLimit.request(2), 4);
      expectTime(300);
      expect(await rateLimit.request(3), 1);
      expectTime(1000);
      expect(await rateLimit.request(4), 5);
      expectTime(1100);
      expect(await rateLimit.request(0), 3);
      expectTime(1300);
      expect(await rateLimit.request(1), 1);
      expectTime(2000);
      expect(await rateLimit.request(2), 4);
      expectTime(2100);
      expect(await rateLimit.request(3), 1);
      expectTime(2300);
      expect(await rateLimit.request(4), 5);
      expectTime(3000);
    },
  );
}
