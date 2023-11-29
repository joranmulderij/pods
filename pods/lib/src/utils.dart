import 'package:riverpod/riverpod.dart';

extension ConvertAsyncValue<T> on AsyncValue<T> {
  AsyncValue<T2> mapData<T2>(T2 Function(T) convert) {
    return when(
      data: (data) => AsyncValue.data(convert(data)),
      loading: AsyncLoading.new,
      error: AsyncError.new,
    );
  }
}
