import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecureStorageService {
  // Singleton instance
  static final SecureStorageService _instance = SecureStorageService._internal();

  // This is what you call
  static SecureStorageService get instance => _instance;

  // Private constructor
  SecureStorageService._internal();

  // Instance variables
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final String _keyAccessToken = 'ACCESS_TOKEN';
  final String _keyRefreshToken = 'REFRESH_TOKEN';
  final String _keyUserData = 'USER_DATA';

  // Instance methods
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _keyAccessToken, value: token);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _keyAccessToken);
  }

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _keyRefreshToken, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _keyRefreshToken);
  }

  Future<void> saveUserData(Map<String, dynamic> user) async {
    await _storage.write(key: _keyUserData, value: jsonEncode(user));
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final data = await _storage.read(key: _keyUserData);
    if (data == null) return null;
    return jsonDecode(data);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }





  Future<void> saveTemporaryData(String key, String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
      print('✅ Temporary data saved for key: $key');
    } catch (e) {
      print('Error saving temporary data: $e');
    }
  }

  Future<String?> getTemporaryData(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    } catch (e) {
      print('Error getting temporary data: $e');
      return null;
    }
  }









  static const String _keySubscriptionStatus = 'subscription_status';

  Future<void> saveSubscriptionStatus(bool isSubscribed) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keySubscriptionStatus, isSubscribed);
      print('✅ Subscription status saved: $isSubscribed');
    } catch (e) {
      print('Error saving subscription status: $e');
    }
  }

  Future<bool?> getSubscriptionStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keySubscriptionStatus);
    } catch (e) {
      print('Error getting subscription status: $e');
      return null;
    }
  }



  Future<void> clearTemporaryData(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
      print('✅ Temporary data cleared for key: $key');
    } catch (e) {
      print('Error clearing temporary data: $e');
    }
  }

}