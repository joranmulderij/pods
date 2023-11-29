import 'package:pods/pods.dart';
import 'package:riverpod/riverpod.dart';

class AsyncPod<T> {
  AsyncPod(Future<T> Function(AutoDisposeFutureProviderRef<T> ref) onRead)
      : _provider = AutoDisposeFutureProvider(onRead);

  final AutoDisposeFutureProvider<T> _provider;

  AsyncValue<T> read(StateRef ref) => ref.read(_provider);
  Future<T> readFuture(StateRef ref) => ref.read(_provider.future);

  AsyncValue<T> watch(StateRef ref) => ref.read(_provider);
  Future<T> watchFuture(StateRef ref) => ref.read(_provider.future);
}
