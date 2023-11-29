import 'package:riverpod/riverpod.dart';

abstract class StateRef {
  const StateRef();

  Result read<Result>(ProviderListenable<Result> provider);

  Result watch<Result>(ProviderListenable<Result> provider);

  void listen<Result>(
    ProviderListenable<Result> provider,
    void Function(Result? previous, Result next) listener,
  );
}

class StateContainer implements StateRef {
  StateContainer() : _container = ProviderContainer();

  const StateContainer.fromContainer(this._container);

  final ProviderContainer _container;

  @override
  Result read<Result>(ProviderListenable<Result> provider) =>
      _container.read(provider);

  @override
  Result watch<Result>(ProviderListenable<Result> provider) =>
      throw UnimplementedError('Cannot watch on Container');

  @override
  void listen<Result>(
    ProviderListenable<Result> provider,
    void Function(Result? previous, Result next) listener,
  ) {
    _container.listen<Result>(provider, listener);
  }
}

class _RefPodRef<RefType> implements StateRef {
  const _RefPodRef(this._ref);

  final AutoDisposeRef<RefType> _ref;

  @override
  Result read<Result>(ProviderListenable<Result> provider) =>
      _ref.read(provider);

  @override
  Result watch<Result>(ProviderListenable<Result> provider) =>
      _ref.watch(provider);

  @override
  void listen<Result>(
    ProviderListenable<Result> provider,
    void Function(Result? previous, Result next) listener,
  ) {
    _ref.listen(provider, listener);
  }
}

extension RefToPodRef<T> on AutoDisposeRef<T> {
  StateRef get s {
    return _RefPodRef<T>(this);
  }
}
