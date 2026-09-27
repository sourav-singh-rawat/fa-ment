sealed class AsyncState<T> {
  const AsyncState();

  factory AsyncState.idle() => AsyncIdle();
  factory AsyncState.loading({num? value}) => AsyncLoading(value: value);
  factory AsyncState.failure({String? error}) => AsyncFailure(error: error);
  factory AsyncState.partial({T? data}) => AsyncPartial<T>(data: data);
  factory AsyncState.success({T? data}) => AsyncSuccess<T>(data: data);
}

final class AsyncIdle<T> extends AsyncState<T> {}

final class AsyncLoading<T> extends AsyncState<T> {
  final num? value;
  const AsyncLoading({this.value});
}

final class AsyncFailure<T> extends AsyncState<T> {
  final String? error;
  const AsyncFailure({this.error});
}

final class AsyncPartial<T> extends AsyncState<T> {
  final T? data;
  const AsyncPartial({this.data});
}

final class AsyncSuccess<T> extends AsyncState<T> {
  final T? data;
  const AsyncSuccess({this.data});
}
