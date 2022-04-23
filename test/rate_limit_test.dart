import 'package:requests_limiter/src/rate_limit.dart';
import 'package:test/test.dart';

import 'common.dart';

void main() {
  late RateLimit rateLimit;
  late Repo repo;
  late Stopwatch stopwatch;

  setUp(() {
    repo = RepoMock();

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

      expect(rateLimit.haveAccess(), isTrue);
      await rateLimit.waitAccess();
      expect(await repo.resourceRequest(0), 3);
      await sleep(300);
      expect(rateLimit.haveAccess(), isTrue);
      await rateLimit.waitAccess();
      expect(await repo.resourceRequest(1), 1);
      await sleep(300);
      expect(rateLimit.haveAccess(), isTrue);
      await rateLimit.waitAccess();
      expect(await repo.resourceRequest(2), 4);
      expectTime(600);
    },
  );

  // 'i: _|||___|_'
  // 'o: _|||______|_',
  test(
    'RateLimit, _|||___|_',
    () async {
      stopwatch.start();

      expect(rateLimit.haveAccess(), isTrue);
      await rateLimit.waitAccess();
      expect(await repo.resourceRequest(0), 3);
      expect(rateLimit.haveAccess(), isTrue);
      await rateLimit.waitAccess();
      expect(await repo.resourceRequest(1), 1);
      expect(rateLimit.haveAccess(), isTrue);
      await rateLimit.waitAccess();
      expect(await repo.resourceRequest(2), 4);
      await sleep(500);
      expect(rateLimit.haveAccess(), isFalse);
      await rateLimit.waitAccess();
      expect(await repo.resourceRequest(3), 1);
      expectTime(1000);
    },
  );

  // 'i: _|_|_|_____||_'
  // 'o: _|_|_|_____|_|_',
  test(
    'RateLimit, _|_|_|_____||_',
    () async {
      stopwatch.start();

      expect(rateLimit.haveAccess(), isTrue);
      await rateLimit.waitAccess();
      expect(await repo.resourceRequest(0), 3);
      await sleep(100);
      expect(rateLimit.haveAccess(), isTrue);
      await rateLimit.waitAccess();
      expect(await repo.resourceRequest(1), 1);
      await sleep(100);
      expect(rateLimit.haveAccess(), isTrue);
      await rateLimit.waitAccess();
      expect(await repo.resourceRequest(2), 4);
      await sleep(100);
      expect(rateLimit.haveAccess(), isFalse);
      await rateLimit.waitAccess();
      expect(await repo.resourceRequest(3), 1);
      expectTime(1000);
      expect(rateLimit.haveAccess(), isFalse);
      await rateLimit.waitAccess();
      expect(await repo.resourceRequest(4), 5);
      expectTime(1100);
    },
  );

  // 'i: _|_|_|___________________||||_'
  // 'o: _|_|_|___________________|||______|',
  test(
    'RateLimit, _|_|_|___________________||||_',
    () async {
      stopwatch.start();

      expect(rateLimit.haveAccess(), isTrue);
      await rateLimit.waitAccess();
      expect(await repo.resourceRequest(0), 3);
      await sleep(100);
      expect(rateLimit.haveAccess(), isTrue);
      await rateLimit.waitAccess();
      expect(await repo.resourceRequest(1), 1);
      await sleep(100);
      expect(rateLimit.haveAccess(), isTrue);
      await rateLimit.waitAccess();
      expect(await repo.resourceRequest(2), 4);
      await sleep(1800);
      expect(rateLimit.haveAccess(), isTrue);
      await rateLimit.waitAccess();
      expect(await repo.resourceRequest(3), 1);
      expectTime(2000);
      expect(rateLimit.haveAccess(), isTrue);
      await rateLimit.waitAccess();
      expect(await repo.resourceRequest(1), 1);
      expectTime(2000);
      expect(rateLimit.haveAccess(), isTrue);
      await rateLimit.waitAccess();
      expect(await repo.resourceRequest(2), 4);
      expectTime(2000);
      expect(rateLimit.haveAccess(), isFalse);
      await rateLimit.waitAccess();
      expect(await repo.resourceRequest(2), 4);
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
      expect(await repo.resourceRequest(0), 3);
      await sleep(100);
      await rateLimit.waitAccess();
      expect(await repo.resourceRequest(1), 1);
      await sleep(200);
      await rateLimit.waitAccess();
      expect(await repo.resourceRequest(2), 4);
      expectTime(300);
      await rateLimit.waitAccess();
      expect(await repo.resourceRequest(3), 1);
      expectTime(1000);
      await rateLimit.waitAccess();
      expect(await repo.resourceRequest(4), 5);
      expectTime(1100);
      await rateLimit.waitAccess();
      expect(await repo.resourceRequest(0), 3);
      expectTime(1300);
      await rateLimit.waitAccess();
      expect(await repo.resourceRequest(1), 1);
      expectTime(2000);
      await rateLimit.waitAccess();
      expect(await repo.resourceRequest(2), 4);
      expectTime(2100);
      await rateLimit.waitAccess();
      expect(await repo.resourceRequest(3), 1);
      expectTime(2300);
      await rateLimit.waitAccess();
      expect(await repo.resourceRequest(4), 5);
      expectTime(3000);
    },
  );
}
