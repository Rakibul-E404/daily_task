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
    final accessToken = await SecureStorageService.getAccessToken();

    if (accessToken != null) {
      // Token exists, load user info
      final userJson = await SecureStorageService.getUserData();
      final signInController = Get.put(ManualSignInScreenController());

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
}