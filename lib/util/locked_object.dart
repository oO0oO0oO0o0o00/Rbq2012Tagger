import 'dart:async';

import 'package:synchronized/synchronized.dart';

class LockedObject<T> {
  final Lock _lock;
  final T _object;

  LockedObject(this._object, {bool reentrant = false})
      : _lock = Lock(reentrant: reentrant);

  Future<R> run<R>(FutureOr<R> Function(T object) computation,
          {Duration? timeout}) =>
      _lock.synchronized(() => computation(_object), timeout: timeout);

  FutureOr<R> runWithoutLock<R>(FutureOr<R> Function(T object) computation) =>
      computation(_object);
}
