import 'package:pods/pods.dart';
import 'package:riverpod/riverpod.dart';

abstract class MutFamPod<T, A> implements FamPod<T, A> {
  factory MutFamPod({
    required T Function(PodRef ref, A arg) onRead,
    required void Function(PodRef ref, A arg, T value) onUpdate,
    required void Function(PodRef ref, A arg) onDelete,
    required void Function(PodRef ref, A arg, T value) onCreate,
  }) = _RiverpodMutFamPod;

  MutFamPod._();

  @override
  T read(PodRef ref, A arg);

  @override
  T watch(PodRef ref, A arg);

  void listen(
    PodRef ref,
    A arg,
    void Function(T? previous, T next) listener,
  );

  void delete(PodRef ref, A arg);

  void update(PodRef ref, A arg, T value);

  void create(PodRef ref, A arg, T value);

  MutPod<T> child(A arg) {
    return MutPod<T>.simple(
      read: (ref) => this.watch(ref, arg),
      update: (ref, value) => this.update(ref, arg, value),
      reset: (ref) => this.delete(ref, arg),
      listen: (ref, listener) => this.listen(ref, arg, listener),
    );
  }
}

class _RiverpodMutFamPod<T, A> extends MutFamPod<T, A> {
  _RiverpodMutFamPod({
    required T Function(PodRef, A) onRead,
    required void Function(PodRef, A, T) onUpdate,
    required void Function(PodRef, A) onDelete,
    required void Function(PodRef, A, T) onCreate,
  })  : _provider = AutoDisposeNotifierProviderFamily(
          () => _MutFamPodNotifier(onRead, onUpdate, onDelete),
        ),
        _onCreate = onCreate,
        super._();

  final AutoDisposeNotifierProviderFamily<_MutFamPodNotifier<T, A>, T, A>
      _provider;

  final void Function(PodRef, A, T) _onCreate;

  @override
  T read(PodRef ref, A arg) => ref.read(_provider(arg));

  @override
  T watch(PodRef ref, A arg) => ref.watch(_provider(arg));

  @override
  void listen(
    PodRef ref,
    A arg,
    void Function(T? previous, T next) listener,
  ) {
    ref.listen(_provider(arg), listener);
  }

  @override
  void delete(PodRef ref, A arg) {
    ref.read(_provider(arg).notifier)._delete();
  }

  @override
  void update(PodRef ref, A arg, T value) {
    ref.read(_provider(arg).notifier)._update(value);
  }

  @override
  void create(PodRef ref, A arg, T value) {
    _onCreate(ref, arg, value);
  }
}

class _MutFamPodNotifier<T, A> extends AutoDisposeFamilyNotifier<T, A> {
  _MutFamPodNotifier(this._onRead, this._onUpdate, this._onDelete);

  final T Function(PodRef ref, A arg) _onRead;
  final void Function(PodRef ref, A arg, T value) _onUpdate;
  final void Function(PodRef ref, A arg) _onDelete;

  void _delete() {
    _onDelete(ref.s, arg);
    state = _onRead(ref.s, arg);
  }

  void _update(T value) {
    _onUpdate(ref.s, arg, value);
    state = value;
  }

  @override
  T build(A arg) {
    return _onRead(ref.s, arg);
  }
}

_RiverpodMutFamPod<V?, K> mapPod<K, V>() {
  final map = <K, V?>{};
  return _RiverpodMutFamPod(
    onRead: (ref, key) => map[key],
    onUpdate: (ref, key, value) => map[key] = value,
    onDelete: (ref, key) => map.remove(key),
    onCreate: (ref, key, value) => map[key] = value,
  );
}
