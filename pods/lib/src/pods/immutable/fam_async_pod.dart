import 'package:pods/pods.dart';
import 'package:riverpod/riverpod.dart';

class FamAsyncPod<T, A> {
  FamAsyncPod(
    Future<T> Function(PodRef ref, A arg) onRead,
  ) : _provider =
            AutoDisposeFutureProviderFamily((ref, arg) => onRead(ref.s, arg));

  final AutoDisposeFutureProviderFamily<T, A> _provider;

  AsyncValue<T> read(PodRef ref, A arg) => ref.read(_provider(arg));
  Future<T> readFuture(PodRef ref, A arg) => ref.read(_provider(arg).future);

  AsyncValue<T> watch(PodRef ref, A arg) => ref.read(_provider(arg));
  Future<T> watchFuture(PodRef ref, A arg) => ref.read(_provider(arg).future);
}
