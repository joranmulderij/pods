import 'package:pods/pods.dart';

abstract class Cachable {
  DateTime get lastUpdated;
}

extension on Cachable {
  bool isOld(Duration? duration) {
    if (duration == null) {
      return false;
    }
    final cacheAge = DateTime.now().difference(lastUpdated);
    return cacheAge > duration;
  }
}

class CachingMutFamAsyncPod<T extends Cachable, A>
    extends MutFamAsyncPod<T, A> {
  CachingMutFamAsyncPod({
    required this.cachePod,
    required this.primaryPod,
    this.maxCacheAge,
  });

  final MutFamAsyncPod<T, A> primaryPod;
  final MutFamAsyncPod<T?, A> cachePod;
  final Duration? maxCacheAge;

  @override
  Future<A> onCreate(StateRef ref, T value) {
    return primaryPod.create(ref, value);
  }

  @override
  Future<void> onDelete(StateRef ref, A arg) async {
    await primaryPod.delete(ref, arg);
    await cachePod.delete(ref, arg);
  }

  @override
  Future<T> onRead(StateRef ref, A arg) async {
    final cache = await cachePod.readFuture(ref, arg);
    if (cache != null && !cache.isOld(maxCacheAge)) {
      return cache;
    }
    return await primaryPod.readFuture(ref, arg);
  }

  @override
  Future<T?> onUpdate(StateRef ref, A arg, T value) async {
    await primaryPod.update(ref, arg, value);
    await cachePod.update(ref, arg, value);
    return null;
  }
}

MutAsyncPod<T> cachingMutAsyncPod<T extends Cachable>(
  MutAsyncPod<T> primaryPod,
  MutAsyncPod<T?> cachePod, {
  Duration? maxCacheAge,
}) {
  return MutAsyncPod(
    onRead: (ref) async {
      final cache = await cachePod.readFuture(ref);
      if (cache != null && !cache.isOld(maxCacheAge)) {
        return cache;
      }
      return await primaryPod.readFuture(ref);
    },
    onReset: (ref) async {
      await primaryPod.reset(ref);
      await cachePod.reset(ref);
    },
    onUpdate: (ref, value) async {
      await primaryPod.put(ref, value);
      await cachePod.put(ref, value);
    },
  );
}
