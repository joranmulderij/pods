import 'package:riverpod/riverpod.dart';

// ignore: one_member_abstracts
abstract class PodBase<T, Provider extends ProviderBase<T>> {
  Provider call();
}

abstract class AsyncPodBase<T, Provider extends ProviderBase<AsyncValue<T>>>
    extends PodBase<AsyncValue<T>, Provider> {
  @override
  Provider call();

  Refreshable<Future<T>> future();
}

// class FamilyPodBase<T, Provider extends ProviderBase<T>,
//     Family extends FamilyBase<T, Provider>> extends PodBase<T, Provider> {
//   FamilyPodBase(this.family, this.name);

//   final Family family;
//   final String name;

//   @override
//   Provider call() => family(name);
// }
