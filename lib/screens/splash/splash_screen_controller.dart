/**
import 'dart:async';
import 'package:get/get.dart';
import '../../auth/model/user_model.dart';
import '../../auth/sign_in/manual_sign_in_screen_controller.dart';
import '../../screens/get_started/get_started_screen.dart';
import '../../features/individual_user/views/bottom_navigation/main_bottom_nav.dart';
import '../../features/individual_user/views/home/app_open_home_screen.dart';
import '../../features/group_user/visions/bottom_navigation/ugc_bottom_nav.dart';
import '../../utils/network/secure_storage_service.dart';

class SplashScreenController {
  final int splashDuration;
  Timer? _timer;

  SplashScreenController({this.splashDuration = 3});

  void startTimer() {
    _timer = Timer(Duration(seconds: splashDuration), _checkAuth);
  }

  Future<void> _checkAuth() async {
    // Get access token
    final accessToken = await SecureStorageService.instance.getAccessToken();

    if (accessToken != null) {
      // Token exists, load user info
      final userJson = await SecureStorageService.instance.getUserData();
      final subscriptionStatus = await SecureStorageService.instance.getSubscriptionStatus();

      final signInController = Get.isRegistered<ManualSignInScreenController>()
          ? Get.find<ManualSignInScreenController>()
          : Get.put(ManualSignInScreenController());

      if (userJson != null) {
        signInController.loggedInUser = UserModel.fromJson(userJson);

        // Set subscription status in controller
        if (subscriptionStatus != null) {
          signInController.isSubscribed = subscriptionStatus;
        }

        // Navigate based on role and subscription
        if (signInController.loggedInUser!.role == 'individual') {
          if (signInController.isSubscribed) {
            // User has active subscription - go to main bottom nav
            print('✅ Splash: User has active subscription - navigating to MainBottomNav');
            Get.offAll(() => MainBottomNav());
          } else {
            // User has no subscription - go to AppOpenHomeScreen
            print('⚠️ Splash: User has no active subscription - navigating to AppOpenHomeScreen');
            Get.offAll(() => const AppOpenHomeScreen());
          }
        } else if (signInController.loggedInUser!.role == 'child') {
          print('👶 Splash: Child user - navigating to UgcMainBottomNav');
          Get.offAll(() => UgcMainBottomNav());
        } else {
          print('❓ Splash: Unknown role - navigating to GetStartedScreen');
          Get.offAll(() => GetStartedScreen());
        }
      } else {
        // User data not found, go to login
        print('⚠️ Splash: No user data found - navigating to GetStartedScreen');
        Get.offAll(() => GetStartedScreen());
      }
    } else {
      // No token, go to login
      print('⚠️ Splash: No access token - navigating to GetStartedScreen');
      Get.offAll(() => GetStartedScreen());
    }
  }

  void dispose() {
    _timer?.cancel();
  }
}*/









///
///
///
/// todo:: checking the accesstoken
///
///
///




import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import '../../auth/model/user_model.dart';
import '../../auth/sign_in/manual_sign_in_screen_controller.dart';
import '../../screens/get_started/get_started_screen.dart';
import '../../features/individual_user/views/bottom_navigation/main_bottom_nav.dart';
import '../../features/individual_user/views/home/app_open_home_screen.dart';
import '../../features/group_user/visions/bottom_navigation/ugc_bottom_nav.dart';
import '../../utils/network/secure_storage_service.dart';

class SplashScreenController {
  final int splashDuration;
  Timer? _timer;

  SplashScreenController({this.splashDuration = 3});

  void startTimer() {
    _timer = Timer(Duration(seconds: splashDuration), _checkAuth);
  }

  /// Decodes the JWT and checks if it's expired
  bool _isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true; // Invalid token structure

      // JWT payload is base64url encoded — normalize it first
      String payload = parts[1];
      payload = payload.replaceAll('-', '+').replaceAll('_', '/');

      // Pad to valid base64 length
      switch (payload.length % 4) {
        case 2:
          payload += '==';
          break;
        case 3:
          payload += '=';
          break;
      }

      final decoded = utf8.decode(base64Decode(payload));
      final Map<String, dynamic> payloadMap = jsonDecode(decoded);

      if (!payloadMap.containsKey('exp')) return true; // No expiry field

      final exp = payloadMap['exp'] as int;
      final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      final now = DateTime.now();

      print('🕐 Token expiry: $expiryDate | Now: $now');

      return now.isAfter(expiryDate); // true = expired
    } catch (e) {
      print('❌ Error decoding token: $e');
      return true; // Treat malformed token as expired
    }
  }

  Future<void> _checkAuth() async {
    final accessToken = await SecureStorageService.instance.getAccessToken();

    if (accessToken != null) {
      // ✅ Check token expiry locally without any API call
      final isExpired = _isTokenExpired(accessToken);

      if (isExpired) {
        print('❌ Splash: Access token is expired - navigating to GetStartedScreen');
        await SecureStorageService.instance.clearAll(); // Wipe stale data
        Get.offAll(() => GetStartedScreen());
        return;
      }

      print('✅ Splash: Token is valid, proceeding...');

      // Token is valid — proceed with user data
      final userJson = await SecureStorageService.instance.getUserData();
      final subscriptionStatus = await SecureStorageService.instance.getSubscriptionStatus();

      final signInController = Get.isRegistered<ManualSignInScreenController>()
          ? Get.find<ManualSignInScreenController>()
          : Get.put(ManualSignInScreenController());

      if (userJson != null) {
        signInController.loggedInUser = UserModel.fromJson(userJson);

        if (subscriptionStatus != null) {
          signInController.isSubscribed = subscriptionStatus;
        }

        if (signInController.loggedInUser!.role == 'individual') {
          if (signInController.isSubscribed) {
            print('✅ Splash: User has active subscription - navigating to MainBottomNav');
            Get.offAll(() => MainBottomNav());
          } else {
            print('⚠️ Splash: User has no active subscription - navigating to AppOpenHomeScreen');
            Get.offAll(() => const AppOpenHomeScreen());
          }
        } else if (signInController.loggedInUser!.role == 'child') {
          print('👶 Splash: Child user - navigating to UgcMainBottomNav');
          Get.offAll(() => UgcMainBottomNav());
        } else {
          print('❓ Splash: Unknown role - navigating to GetStartedScreen');
          Get.offAll(() => GetStartedScreen());
        }
      } else {
        print('⚠️ Splash: No user data found - navigating to GetStartedScreen');
        Get.offAll(() => GetStartedScreen());
      }
    } else {
      print('⚠️ Splash: No access token - navigating to GetStartedScreen');
      Get.offAll(() => GetStartedScreen());
    }
  }

  void dispose() {
    _timer?.cancel();
  }
}