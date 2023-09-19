// // ignore_for_file: avoid_catching_errors, avoid_dynamic_calls

// import 'package:riverpod/riverpod.dart';

// typedef RefType = dynamic;

// T readPod<T>(RefType ref, ProviderListenable<T> provider) {
//   try {
//     return ref.read(provider) as T;
//   } on NoSuchMethodError {
//     throw Exception('$ref does not have the method "read".');
//   }
// }

// T watchPod<T>(RefType ref, ProviderListenable<T> provider) {
//   try {
//     return ref.watch(provider) as T;
//   } on NoSuchMethodError {
//     throw Exception('$ref does not have the method "watch".');
//   }
// }

// void listenPod<T>(
//   RefType ref,
//   ProviderListenable<T> provider,
//   void Function(T?, T) listener,
// ) {
//   try {
//     ref.listen<T>(provider, listener);
//   } on NoSuchMethodError {
//     throw Exception('$ref does not have the method "listen".');
//   }
// }

// T readPodRefreshable<T>(RefType ref, Refreshable<T> future) {
//   try {
//     return ref.read(future) as T;
//   } on NoSuchMethodError {
//     throw Exception('$ref does not have the method "read".');
//   }
// }

// T watchPodRefreshable<T>(RefType ref, Refreshable<T> future) {
//   try {
//     return ref.watch(future) as T;
//   } on NoSuchMethodError {
//     throw Exception('$ref does not have the method "watch".');
//   }
// }
