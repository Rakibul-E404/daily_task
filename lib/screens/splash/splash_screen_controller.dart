/**
import 'dart:async';
import 'package:get/get.dart';
import '../../auth/model/user_model.dart';
import '../../auth/sign_in/manual_signin_screen_controller.dart';
import '../../screens/get_started/get_started_screen.dart';
import '../../features/individual_user/views/bottom_navigation/main_bottom_nav.dart';
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
    // ✅ Using instance pattern
    final accessToken = await SecureStorageService.instance.getAccessToken();

    if (accessToken != null) {
      // Token exists, load user info
      final userJson = await SecureStorageService.instance.getUserData();

      final signInController = Get.isRegistered<ManualSignInScreenController>()
          ? Get.find<ManualSignInScreenController>()
          : Get.put(ManualSignInScreenController());

      if (userJson != null) {
        signInController.loggedInUser = UserModel.fromJson(userJson);

        if (signInController.loggedInUser!.role == 'individual') {
          Get.offAll(() => MainBottomNav());
        } else if (signInController.loggedInUser!.role == 'child') {
          Get.offAll(() => UgcMainBottomNav());
        } else {
          Get.offAll(() => GetStartedScreen());
        }
      } else {
        Get.offAll(() => GetStartedScreen());
      }
    } else {
      Get.offAll(() => GetStartedScreen());
    }
  }

  void dispose() {
    _timer?.cancel();
  }
}*/










import 'dart:async';
import 'package:get/get.dart';
import '../../auth/model/user_model.dart';
import '../../auth/sign_in/manual_signin_screen_controller.dart';
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
}