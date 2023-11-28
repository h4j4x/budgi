abstract class StorageService {
  /// Will delete entry if value is null.
  Future<void> writeString(String key, String? value);

  Future<String?> readString(String key);
}
