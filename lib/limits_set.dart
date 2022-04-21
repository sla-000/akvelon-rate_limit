import 'dart:core';

import 'package:rate_limit/limiter.dart';
import 'package:rate_limit/rate_limit.dart';

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
}
