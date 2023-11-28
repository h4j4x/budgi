import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../storage.dart';

class SecureStorageService implements StorageService {
  final storage = const FlutterSecureStorage();

  @override
  Future<String?> readString(String key) {
    return storage.read(key: key);
  }

  @override
  Future<void> writeString(String key, String? value) {
    if (value != null) {
      return storage.write(key: key, value: value);
    } else {
      return storage.delete(key: key);
    }
  }
}
