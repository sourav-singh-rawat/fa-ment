import 'package:equatable/equatable.dart' show Equatable;

class ValidState<T> extends Equatable {
  final T value;
  final bool hasError;
  final String errorText;
  const new(this.value, {this.hasError = false, this.errorText = ''});

  const ValidState.init(T value) : this(value);

  ValidState<T> copyWith({T? value, bool? hasError, String? errorText}) {
    hasError = hasError ?? errorText?.isNotEmpty;

    return ValidState<T>(
      value ?? this.value,
      hasError: hasError ?? this.hasError,
      errorText: errorText ?? this.errorText,
    );
  }

  @override
  List<Object?> get props => [value, hasError, errorText];
}
