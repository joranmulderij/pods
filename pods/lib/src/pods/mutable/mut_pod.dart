import 'package:riverpod/riverpod.dart';

class MutPod<T> {
  MutPod({
    required this.onRead,
    this.onUpdate,
    this.onReset,
  }) : _provider = AutoDisposeNotifierProvider(
          () => MutPodNotifier(onRead, onUpdate, onReset),
        );

  final AutoDisposeNotifierProvider<MutPodNotifier<T>, T> _provider;

  final T Function(AutoDisposeNotifierProviderRef<T> ref) onRead;
  final void Function(AutoDisposeNotifierProviderRef<T> ref, T value)? onUpdate;
  final void Function(AutoDisposeNotifierProviderRef<T> ref)? onReset;

  AutoDisposeNotifierProvider<MutPodNotifier<T>, T> call() => _provider;

  Refreshable<MutPodNotifier<T>> notifier() => _provider.notifier;
}

class MutPodNotifier<T> extends AutoDisposeNotifier<T> {
  MutPodNotifier(this._onRead, this._onUpdate, this._onReset);

  final T Function(AutoDisposeNotifierProviderRef<T> ref) _onRead;
  final void Function(AutoDisposeNotifierProviderRef<T> ref, T value)?
      _onUpdate;
  final void Function(AutoDisposeNotifierProviderRef<T> ref)? _onReset;

  void put(T value) {
    _onUpdate?.call(ref, value);
    state = value;
  }

  void delete() {
    _onReset?.call(ref);
    state = _onRead(ref);
  }

  @override
  T build() {
    return _onRead(ref);
  }
}
