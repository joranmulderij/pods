import 'package:http/http.dart' as http;
import 'package:pocketbase/pocketbase.dart';
import 'package:pods/pods.dart';

Pod<PocketBase> pocketBasePod(
  Pod<String> baseUrlPod, {
  Pod<String>? langPod,
  MutPod<AuthStore>? authStorePod,
  Pod<http.Client Function()>? httpClientFactoryPod,
}) {
  return Pod((ref) {
    final baseUrl = ref.watch(baseUrlPod());
    final lang = langPod != null ? ref.watch(langPod()) : "en-US";
    final authStore =
        authStorePod != null ? ref.watch(authStorePod()) : AuthStore();
    final httpClientFactory =
        httpClientFactoryPod != null ? ref.watch(httpClientFactoryPod()) : null;
    final pocketBase = PocketBase(
      baseUrl,
      lang: lang,
      authStore: authStore,
      httpClientFactory: httpClientFactory,
    );
    return pocketBase;
  });
}

MutFamAsyncPod<T, String> pocketBaseMutableRecordPod<T>({
  required String collectionName,
  required T Function(Map<String, dynamic> json) fromJson,
  required Map<String, dynamic> Function(T value) toJson,
  required Pod<PocketBase> pbClientPod,
}) {
  return MutFamAsyncPod(
    onCreate: (ref, value) async {
      return '';
    },
    onRead: (ref, id) async {
      final pbClient = ref.watch(pbClientPod());
      final record = await pbClient.collection(collectionName).getOne(id);
      return fromJson(record.toJson());
    },
    onUpdate: (ref, id, value) async {
      final pbClient = ref.watch(pbClientPod());
      final record = await pbClient
          .collection(collectionName)
          .update(id, body: toJson(value));
      return fromJson(record.toJson());
    },
    onDelete: (ref, id) async {
      final pbClient = ref.watch(pbClientPod());
      await pbClient.collection(collectionName).delete(id);
    },
  );
}

FamAsyncPod<T, String> pocketBaseRecordPod<T>({
  required String collectionName,
  required T Function(Map<String, dynamic> json) fromJson,
  required Pod<PocketBase> pbClientPod,
}) {
  return FamAsyncPod(
    (ref, id) async {
      final pbClient = ref.watch(pbClientPod());
      final record = await pbClient.collection(collectionName).getOne(id);
      return fromJson(record.toJson());
    },
  );
}
