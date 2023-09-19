import 'package:riverpod/riverpod.dart';

class AsyncPod<T> {
  AsyncPod(this.onRead) : _provider = AutoDisposeFutureProvider(onRead);

  // AsyncPod.fromSync(Pod<T> pod)
  //     : onRead = ((ref) async => pod.onRead(ref)),
  //       _provider = AutoDisposeFutureProvider((ref) async => pod.read(ref));

  final Future<T> Function(AutoDisposeFutureProviderRef<T> ref) onRead;

  final AutoDisposeFutureProvider<T> _provider;

  AutoDisposeFutureProvider<T> call() => _provider;

  Refreshable<Future<T>> future() => _provider.future;
}
