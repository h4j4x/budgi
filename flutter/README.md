# Budg1

Budg1 Flutter project.

![Test](https://github.com/h4j4x/budgi/actions/workflows/test.yml/badge.svg)

## Getting Started

### Configuration

Create config in file `config.json`:

```json
{
  "AUTH_PROVIDER": "supabase",
  "SUPABASE_URL": "<SUPABASE_URL>",
  "SUPABASE_TOKEN": "<SUPABASE_TOKEN>"
}
```

### Run the application

Run the app specifying the config file:

```shell
flutter run --dart-define-from-file=config.json
```
