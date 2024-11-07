import 'package:pods/pods.dart';
import 'package:pods/src/types.dart';
import 'package:pods/src/utils.dart';
import 'package:riverpod/riverpod.dart';

abstract class MutFamAsyncPod<T, A> implements FamAsyncPod<T, A> {
  factory MutFamAsyncPod.cached({
    required Future<A> Function(PodRef ref, T value) onCreate,
    required Future<T> Function(PodRef ref, A arg) onRead,
    required Future<T?> Function(PodRef ref, A arg, T value) onUpdate,
    required Future<void> Function(PodRef ref, A arg) onDelete,
  }) = RiverpodMutFamAsyncPod<T, A>;

  factory MutFamAsyncPod.simple({
    required Future<A> Function(PodRef ref, T value) create,
    required AsyncValue<T> Function(PodRef ref, A arg) read,
    required Future<T> Function(PodRef ref, A arg) readFuture,
    required AsyncValue<T> Function(PodRef ref, A arg) watch,
    required Future<T> Function(PodRef ref, A arg) watchFuture,
    required Future<void> Function(PodRef ref, A arg) delete,
    required Future<T?> Function(PodRef ref, A arg, T value) update,
    required void Function(
      PodRef ref,
      A arg,
      ListenerFunction<AsyncValue<T>> listener,
    ) listen,
  }) = _SimpleMutFamAsyncPod<T, A>;

  MutFamAsyncPod._();

  @override
  AsyncValue<T> read(PodRef ref, A arg);

  @override
  Future<T> readFuture(PodRef ref, A arg);

  @override
  AsyncValue<T> watch(PodRef ref, A arg);

  @override
  Future<T> watchFuture(PodRef ref, A arg);

  Future<void> update(PodRef ref, A arg, T value);

  Future<void> delete(PodRef ref, A arg);

  Future<A> create(PodRef ref, T value);

  void listen(
    PodRef ref,
    A arg,
    ListenerFunction<AsyncValue<T>> listener,
  );

  MutAsyncPod<T> child(A arg) {
    return MutAsyncPod<T>.simple(
      read: (ref) => this.read(ref, arg),
      update: (ref, value) => this.update(ref, arg, value),
      reset: (ref) => this.delete(ref, arg),
      readFuture: (ref) => this.readFuture(ref, arg),
      watch: (ref) => this.watch(ref, arg),
      watchFuture: (ref) => this.watchFuture(ref, arg),
      listen: (ref, listener) => this.listen(ref, arg, listener),
    );
  }

  MutFamAsyncPod<Tchild, A> property<Tchild>({
    required Tchild Function() defaultChild,
    required Tchild Function(T parent) getChild,
    required T Function(T parent, Tchild child) updateParent,
  }) {
    return MutFamAsyncPod.simple(
      create: (ref, value) async {
        throw UnimplementedError();
      },
      readFuture: (ref, arg) async {
        final value = await this.readFuture(ref, arg);
        return getChild(value);
      },
      watchFuture: (ref, arg) async {
        final value = await this.watchFuture(ref, arg);
        return getChild(value);
      },
      read: (ref, arg) {
        final value = this.read(ref, arg);
        return value.mapData(getChild);
      },
      watch: (ref, arg) {
        final value = this.watch(ref, arg);
        return value.mapData(getChild);
      },
      listen: (ref, arg, listener) {
        return this.listen(ref, arg, (previous, next) {
          listener(
            previous?.mapData(getChild),
            next.mapData(getChild),
          );
        });
      },
      update: (ref, arg, value) async {
        final parent = await this.watchFuture(ref, arg);
        final updatedParent = updateParent(parent, value);
        await this.update(ref, arg, updatedParent);
        return value;
      },
      delete: (ref, arg) async {
        final parent = await this.watchFuture(ref, arg);
        final updatedParent = updateParent(parent, defaultChild());
        await this.update(ref, arg, updatedParent);
      },
    );
  }
}

class _SimpleMutFamAsyncPod<T, A> extends MutFamAsyncPod<T, A> {
  _SimpleMutFamAsyncPod({
    required Future<A> Function(PodRef ref, T value) create,
    required AsyncValue<T> Function(PodRef ref, A arg) read,
    required Future<T> Function(PodRef ref, A arg) readFuture,
    required AsyncValue<T> Function(PodRef ref, A arg) watch,
    required Future<T> Function(PodRef ref, A arg) watchFuture,
    required Future<void> Function(PodRef ref, A arg) delete,
    required Future<T?> Function(PodRef ref, A arg, T value) update,
    required void Function(
      PodRef ref,
      A arg,
      ListenerFunction<AsyncValue<T>> listener,
    ) listen,
  })  : _create = create,
        _read = read,
        _readFuture = readFuture,
        _watch = watch,
        _watchFuture = watchFuture,
        _delete = delete,
        _update = update,
        _listen = listen,
        super._();

  final Future<A> Function(PodRef ref, T value) _create;
  final AsyncValue<T> Function(PodRef ref, A arg) _read;
  final Future<T> Function(PodRef ref, A arg) _readFuture;
  final AsyncValue<T> Function(PodRef ref, A arg) _watch;
  final Future<T> Function(PodRef ref, A arg) _watchFuture;
  final Future<void> Function(PodRef ref, A arg) _delete;
  final Future<T?> Function(PodRef ref, A arg, T value) _update;
  final void Function(PodRef ref, A arg, ListenerFunction<AsyncValue<T>>)
      _listen;

  @override
  Future<A> create(PodRef ref, T value) => _create(ref, value);

  @override
  AsyncValue<T> read(PodRef ref, A arg) => _read(ref, arg);

  @override
  Future<T> readFuture(PodRef ref, A arg) => _readFuture(ref, arg);

  @override
  AsyncValue<T> watch(PodRef ref, A arg) => _watch(ref, arg);

  @override
  Future<T> watchFuture(PodRef ref, A arg) => _watchFuture(ref, arg);

  @override
  Future<void> delete(PodRef ref, A arg) => _delete(ref, arg);

  @override
  Future<T?> update(PodRef ref, A arg, T value) => _update(ref, arg, value);

  @override
  void listen(
    PodRef ref,
    A arg,
    ListenerFunction<AsyncValue<T>> listener,
  ) =>
      _listen(ref, arg, listener);
}

class RiverpodMutFamAsyncPod<T, A> extends MutFamAsyncPod<T, A> {
  RiverpodMutFamAsyncPod({
    required Future<A> Function(PodRef ref, T value) onCreate,
    required Future<T> Function(PodRef ref, A arg) onRead,
    required Future<T?> Function(PodRef ref, A arg, T value) onUpdate,
    required Future<void> Function(PodRef ref, A arg) onDelete,
  })  : _onCreate = onCreate,
        _onUpdate = onUpdate,
        _onDelete = onDelete,
        _provider = AutoDisposeAsyncNotifierProviderFamily(
          () => MutFamAsyncPodNotifier<T, A>(onRead),
        ),
        super._();

  final Future<A> Function(PodRef ref, T value) _onCreate;
  final Future<T?> Function(PodRef ref, A arg, T value) _onUpdate;
  final Future<void> Function(PodRef ref, A arg) _onDelete;

  late final AutoDisposeAsyncNotifierProviderFamily<
      MutFamAsyncPodNotifier<T, A>, T, A> _provider;

  @override
  AsyncValue<T> read(PodRef ref, A arg) => ref.read(_provider.call(arg));

  @override
  Future<T> readFuture(PodRef ref, A arg) =>
      ref.read(_provider.call(arg).future);

  @override
  AsyncValue<T> watch(PodRef ref, A arg) => ref.watch(_provider.call(arg));

  @override
  Future<T> watchFuture(PodRef ref, A arg) =>
      ref.watch(_provider.call(arg).future);

  @override
  Future<void> update(PodRef ref, A arg, T value) async {
    final oldValue = read(ref, arg);
    if (value == oldValue.value) return;
    final notifier = ref.read(_provider(arg).notifier);
    notifier._set(AsyncValue.data(value));
    try {
      await _onUpdate(ref, arg, value);
    } catch (e) {
      print('update failed');
      notifier._set(oldValue);
    }
  }

  @override
  Future<void> delete(PodRef ref, A arg) async {
    final oldValue = read(ref, arg);
    final notifier = ref.read(_provider(arg).notifier);
    notifier._set(const AsyncValue.loading());
    try {
      await _onDelete(ref, arg);
    } catch (e) {
      notifier._set(oldValue);
    }
  }

  @override
  Future<A> create(PodRef ref, T value) async {
    final arg = await _onCreate(ref, value);
    final notifier = ref.read(_provider(arg).notifier);
    notifier._set(AsyncValue.data(value));
    return arg;
  }

  @override
  void listen(
    PodRef ref,
    A arg,
    ListenerFunction<AsyncValue<T>> listener,
  ) {
    ref.listen<AsyncValue<T>>(_provider(arg), listener);
  }
}

class MutFamAsyncPodNotifier<T, A>
    extends AutoDisposeFamilyAsyncNotifier<T, A> {
  MutFamAsyncPodNotifier(this._onRead);

  final Future<T> Function(PodRef ref, A arg) _onRead;

  @override
  Future<T> build(A arg) {
    return _onRead(ref.s, arg);
  }

  void _set(AsyncValue<T> value) {
    state = value;
  }
}
