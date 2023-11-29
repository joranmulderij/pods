import 'package:http/http.dart' as http;
import 'package:pocketbase/pocketbase.dart';
import 'package:pods/pods.dart';

Future<void> sleep(Duration? duration) async {
  if (duration == null) return;
  await Future.delayed(duration);
}

ImmutablePod<PocketBase> pocketBasePod(
  ImmutablePod<String> baseUrlPod, {
  ImmutablePod<String>? langPod,
  MutPod<AuthStore>? authStorePod,
  ImmutablePod<http.Client Function()>? httpClientFactoryPod,
}) {
  return ImmutablePod((ref) {
    final pocketBase = PocketBase(
      baseUrlPod.watch(ref),
      lang: langPod != null ? langPod.watch(ref) : "en-US",
      authStore: authStorePod != null ? authStorePod.watch(ref) : AuthStore(),
      httpClientFactory: httpClientFactoryPod?.watch(ref),
    );
    return pocketBase;
  });
}

MutFamAsyncPod<T, String> pocketBaseMutableRecordPod<T>({
  required String collectionName,
  required T Function(Map<String, dynamic> json) fromJson,
  required Map<String, dynamic> Function(T value) toJson,
  required ImmutablePod<PocketBase> pbClientPod,
  ImmutablePod<Duration>? debounceDurationPod,
}) {
  return MutFamAsyncPod(
    onCreate: (ref, value) async {
      final pbClient = pbClientPod.watch(ref);
      await sleep(debounceDurationPod?.watch(ref));
      final record =
          await pbClient.collection(collectionName).create(body: toJson(value));
      return record.id;
    },
    onRead: (ref, id) async {
      final pbClient = pbClientPod.watch(ref);
      await sleep(debounceDurationPod?.watch(ref));
      final record = await pbClient.collection(collectionName).getOne(id);
      return fromJson(record.toJson());
    },
    onUpdate: (ref, id, value) async {
      final pbClient = pbClientPod.watch(ref);
      await sleep(debounceDurationPod?.watch(ref));
      final record = await pbClient
          .collection(collectionName)
          .update(id, body: toJson(value));
      return fromJson(record.toJson());
    },
    onDelete: (ref, id) async {
      final pbClient = pbClientPod.watch(ref);
      await sleep(debounceDurationPod?.watch(ref));
      await pbClient.collection(collectionName).delete(id);
    },
  );
}

FamAsyncPod<T, String> pocketBaseRecordPod<T>({
  required String collectionName,
  required T Function(Map<String, dynamic> json) fromJson,
  required ImmutablePod<PocketBase> pbClientPod,
}) {
  return FamAsyncPod(
    (ref, id) async {
      final pbClient = pbClientPod.watch(ref);
      final record = await pbClient.collection(collectionName).getOne(id);
      return fromJson(record.toJson());
    },
  );
}
