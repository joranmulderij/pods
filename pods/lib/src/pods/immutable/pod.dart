import 'package:riverpod/riverpod.dart';

class Pod<T> {
  Pod(this.onRead) : _provider = AutoDisposeProvider(onRead);

  final T Function(AutoDisposeProviderRef<T> ref) onRead;

  final AutoDisposeProvider<T> _provider;

  AutoDisposeProvider<T> get provider => _provider;

  AutoDisposeProvider<T> call() => _provider;
}

Pod<T> constPod<T>(T value) {
  return Pod<T>((ref) => value);
}
