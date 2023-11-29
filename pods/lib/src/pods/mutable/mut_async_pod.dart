import 'package:pods/pods.dart';
import 'package:pods/src/types.dart';
import 'package:riverpod/riverpod.dart';

abstract class MutAsyncPod<T> implements AsyncPod<T> {
  factory MutAsyncPod({
    required Future<T> Function(StateRef ref) onRead,
    Future<void> Function(StateRef ref, T value)? onUpdate,
    Future<void> Function(StateRef ref)? onReset,
  }) = _RiverpodMutAsyncPod;

  MutAsyncPod._();

  factory MutAsyncPod.simple({
    required AsyncValue<T> Function(StateRef ref) read,
    required Future<T> Function(StateRef ref) readFuture,
    required AsyncValue<T> Function(StateRef ref) watch,
    required Future<T> Function(StateRef ref) watchFuture,
    required Future<void> Function(StateRef ref, T value) update,
    required Future<void> Function(StateRef ref) reset,
    required void Function(
      StateRef ref,
      ListenerFunction<AsyncValue<T>> listener,
    ) listen,
  }) = _SimpleMutAsyncPod;

  Future<void> update(StateRef ref, T value);

  void reset(StateRef ref);

  void listen(StateRef ref, ListenerFunction<AsyncValue<T>> listener);

  MutPod<T> sync(T Function() defaultValue) {
    return MutPod<T>.simple(
      read: (ref) => watch(ref).value ?? defaultValue(),
      update: (ref, value) {
        if (value != null) update(ref, value);
      },
      reset: reset,
      listen: (ref, listener) {
        listen(ref, (previous, next) {
          listener(previous?.value, next.value as T);
        });
      },
    );
  }
}

class _SimpleMutAsyncPod<T> extends MutAsyncPod<T> {
  _SimpleMutAsyncPod({
    required Future<T> Function(StateRef ref) readFuture,
    required Future<T> Function(StateRef ref) watchFuture,
    required AsyncValue<T> Function(StateRef ref) watch,
    required AsyncValue<T> Function(StateRef ref) read,
    required Future<void> Function(StateRef ref, T value) update,
    required Future<void> Function(StateRef ref) reset,
    required void Function(
      StateRef ref,
      ListenerFunction<AsyncValue<T>> listener,
    ) listen,
  })  : _readFuture = readFuture,
        _watchFuture = watchFuture,
        _read = read,
        _watch = watch,
        _update = update,
        _reset = reset,
        _listen = listen,
        super._();

  final Future<T> Function(StateRef ref) _readFuture;
  final AsyncValue<T> Function(StateRef ref) _read;
  final Future<T> Function(StateRef ref) _watchFuture;
  final AsyncValue<T> Function(StateRef ref) _watch;
  final Future<void> Function(StateRef ref, T value) _update;
  final Future<void> Function(StateRef ref) _reset;
  final void Function(StateRef ref, ListenerFunction<AsyncValue<T>> listener)
      _listen;

  @override
  AsyncValue<T> read(StateRef ref) => _read(ref);
  @override
  Future<T> readFuture(StateRef ref) => _readFuture(ref);

  @override
  AsyncValue<T> watch(StateRef ref) => _watch.call(ref);
  @override
  Future<T> watchFuture(StateRef ref) => _watchFuture(ref);

  @override
  Future<void> update(StateRef ref, T value) => _update(ref, value);

  @override
  Future<void> reset(StateRef ref) => _reset(ref);

  @override
  void listen(StateRef ref, ListenerFunction<AsyncValue<T>> listener) =>
      _listen(ref, listener);
}

class _RiverpodMutAsyncPod<T> extends MutAsyncPod<T> {
  _RiverpodMutAsyncPod({
    required Future<T> Function(StateRef) onRead,
    Future<void> Function(StateRef ref, T value)? onUpdate,
    Future<void> Function(StateRef ref)? onReset,
  })  : _provider = AutoDisposeAsyncNotifierProvider(
          () => MutAsyncPodNotifier(onRead, onUpdate, onReset),
        ),
        super._();

  final AutoDisposeAsyncNotifierProvider<MutAsyncPodNotifier<T>, T> _provider;

  @override
  AsyncValue<T> watch(StateRef ref) => ref.watch(_provider);
  @override
  Future<T> watchFuture(StateRef ref) => ref.watch(_provider.future);

  @override
  AsyncValue<T> read(StateRef ref) => ref.read(_provider);
  @override
  Future<T> readFuture(StateRef ref) => ref.read(_provider.future);

  @override
  Future<void> update(StateRef ref, T value) async {
    await ref.read(_provider.notifier)._update(value);
  }

  @override
  Future<void> reset(StateRef ref) async {
    await ref.read(_provider.notifier)._reset();
  }

  @override
  void listen(StateRef ref, ListenerFunction<AsyncValue<T>> listener) {
    ref.listen(_provider, listener);
  }
}

class MutAsyncPodNotifier<T> extends AutoDisposeAsyncNotifier<T> {
  MutAsyncPodNotifier(this.onRead, this.onUpdate, this.onReset);

  final Future<T> Function(StateRef ref) onRead;
  final Future<void> Function(StateRef ref, T value)? onUpdate;
  final Future<void> Function(StateRef ref)? onReset;

  Future<void> _update(T value) async {
    state = AsyncValue.data(value);
  }

  Future<void> _reset() async {
    final value = await onRead(ref.s);
    state = AsyncValue.data(value);
  }

  @override
  Future<T> build() {
    return onRead(ref.s);
  }
}
