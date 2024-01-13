# Budg1

Budg1 Flutter project.

![Test](https://github.com/h4j4x/budgi/actions/workflows/flutter-test.yml/badge.svg)

## Getting Started

### Configuration

Create config in file `config.json`:

```json
{
  "DATA_PROVIDER": "spring",
  "SPRING_URL": "http://localhost:8080/api/v1"
}
```

### Run the application

Run the app specifying the config file:

```shell
flutter run --dart-define-from-file=config.json
```

### Testing

Generate mocks and test:

```shell
dart run build_runner build
flutter test
```

If you get an error with **build_runner**, delete [.dart_tool](.dart_tool) folder.
