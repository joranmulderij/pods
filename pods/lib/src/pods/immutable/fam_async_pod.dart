import 'package:riverpod/riverpod.dart';

class FamAsyncPod<T, A> {
  FamAsyncPod(this.onRead)
      : _provider = AutoDisposeFutureProviderFamily(onRead);

  final Future<T> Function(AutoDisposeFutureProviderRef<T> ref, A arg) onRead;

  final AutoDisposeFutureProviderFamily<T, A> _provider;

  AutoDisposeFutureProvider<T> call(A arg) => _provider(arg);

  Refreshable<Future<T>> future(A arg) => _provider(arg).future;
}
