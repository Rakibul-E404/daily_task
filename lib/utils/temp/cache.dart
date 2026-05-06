import 'package:get_storage/get_storage.dart';

class CacheService {
  static final GetStorage _storage = GetStorage();

  // Cache keys
  static const String _keyUserProfile = 'user_profile';
  static const String _keyLastUpdated = 'last_updated';
  static const String _keyPreferredTime = 'preferred_time';
  static const String _keyPreferredTimeLastUpdated = 'preferred_time_last_updated';

  // ==================== USER PROFILE CACHE METHODS ====================

  // Save user profile to cache
  static Future<void> saveUserProfile(Map<String, dynamic> data) async {
    await _storage.write(_keyUserProfile, data);
    await _storage.write(_keyLastUpdated, DateTime.now().toIso8601String());
    print('✅ User profile saved to cache');
  }

  // Get cached user profile
  static Map<String, dynamic>? getUserProfile() {
    return _storage.read(_keyUserProfile);
  }

  // Get last updated time for user profile
  static DateTime? getLastUpdated() {
    final timestamp = _storage.read(_keyLastUpdated);
    if (timestamp != null) {
      return DateTime.parse(timestamp);
    }
    return null;
  }

  // Check if user profile cache is stale (older than specified minutes)
  static bool isProfileCacheStale({int minutes = 5}) {
    final lastUpdated = getLastUpdated();
    if (lastUpdated == null) return true;

    final difference = DateTime.now().difference(lastUpdated);
    return difference.inMinutes > minutes;
  }

  // ==================== PREFERRED TIME CACHE METHODS ====================

  // Save preferred time to cache
  static Future<void> savePreferredTime(String time) async {
    await _storage.write(_keyPreferredTime, time);
    await _storage.write(_keyPreferredTimeLastUpdated, DateTime.now().toIso8601String());
    print('✅ Preferred time saved to cache: $time');
  }

  // Get cached preferred time
  static String? getPreferredTime() {
    return _storage.read(_keyPreferredTime);
  }

  // Get last updated time for preferred time
  static DateTime? getPreferredTimeLastUpdated() {
    final timestamp = _storage.read(_keyPreferredTimeLastUpdated);
    if (timestamp != null) {
      return DateTime.parse(timestamp);
    }
    return null;
  }

  // Check if preferred time cache is stale (older than specified minutes)
  static bool isPreferredTimeCacheStale({int minutes = 5}) {
    final lastUpdated = getPreferredTimeLastUpdated();
    if (lastUpdated == null) return true;

    final difference = DateTime.now().difference(lastUpdated);
    return difference.inMinutes > minutes;
  }

  // ==================== GENERAL CACHE METHODS ====================

  // Check if any cache is stale (for backward compatibility)
  static bool isCacheStale({int minutes = 5}) {
    return isProfileCacheStale(minutes: minutes);
  }

  // Clear all cache
  static Future<void> clearCache() async {
    await _storage.remove(_keyUserProfile);
    await _storage.remove(_keyLastUpdated);
    await _storage.remove(_keyPreferredTime);
    await _storage.remove(_keyPreferredTimeLastUpdated);
    print('✅ All cache cleared');
  }

  // Clear only user profile cache
  static Future<void> clearUserProfileCache() async {
    await _storage.remove(_keyUserProfile);
    await _storage.remove(_keyLastUpdated);
    print('✅ User profile cache cleared');
  }

  // Clear only preferred time cache
  static Future<void> clearPreferredTimeCache() async {
    await _storage.remove(_keyPreferredTime);
    await _storage.remove(_keyPreferredTimeLastUpdated);
    print('✅ Preferred time cache cleared');
  }

  // Get all cache keys (for debugging)
  static Map<String, dynamic> getAllCache() {
    return {
      'userProfile': _storage.read(_keyUserProfile),
      'userProfileLastUpdated': _storage.read(_keyLastUpdated),
      'preferredTime': _storage.read(_keyPreferredTime),
      'preferredTimeLastUpdated': _storage.read(_keyPreferredTimeLastUpdated),
    };
  }

  // Check if cache exists
  static bool hasUserProfileCache() {
    return _storage.read(_keyUserProfile) != null;
  }

  static bool hasPreferredTimeCache() {
    return _storage.read(_keyPreferredTime) != null;
  }

  // Get cache age in minutes
  static int? getUserProfileCacheAgeInMinutes() {
    final lastUpdated = getLastUpdated();
    if (lastUpdated == null) return null;

    final difference = DateTime.now().difference(lastUpdated);
    return difference.inMinutes;
  }

  static int? getPreferredTimeCacheAgeInMinutes() {
    final lastUpdated = getPreferredTimeLastUpdated();
    if (lastUpdated == null) return null;

    final difference = DateTime.now().difference(lastUpdated);
    return difference.inMinutes;
  }
}