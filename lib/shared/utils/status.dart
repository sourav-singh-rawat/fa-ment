sealed class Status {
  const Status();

  factory Status.idle() => Idle();
  factory Status.loading({num? value}) => Loading(value: value);
  factory Status.failure({String? error}) => Failure(error: error);
  factory Status.partial({dynamic data}) => Partial(data: data);
  factory Status.success({dynamic data}) => Success(data: data);
}

final class Idle extends Status {}

final class Loading extends Status {
  final num? value;
  const Loading({this.value});
}

final class Failure extends Status {
  final String? error;
  const Failure({this.error});
}

final class Partial<T> extends Status {
  final T? data;
  const Partial({this.data});
}

final class Success<T> extends Status {
  final T? data;
  const Success({this.data});
}
