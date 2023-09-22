import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:pods/pods.dart';

extension PodExtension<T> on Pod<T> {
  T watchWidget(WidgetRef ref) {
    return ref.watch(provider);
  }

  T readWidget(WidgetRef ref) {
    return ref.read(provider);
  }

  @useResult
  T refreshWidget(WidgetRef ref) {
    return ref.refresh(provider);
  }

  void listenWidget(
      WidgetRef ref, void Function(T? previous, T next) listener) {
    ref.listen(provider, listener);
  }

  T call(WidgetRef ref) {
    return ref.watch(provider);
  }
}
