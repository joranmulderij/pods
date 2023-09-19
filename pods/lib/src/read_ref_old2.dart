// import 'package:riverpod/riverpod.dart';

// typedef RefType = dynamic;

// T readPod<T>(RefType ref, ProviderListenable<T> provider) {
//   if (ref is Ref) {
//     return ref.read(provider);
//   } else if (ref is ProviderContainer) {
//     return ref.read(provider);
//   } else {
//     throw Exception('Unknown ref type');
//   }
// }

// T watchPod<T>(RefType ref, ProviderListenable<T> provider) {
//   if (ref is AutoDisposeRef) {
//     return ref.watch(provider);
//   } else if (ref is ProviderContainer) {
//     throw Exception('Cannot watch a Pod from a ProviderContainer');
//   } else {
//     throw Exception('Unknown ref type');
//   }
// }

// void listenPod<T>(
//   RefType ref,
//   ProviderListenable<T> provider,
//   void Function(T?, T) listener,
// ) {
//   if (ref is AutoDisposeRef) {
//     ref.listen(provider, listener);
//   } else if (ref is ProviderContainer) {
//     ref.listen(provider, listener);
//   } else {
//     throw Exception('Unknown ref type');
//   }
// }

// AsyncValue<T> readAsyncPod<T>(
//   RefType ref,
//   ProviderListenable<AsyncValue<T>> provider,
// ) {
//   if (ref is Ref) {
//     return ref.read(provider);
//   } else if (ref is ProviderContainer) {
//     return ref.read(provider);
//   } else {
//     throw Exception('Unknown ref type');
//   }
// }

// AsyncValue<T> watchAsyncPod<T>(
//   RefType ref,
//   ProviderListenable<AsyncValue<T>> provider,
// ) {
//   if (ref is AutoDisposeRef) {
//     return ref.watch(provider);
//   } else if (ref is ProviderContainer) {
//     throw Exception('Cannot watch a Pod from a ProviderContainer');
//   } else {
//     throw Exception('Unknown ref type');
//   }
// }

// T readPodRefreshable<T>(RefType ref, Refreshable<T> future) {
//   if (ref is Ref) {
//     return ref.read(future);
//   } else if (ref is ProviderContainer) {
//     return ref.read(future);
//   } else {
//     throw Exception('Unknown ref type');
//   }
// }

// T watchPodRefreshable<T>(RefType ref, Refreshable<T> future) {
//   if (ref is AutoDisposeRef) {
//     return ref.watch(future);
//   } else if (ref is ProviderContainer) {
//     throw Exception('Cannot watch a Pod from a ProviderContainer');
//   } else {
//     throw Exception('Unknown ref type');
//   }
// }
