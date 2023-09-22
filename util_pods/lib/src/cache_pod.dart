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

MutFamAsyncPod<T, A> cachingMutFamAsyncPod<T extends Cachable, A>(
  MutFamAsyncPod<T, A> primaryPod,
  MutFamAsyncPod<T?, A> cachePod, {
  Duration? maxCacheAge,
  required A defaultArg,
}) {
  return MutFamAsyncPod(
    onCreate: (ref, value) {
      final notifier = ref.read(primaryPod(defaultArg).notifier);
      return notifier.create(value);
    },
    onRead: (ref, arg) async {
      final cache = await ref.read(cachePod(arg).future);
      if (cache != null && !cache.isOld(maxCacheAge)) {
        return cache;
      }
      return await ref.read(primaryPod(arg).future);
    },
    onDelete: (ref, arg) async {
      await ref.read(primaryPod(arg).notifier).delete();
      await ref.read(cachePod(arg).notifier).delete();
    },
    onUpdate: (ref, arg, value) async {
      await ref.read(primaryPod(arg).notifier).put(value);
      await ref.read(cachePod(arg).notifier).put(value);
      return null;
    },
  );
}

MutAsyncPod<T> cachingMutAsyncPod<T extends Cachable>(
  MutAsyncPod<T> primaryPod,
  MutAsyncPod<T?> cachePod, {
  Duration? maxCacheAge,
}) {
  return MutAsyncPod(
    onRead: (ref) async {
      final cache = await ref.read(cachePod().future);
      if (cache != null && !cache.isOld(maxCacheAge)) {
        return cache;
      }
      return await ref.read(primaryPod().future);
    },
    onReset: (ref) async {
      await ref.read(primaryPod().notifier).reset();
      await ref.read(cachePod().notifier).reset();
    },
    onUpdate: (ref, value) async {
      await ref.read(primaryPod().notifier).put(value);
      await ref.read(cachePod().notifier).put(value);
    },
  );
}
