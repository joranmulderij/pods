import 'package:meta/meta.dart';
import 'package:riverpod/riverpod.dart';

class MutFamAsyncPod<T, A> {
  MutFamAsyncPod({
    required this.onCreate,
    required this.onRead,
    required this.onUpdate,
    required this.onDelete,
  }) : _provider = AutoDisposeAsyncNotifierProviderFamily(
          () => MutFamAsyncPodNotifier(onCreate, onRead, onUpdate, onDelete),
        );

  factory MutFamAsyncPod.fuse(List<MutFamAsyncPod<T, A>> pods) {
    return MutFamAsyncPod(
      onCreate: (ref, value) {
        for (final pod in pods) {
          try {
            return pod.onCreate(ref, value);
          } catch (_) {
            continue;
          }
        }
        throw Exception('No pod was able to create');
      },
      onRead: (ref, arg) async {
        for (final pod in pods) {
          try {
            return await pod.onRead(ref, arg);
          } catch (_) {
            continue;
          }
        }
        throw Exception('No pod was able to read');
      },
      onUpdate: (ref, arg, value) async {
        for (final pod in pods) {
          await pod.onUpdate(ref, arg, value);
        }
        return null;
      },
      onDelete: (ref, arg) async {
        for (final pod in pods) {
          await pod.onDelete(ref, arg);
        }
      },
    );
  }

  final AutoDisposeAsyncNotifierProviderFamily<MutFamAsyncPodNotifier<T, A>, T,
      A> _provider;

  @protected
  final Future<A> Function(AutoDisposeAsyncNotifierProviderRef<T> ref, T value)
      onCreate;
  @protected
  final Future<T> Function(AutoDisposeAsyncNotifierProviderRef<T> ref, A arg)
      onRead;
  @protected
  final Future<T?> Function(
    AutoDisposeAsyncNotifierProviderRef<T> ref,
    A arg,
    T value,
  ) onUpdate;
  @protected
  final Future<void> Function(AutoDisposeAsyncNotifierProviderRef<T> ref, A arg)
      onDelete;

  AutoDisposeFamilyAsyncNotifierProvider<MutFamAsyncPodNotifier<T, A>, T, A>
      call(A arg) => _provider.call(arg);

  // Refreshable<MutFamAsyncPodNotifier<T, A>> notifier(A arg) =>
  //     _provider(arg).notifier;

  // Refreshable<Future<T>> future(A arg) => _provider(arg).future;
}

class MutFamAsyncPodNotifier<T, A>
    extends AutoDisposeFamilyAsyncNotifier<T, A> {
  MutFamAsyncPodNotifier(
    this._onCreate,
    this._onRead,
    this._onUpdate,
    this._onDelete,
  );

  final Future<A> Function(AutoDisposeAsyncNotifierProviderRef<T> ref, T value)
      _onCreate;
  final Future<T> Function(AutoDisposeAsyncNotifierProviderRef<T> ref, A arg)
      _onRead;
  final Future<T?> Function(
    AutoDisposeAsyncNotifierProviderRef<T> ref,
    A arg,
    T value,
  ) _onUpdate;
  final Future<void> Function(AutoDisposeAsyncNotifierProviderRef<T> ref, A arg)
      _onDelete;

  Future<A> create(T value) async {
    return _onCreate(ref, value);
  }

  @override
  Future<T> build(A arg) {
    return _onRead(ref, arg);
  }

  Future<void> put(T value) async {
    await _onUpdate(ref, arg, value);
    state = AsyncValue.data(value);
  }

  Future<void> delete() async {
    await _onDelete(ref, arg);
    state = AsyncValue.data(await _onRead(ref, arg));
  }
}
