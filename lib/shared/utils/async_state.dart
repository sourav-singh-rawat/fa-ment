import 'package:equatable/equatable.dart' show Equatable;

sealed class AsyncState<T> extends Equatable {
  const AsyncState();

  factory AsyncState.idle() => AsyncIdle();
  factory AsyncState.loading({num? value}) => AsyncLoading(value: value);
  factory AsyncState.failure({String? error}) => AsyncFailure(error: error);
  factory AsyncState.partial({T? data}) => AsyncPartial<T>(data: data);
  factory AsyncState.success({T? data}) => AsyncSuccess<T>(data: data);
}

final class AsyncIdle<T> extends AsyncState<T> {
  @override
  List<Object?> get props => const [];
}

final class AsyncLoading<T> extends AsyncState<T> {
  final num? value;
  const AsyncLoading({this.value});

  @override
  List<Object?> get props => [value];
}

final class AsyncFailure<T> extends AsyncState<T> {
  final String? error;
  const AsyncFailure({this.error});

  @override
  List<Object?> get props => [error];
}

final class AsyncPartial<T> extends AsyncState<T> {
  final T? data;
  const AsyncPartial({this.data});

  @override
  List<Object?> get props => [data];
}

final class AsyncSuccess<T> extends AsyncState<T> {
  final T? data;
  const AsyncSuccess({this.data});

  @override
  List<Object?> get props => [data];
}
