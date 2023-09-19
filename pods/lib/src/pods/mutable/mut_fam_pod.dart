import 'package:riverpod/riverpod.dart';

class MutFamPod<T, A> {
  MutFamPod({
    required this.onCreate,
    required this.onRead,
    required this.onUpdate,
    required this.onDelete,
  }) : _provider = AutoDisposeNotifierProviderFamily(
          () => MutFamPodNotifier(onRead, onUpdate, onDelete),
        );

  final AutoDisposeNotifierProviderFamily<MutFamPodNotifier<T, A>, T, A>
      _provider;

  final (A, T) Function(AutoDisposeNotifierProviderRef<T> ref) onCreate;
  final T Function(AutoDisposeNotifierProviderRef<T> ref, A arg) onRead;
  final void Function(AutoDisposeNotifierProviderRef<T> ref, A arg, T value)
      onUpdate;
  final void Function(AutoDisposeNotifierProviderRef<T> ref, A arg) onDelete;

  AutoDisposeFamilyNotifierProvider<MutFamPodNotifier<T, A>, T, A> call(
    A arg,
  ) =>
      _provider(arg);

  Refreshable<MutFamPodNotifier<T, A>> notifier(A arg) =>
      _provider(arg).notifier;
}

class MutFamPodNotifier<T, A> extends AutoDisposeFamilyNotifier<T, A> {
  MutFamPodNotifier(this._onRead, this._onUpdate, this._onDelete);

  final T Function(AutoDisposeNotifierProviderRef<T> ref, A arg) _onRead;
  final void Function(AutoDisposeNotifierProviderRef<T> ref, A arg, T value)
      _onUpdate;
  final void Function(AutoDisposeNotifierProviderRef<T> ref, A arg) _onDelete;

  void delete() {
    _onDelete(ref, arg);
    state = _onRead(ref, arg);
  }

  void put(T value) {
    _onUpdate(ref, arg, value);
    state = value;
  }

  @override
  T build(A arg) {
    return _onRead(ref, arg);
  }
}
