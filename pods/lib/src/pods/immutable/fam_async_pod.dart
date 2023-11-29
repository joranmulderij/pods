import 'package:pods/pods.dart';
import 'package:riverpod/riverpod.dart';

class FamAsyncPod<T, A> {
  FamAsyncPod(
    Future<T> Function(StateRef ref, A arg) onRead,
  ) : _provider =
            AutoDisposeFutureProviderFamily((ref, arg) => onRead(ref.s, arg));

  final AutoDisposeFutureProviderFamily<T, A> _provider;

  AsyncValue<T> read(StateRef ref, A arg) => ref.read(_provider(arg));
  Future<T> readFuture(StateRef ref, A arg) => ref.read(_provider(arg).future);

  AsyncValue<T> watch(StateRef ref, A arg) => ref.read(_provider(arg));
  Future<T> watchFuture(StateRef ref, A arg) => ref.read(_provider(arg).future);
}
