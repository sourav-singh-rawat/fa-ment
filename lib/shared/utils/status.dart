sealed class Status<T> {
  const Status();

  factory Status.idle() => Idle();
  factory Status.loading({num? value}) => Loading(value: value);
  factory Status.failure({String? error}) => Failure(error: error);
  factory Status.partial({dynamic data}) => Partial(data: data);
  factory Status.success({dynamic data}) => Success(data: data);
}

final class Idle<T> extends Status<T> {}

final class Loading<T> extends Status<T> {
  final num? value;
  const Loading({this.value});
}

final class Failure<T> extends Status<T> {
  final String? error;
  const Failure({this.error});
}

final class Partial<T> extends Status<T> {
  final T? data;
  const Partial({this.data});
}

final class Success<T> extends Status<T> {
  final T? data;
  const Success({this.data});
}
