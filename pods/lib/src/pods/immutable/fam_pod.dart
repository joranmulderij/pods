import 'package:pods/pods.dart';
import 'package:riverpod/riverpod.dart';

class FamPod<T, A> {
  FamPod(T Function(AutoDisposeProviderRef<T> ref, A arg) onRead)
      : _provider = AutoDisposeProviderFamily(onRead);

  final AutoDisposeProviderFamily<T, A> _provider;

  T read(PodRef ref, A arg) => ref.read(_provider(arg));

  T watch(PodRef ref, A arg) => ref.watch(_provider(arg));
}
