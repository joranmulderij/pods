import 'package:pods/pods.dart';
import 'package:pods/src/types.dart';
import 'package:riverpod/riverpod.dart';

abstract class MutAsyncPod<T> implements AsyncPod<T> {
  factory MutAsyncPod({
    required Future<T> Function(PodRef ref) onRead,
    Future<void> Function(PodRef ref, T value)? onUpdate,
    Future<void> Function(PodRef ref)? onReset,
  }) = _RiverpodMutAsyncPod;

  MutAsyncPod._();

  factory MutAsyncPod.simple({
    required AsyncValue<T> Function(PodRef ref) read,
    required Future<T> Function(PodRef ref) readFuture,
    required AsyncValue<T> Function(PodRef ref) watch,
    required Future<T> Function(PodRef ref) watchFuture,
    required Future<void> Function(PodRef ref, T value) update,
    required Future<void> Function(PodRef ref) reset,
    required void Function(
      PodRef ref,
      ListenerFunction<AsyncValue<T>> listener,
    ) listen,
  }) = _SimpleMutAsyncPod;

  Future<void> update(PodRef ref, T value);

  void reset(PodRef ref);

  void listen(PodRef ref, ListenerFunction<AsyncValue<T>> listener);

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
    required Future<T> Function(PodRef ref) readFuture,
    required Future<T> Function(PodRef ref) watchFuture,
    required AsyncValue<T> Function(PodRef ref) watch,
    required AsyncValue<T> Function(PodRef ref) read,
    required Future<void> Function(PodRef ref, T value) update,
    required Future<void> Function(PodRef ref) reset,
    required void Function(
      PodRef ref,
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

  final Future<T> Function(PodRef ref) _readFuture;
  final AsyncValue<T> Function(PodRef ref) _read;
  final Future<T> Function(PodRef ref) _watchFuture;
  final AsyncValue<T> Function(PodRef ref) _watch;
  final Future<void> Function(PodRef ref, T value) _update;
  final Future<void> Function(PodRef ref) _reset;
  final void Function(PodRef ref, ListenerFunction<AsyncValue<T>> listener)
      _listen;

  @override
  AsyncValue<T> read(PodRef ref) => _read(ref);
  @override
  Future<T> readFuture(PodRef ref) => _readFuture(ref);

  @override
  AsyncValue<T> watch(PodRef ref) => _watch.call(ref);
  @override
  Future<T> watchFuture(PodRef ref) => _watchFuture(ref);

  @override
  Future<void> update(PodRef ref, T value) => _update(ref, value);

  @override
  Future<void> reset(PodRef ref) => _reset(ref);

  @override
  void listen(PodRef ref, ListenerFunction<AsyncValue<T>> listener) =>
      _listen(ref, listener);
}

class _RiverpodMutAsyncPod<T> extends MutAsyncPod<T> {
  _RiverpodMutAsyncPod({
    required Future<T> Function(PodRef) onRead,
    Future<void> Function(PodRef ref, T value)? onUpdate,
    Future<void> Function(PodRef ref)? onReset,
  })  : _provider = AutoDisposeAsyncNotifierProvider(
          () => MutAsyncPodNotifier(onRead, onUpdate, onReset),
        ),
        super._();

  final AutoDisposeAsyncNotifierProvider<MutAsyncPodNotifier<T>, T> _provider;

  @override
  AsyncValue<T> watch(PodRef ref) => ref.watch(_provider);
  @override
  Future<T> watchFuture(PodRef ref) => ref.watch(_provider.future);

  @override
  AsyncValue<T> read(PodRef ref) => ref.read(_provider);
  @override
  Future<T> readFuture(PodRef ref) => ref.read(_provider.future);

  @override
  Future<void> update(PodRef ref, T value) async {
    await ref.read(_provider.notifier)._update(value);
  }

  @override
  Future<void> reset(PodRef ref) async {
    await ref.read(_provider.notifier)._reset();
  }

  @override
  void listen(PodRef ref, ListenerFunction<AsyncValue<T>> listener) {
    ref.listen(_provider, listener);
  }
}

class MutAsyncPodNotifier<T> extends AutoDisposeAsyncNotifier<T> {
  MutAsyncPodNotifier(this.onRead, this.onUpdate, this.onReset);

  final Future<T> Function(PodRef ref) onRead;
  final Future<void> Function(PodRef ref, T value)? onUpdate;
  final Future<void> Function(PodRef ref)? onReset;

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
