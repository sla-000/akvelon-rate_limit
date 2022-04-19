import 'dart:async';

class RateLimit<R, A> {
  RateLimit({
    this.timeMs = 1000,
    this.requestCount = 5,
    required this.resourceRequest,
  });

  /// Window length in ms
  final int timeMs;

  /// Max requests number per window
  final int requestCount;

  /// Function to access a resource
  final FutureOr<R> Function(A arg) resourceRequest;

  final List<int> _historyOfRequestsTimes = [];

  Future<R> request(A arg) async {
    final currentRequestTime = DateTime.now().millisecondsSinceEpoch;

    if (_historyOfRequestsTimes.length < requestCount) {
      _historyOfRequestsTimes.add(currentRequestTime);

      return await resourceRequest(arg);
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

    return await resourceRequest(arg);
  }
}
