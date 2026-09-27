import 'package:equatable/equatable.dart' show Equatable;

class Valid<T> extends Equatable {
  final T value;
  final bool hasError;
  final String errorText;
  const new(this.value, {this.hasError = false, this.errorText = ''});

  const Valid.init(T value) : this(value);

  Valid<T> copyWith({T? value, bool? hasError, String? errorText}) {
    hasError = hasError ?? errorText?.isNotEmpty;

    return Valid<T>(
      value ?? this.value,
      hasError: hasError ?? this.hasError,
      errorText: errorText ?? this.errorText,
    );
  }

  @override
  List<Object?> get props => [value, hasError, errorText];
}
