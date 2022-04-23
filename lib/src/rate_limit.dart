import 'dart:async';

import 'package:requests_limiter/src/limiter.dart';

class RateLimit implements Limiter {
  RateLimit({
    this.timeMs = 1000,
    this.requestCount = 5,
  });

  /// Window length in ms
  final int timeMs;

  /// Max requests number per window
  final int requestCount;

  final List<int> _historyOfRequestsTimes = [];

  @override
  Future<void> waitAccess() async {
    final currentRequestTime = DateTime.now().millisecondsSinceEpoch;

    if (_historyOfRequestsTimes.length < requestCount) {
      _historyOfRequestsTimes.add(currentRequestTime);

      return;
    }

    final firstRequestTime = _historyOfRequestsTimes[0];
    _historyOfRequestsTimes.removeAt(0);

    final int deltaBetweenFirstAndCurrentRequest = currentRequestTime - firstRequestTime;

    if (deltaBetweenFirstAndCurrentRequest >= timeMs) {
      _historyOfRequestsTimes.add(currentRequestTime);
    } else {
      final int timeToWait = timeMs - deltaBetweenFirstAndCurrentRequest;
      _historyOfRequestsTimes.add(currentRequestTime + timeToWait);

      await Future<void>.delayed(Duration(milliseconds: timeToWait));
    }

    return;
  }

  @override
  bool haveAccess() {
    if (_historyOfRequestsTimes.length < requestCount) {
      return true;
    }

    final firstRequestTime = _historyOfRequestsTimes[0];

    final currentRequestTime = DateTime.now().millisecondsSinceEpoch;

    final int deltaBetweenFirstAndCurrentRequest = currentRequestTime - firstRequestTime;

    return deltaBetweenFirstAndCurrentRequest >= timeMs;
  }
}
