import 'package:riverpod/riverpod.dart';

class MutAsyncPod<T> {
  MutAsyncPod({
    required this.onRead,
    this.onUpdate,
    this.onReset,
  }) : _provider = AutoDisposeAsyncNotifierProvider(
          () => MutAsyncPodNotifier(onRead, onUpdate, onReset),
        );

  final AutoDisposeAsyncNotifierProvider<MutAsyncPodNotifier<T>, T> _provider;

  final Future<T> Function(AutoDisposeAsyncNotifierProviderRef<T> ref) onRead;
  final Future<void> Function(
    AutoDisposeAsyncNotifierProviderRef<T> ref,
    T value,
  )? onUpdate;
  final Future<void> Function(AutoDisposeAsyncNotifierProviderRef<T> ref)?
      onReset;

  AutoDisposeAsyncNotifierProvider<MutAsyncPodNotifier<T>, T> call() =>
      _provider;

  Refreshable<MutAsyncPodNotifier<T>> notifier() => _provider.notifier;

  Refreshable<Future<T>> future() => _provider.future;
}

class MutAsyncPodNotifier<T> extends AutoDisposeAsyncNotifier<T> {
  MutAsyncPodNotifier(this.onRead, this.onUpdate, this.onReset);

  final Future<T> Function(AutoDisposeAsyncNotifierProviderRef<T> ref) onRead;
  final Future<void> Function(
    AutoDisposeAsyncNotifierProviderRef<T> ref,
    T value,
  )? onUpdate;
  final Future<void> Function(AutoDisposeAsyncNotifierProviderRef<T> ref)?
      onReset;

  Future<void> put(T value) async {
    state = AsyncValue.data(value);
  }

  Future<void> reset() async {
    final value = await onRead(ref);
    state = AsyncValue.data(value);
  }

  @override
  Future<T> build() {
    return onRead(ref);
  }
}
