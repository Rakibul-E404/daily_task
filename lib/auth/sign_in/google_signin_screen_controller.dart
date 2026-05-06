import 'package:get/get.dart';

class GoogleSignInScreenController extends GetxController {

  Future<void> signInWithGoogle() async {
    await Future.delayed(const Duration(seconds: 1));
    Get.snackbar("Info", "Google Sign-In coming soon 🚀");
  }
}