class ValidationError<E> extends Error {
  final Map<String, E> errors;

  ValidationError(this.errors);
}
