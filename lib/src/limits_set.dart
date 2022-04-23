import 'dart:core';

import 'package:requests_limiter/src/limiter.dart';
import 'package:requests_limiter/src/rate_limit.dart';

class LimitsSet implements Limiter {
  LimitsSet({
    this.limits,
  });

  /// List of limits
  final List<RateLimit>? limits;

  @override
  Future<void> waitAccess() async {
    final Iterable<Future<void>>? futures = limits?.map(
      (RateLimit rateLimit) => rateLimit.waitAccess(),
    );

    if (futures == null) {
      return;
    }

    await Future.wait<void>([
      ...futures,
    ]);
  }

  @override
  bool haveAccess() => limits?.every((RateLimit rateLimit) => rateLimit.haveAccess()) ?? true;
}
