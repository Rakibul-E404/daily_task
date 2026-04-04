// cache_service.dart
import 'package:get_storage/get_storage.dart';

class CacheService {
  static final GetStorage _storage = GetStorage();

  // Cache keys
  static const String _keyUserProfile = 'user_profile';
  static const String _keyLastUpdated = 'last_updated';

  // Save user profile to cache
  static Future<void> saveUserProfile(Map<String, dynamic> data) async {
    await _storage.write(_keyUserProfile, data);
    await _storage.write(_keyLastUpdated, DateTime.now().toIso8601String());
  }

  // Get cached user profile
  static Map<String, dynamic>? getUserProfile() {
    return _storage.read(_keyUserProfile);
  }

  // Get last updated time
  static DateTime? getLastUpdated() {
    final timestamp = _storage.read(_keyLastUpdated);
    if (timestamp != null) {
      return DateTime.parse(timestamp);
    }
    return null;
  }

  // Check if cache is stale (older than specified minutes)
  static bool isCacheStale({int minutes = 5}) {
    final lastUpdated = getLastUpdated();
    if (lastUpdated == null) return true;

    final difference = DateTime.now().difference(lastUpdated);
    return difference.inMinutes > minutes;
  }

  // Clear cache
  static Future<void> clearCache() async {
    await _storage.remove(_keyUserProfile);
    await _storage.remove(_keyLastUpdated);
  }
}