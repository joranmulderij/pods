import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pods/pods.dart';

extension PodExtension<T> on ImmutablePod<T> {
  T call(WidgetRef ref) => watch(ref.s);
}

extension AsyncPodExtension<T> on AsyncPod<T> {
  AsyncValue<T> call(WidgetRef ref) => watch(ref.s);
}

extension FamPodExtension<T, A> on FamPod<T, A> {
  T call(WidgetRef ref, A arg) => watch(ref.s, arg);
}

extension FamAsyncPodExtension<T, A> on FamAsyncPod<T, A> {
  AsyncValue<T> call(WidgetRef ref, A arg) => watch(ref.s, arg);
}

extension WidgetRefExtension on WidgetRef {
  StateRef get s => _WidgetRefStateRef(this);
}

class _WidgetRefStateRef extends StateRef {
  _WidgetRefStateRef(this._ref);

  final WidgetRef _ref;

  @override
  void listen<Result>(ProviderListenable<Result> provider,
      void Function(Result? previous, Result next) listener) {
    _ref.listen<Result>(provider, listener);
  }

  @override
  Result read<Result>(ProviderListenable<Result> provider) {
    return _ref.read(provider);
  }

  @override
  Result watch<Result>(ProviderListenable<Result> provider) {
    return _ref.watch(provider);
  }
}
