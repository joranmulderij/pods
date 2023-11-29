import 'package:pods/pods.dart';
import 'package:riverpod/riverpod.dart';

class ImmutablePod<T> {
  ImmutablePod(T Function(StateRef ref) onRead)
      : _provider = AutoDisposeProvider((ref) => onRead(ref.s));

  final AutoDisposeProvider<T> _provider;

  T read(StateRef ref) => ref.read(_provider);

  T watch(StateRef ref) => ref.watch(_provider);

  void listen(StateRef ref, void Function(T? previous, T next) listener) {
    ref.listen(_provider, listener);
  }
}

ImmutablePod<T> constPod<T>(T value) {
  return ImmutablePod<T>((ref) => value);
}
