abstract class Validator<T, E> {
  Map<String, E> validate(T item);
}
