import 'dart:async';

abstract class Limiter {
  Future<void> waitAccess();

  bool haveAccess();
}
