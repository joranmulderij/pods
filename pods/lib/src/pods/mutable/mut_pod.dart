import 'package:pods/pods.dart';
import 'package:pods/src/types.dart';
import 'package:riverpod/riverpod.dart';

abstract class MutPod<T> implements ImmutablePod<T> {
  factory MutPod({
    required T Function(StateRef ref) onRead,
    void Function(StateRef ref, T value)? onUpdate,
    void Function(StateRef ref)? onReset,
  }) = _RiverpodMutPod;

  factory MutPod.simple({
    required T Function(StateRef ref) read,
    required void Function(StateRef ref, T value) update,
    required void Function(StateRef ref) reset,
    required void Function(StateRef ref, ListenerFunction<T> listener) listen,
  }) = _SimpleMutPod;

  void update(StateRef ref, T value);

  @override
  void listen(StateRef ref, void Function(T? previous, T next) listener);

  void reset(StateRef ref);
}

class _SimpleMutPod<T> implements MutPod<T> {
  _SimpleMutPod({
    required T Function(StateRef ref) read,
    required void Function(StateRef ref, ListenerFunction<T> listener) listen,
    required void Function(StateRef ref, T value) update,
    required void Function(StateRef ref) reset,
  })  : _read = read,
        _update = update,
        _reset = reset,
        _listen = listen;

  final T Function(StateRef ref) _read;
  final void Function(StateRef ref, T value) _update;
  final void Function(StateRef ref) _reset;
  final void Function(StateRef ref, ListenerFunction<T> listener) _listen;

  @override
  T watch(StateRef ref) => _read(ref);

  @override
  T read(StateRef ref) => _read(ref);

  @override
  void update(StateRef ref, T value) => _update.call(ref, value);

  @override
  void listen(StateRef ref, void Function(T? previous, T next) listener) =>
      _listen(ref, listener);

  @override
  void reset(StateRef ref) => _reset.call(ref);
}

class _RiverpodMutPod<T> implements MutPod<T> {
  _RiverpodMutPod({
    required T Function(StateRef ref) onRead,
    void Function(StateRef ref, T value)? onUpdate,
    void Function(StateRef ref)? onReset,
  }) : _provider = AutoDisposeNotifierProvider(
          () => _MutPodNotifier(onRead, onUpdate, onReset),
        );

  final AutoDisposeNotifierProvider<_MutPodNotifier<T>, T> _provider;

  @override
  T watch(StateRef ref) => ref.watch(_provider);

  @override
  T read(StateRef ref) => ref.read(_provider);

  @override
  void update(StateRef ref, T value) {
    ref.read(_provider.notifier).update(value);
  }

  @override
  void listen(StateRef ref, void Function(T? previous, T next) listener) {
    ref.listen(_provider, listener);
  }

  @override
  void reset(StateRef ref) {
    ref.read(_provider.notifier).delete();
  }
}

class _MutPodNotifier<T> extends AutoDisposeNotifier<T> {
  _MutPodNotifier(this._onRead, this._onUpdate, this._onReset);

  final T Function(StateRef ref) _onRead;
  final void Function(StateRef ref, T value)? _onUpdate;
  final void Function(StateRef ref)? _onReset;

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
