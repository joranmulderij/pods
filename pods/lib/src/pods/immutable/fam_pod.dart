import 'package:riverpod/riverpod.dart';

class FamPod<T, A> {
  FamPod(this.onRead) : _provider = AutoDisposeProviderFamily(onRead);

  final T Function(AutoDisposeProviderRef<T> ref, A arg) onRead;

  final AutoDisposeProviderFamily<T, A> _provider;

  AutoDisposeProvider<T> call(A arg) => _provider(arg);
}
