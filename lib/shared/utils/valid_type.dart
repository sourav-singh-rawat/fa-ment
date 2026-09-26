class Valid<T> {
  final T value;
  final bool hasError;
  final String errorText;
  const new(this.value, {this.hasError = false, this.errorText = ''});

  Valid copyWith({T? value, bool? hasError, String? errorText}) {
    hasError = hasError ?? errorText?.isNotEmpty;

    return Valid(
      value ?? this.value,
      hasError: hasError ?? this.hasError,
      errorText: errorText ?? this.errorText,
    );
  }
}
