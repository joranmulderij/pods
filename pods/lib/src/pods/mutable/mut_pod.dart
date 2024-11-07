import 'package:pods/pods.dart';
import 'package:pods/src/types.dart';
import 'package:riverpod/riverpod.dart';

abstract class MutPod<T> implements ImmutablePod<T> {
  factory MutPod({
    required T Function(PodRef ref) onRead,
    void Function(PodRef ref, T value)? onUpdate,
    void Function(PodRef ref)? onReset,
  }) = _RiverpodMutPod;

  factory MutPod.simple({
    required T Function(PodRef ref) read,
    required void Function(PodRef ref, T value) update,
    required void Function(PodRef ref) reset,
    required void Function(PodRef ref, ListenerFunction<T> listener) listen,
  }) = _SimpleMutPod;

  void update(PodRef ref, T value);

  @override
  void listen(PodRef ref, void Function(T? previous, T next) listener);

  void reset(PodRef ref);
}

class _SimpleMutPod<T> implements MutPod<T> {
  _SimpleMutPod({
    required T Function(PodRef ref) read,
    required void Function(PodRef ref, ListenerFunction<T> listener) listen,
    required void Function(PodRef ref, T value) update,
    required void Function(PodRef ref) reset,
  })  : _read = read,
        _update = update,
        _reset = reset,
        _listen = listen;

  final T Function(PodRef ref) _read;
  final void Function(PodRef ref, T value) _update;
  final void Function(PodRef ref) _reset;
  final void Function(PodRef ref, ListenerFunction<T> listener) _listen;

  @override
  T watch(PodRef ref) => _read(ref);

  @override
  T read(PodRef ref) => _read(ref);

  @override
  void update(PodRef ref, T value) => _update.call(ref, value);

  @override
  void listen(PodRef ref, void Function(T? previous, T next) listener) =>
      _listen(ref, listener);

  @override
  void reset(PodRef ref) => _reset.call(ref);
}

class _RiverpodMutPod<T> implements MutPod<T> {
  _RiverpodMutPod({
    required T Function(PodRef ref) onRead,
    void Function(PodRef ref, T value)? onUpdate,
    void Function(PodRef ref)? onReset,
  }) : _provider = AutoDisposeNotifierProvider(
          () => _MutPodNotifier(onRead, onUpdate, onReset),
        );

  final AutoDisposeNotifierProvider<_MutPodNotifier<T>, T> _provider;

  @override
  T watch(PodRef ref) => ref.watch(_provider);

  @override
  T read(PodRef ref) => ref.read(_provider);

  @override
  void update(PodRef ref, T value) {
    ref.read(_provider.notifier).update(value);
  }

  @override
  void listen(PodRef ref, void Function(T? previous, T next) listener) {
    ref.listen(_provider, listener);
  }

  @override
  void reset(PodRef ref) {
    ref.read(_provider.notifier).delete();
  }
}

class _MutPodNotifier<T> extends AutoDisposeNotifier<T> {
  _MutPodNotifier(this._onRead, this._onUpdate, this._onReset);

  final T Function(PodRef ref) _onRead;
  final void Function(PodRef ref, T value)? _onUpdate;
  final void Function(PodRef ref)? _onReset;

  void update(T value) {
    _onUpdate?.call(ref.s, value);
    state = value;
  }

  void delete() {
    _onReset?.call(ref.s);
    state = _onRead(ref.s);
  }

  @override
  T build() {
    return _onRead(ref.s);
  }
}

extension NonNullMutPod<T> on MutPod<T?> {
  MutPod<T> nonNull(T Function() defaultValue) {
    return MutPod<T>(
      onRead: (ref) => watch(ref) ?? defaultValue(),
      onUpdate: update,
      onReset: reset,
    );
  }
}
