import 'package:requests_limiter/src/limits_set.dart';
import 'package:requests_limiter/src/rate_limit.dart';
import 'package:test/test.dart';

import 'common.dart';

void main() {
  late LimitsSet limitsSet;
  late Repo repo;
  late Stopwatch stopwatch;

  setUp(() {
    repo = RepoMock();

    limitsSet = LimitsSet(
      limits: [
        RateLimit(
          requestCount: 3,
          timeMs: 1000,
        ),
        RateLimit(
          requestCount: 5,
          timeMs: 2000,
        ),
      ],
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

  // 'i: _||||_'
  // 'o: _|||______|_',
  test(
    'LimitsSet, _||||_',
    () async {
      stopwatch.start();

      expect(limitsSet.haveAccess(), isTrue);
      await limitsSet.waitAccess();
      expect(await repo.resourceRequest(0), 3);
      expect(limitsSet.haveAccess(), isTrue);
      await limitsSet.waitAccess();
      expect(await repo.resourceRequest(1), 1);
      expect(limitsSet.haveAccess(), isTrue);
      await limitsSet.waitAccess();
      expect(await repo.resourceRequest(2), 4);
      expectTime(0);
      expect(limitsSet.haveAccess(), isFalse);
      await limitsSet.waitAccess();
      expect(await repo.resourceRequest(1), 1);
      expectTime(1000);
    },
  );

  // 'i: _|___|___|___|___|___|_'
  // 'o: _|___|___|___|___|_________|_',
  test(
    'LimitsSet, _|___|___|___|___|___|_',
    () async {
      stopwatch.start();

      expect(limitsSet.haveAccess(), isTrue);
      await limitsSet.waitAccess();
      expect(await repo.resourceRequest(0), 3);
      await sleep(350);
      expect(limitsSet.haveAccess(), isTrue);
      await limitsSet.waitAccess();
      expect(await repo.resourceRequest(1), 1);
      await sleep(350);
      expect(limitsSet.haveAccess(), isTrue);
      await limitsSet.waitAccess();
      expect(await repo.resourceRequest(2), 4);
      await sleep(350);
      expect(limitsSet.haveAccess(), isTrue);
      await limitsSet.waitAccess();
      expect(await repo.resourceRequest(3), 1);
      await sleep(350);
      expect(limitsSet.haveAccess(), isTrue);
      await limitsSet.waitAccess();
      expect(await repo.resourceRequest(4), 5);
      expectTime(1400);
      expect(limitsSet.haveAccess(), isFalse);
      await limitsSet.waitAccess();
      expect(await repo.resourceRequest(0), 3);
      expectTime(2000);
    },
  );

  // 'i: _|_|_|___|_|_|___|'
  // 'o: _|_|_|___|_|_____|___|_',
  test(
    'LimitsSet, _|_|_|___|_|_|___|_',
    () async {
      stopwatch.start();

      expect(limitsSet.haveAccess(), isTrue);
      await limitsSet.waitAccess();
      expect(limitsSet.haveAccess(), isTrue);
      expect(await repo.resourceRequest(0), 3);
      await sleep(300);
      expect(limitsSet.haveAccess(), isTrue);
      await limitsSet.waitAccess();
      expect(limitsSet.haveAccess(), isTrue);
      expect(await repo.resourceRequest(1), 1);
      await sleep(300);
      expect(limitsSet.haveAccess(), isTrue);
      await limitsSet.waitAccess();
      expect(limitsSet.haveAccess(), isFalse);
      expect(await repo.resourceRequest(2), 4);
      expectTime(600);
      await sleep(500);
      expect(limitsSet.haveAccess(), isTrue);
      await limitsSet.waitAccess();
      expect(limitsSet.haveAccess(), isFalse);
      expect(await repo.resourceRequest(0), 3);
      await sleep(300);
      expect(limitsSet.haveAccess(), isTrue);
      await limitsSet.waitAccess();
      expect(limitsSet.haveAccess(), isFalse);
      expect(await repo.resourceRequest(1), 1);
      await sleep(300);
      expect(limitsSet.haveAccess(), isFalse);
      await limitsSet.waitAccess();
      expect(limitsSet.haveAccess(), isFalse);
      expect(await repo.resourceRequest(2), 4);
      expectTime(2000);
      await sleep(500);
      expect(limitsSet.haveAccess(), isTrue);
      await limitsSet.waitAccess();
      expect(limitsSet.haveAccess(), isFalse);
      expect(await repo.resourceRequest(3), 1);
      expectTime(2500);
      await sleep(500);
      expect(limitsSet.haveAccess(), isTrue);
      expectTime(3000);
    },
  );
}
