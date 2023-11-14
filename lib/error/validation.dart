class ValidationError extends Error {
  final Map<String, String> errors;

  ValidationError(this.errors);
}
