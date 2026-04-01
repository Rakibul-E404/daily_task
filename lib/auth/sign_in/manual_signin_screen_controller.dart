import 'package:get/get.dart';
import '../../screens/get_started/get_started_screen.dart';
import '../../utils/network/app_url.dart';
import '../../utils/network/network_caller_dio.dart';
import '../../utils/network/network_response_dio.dart';
import '../../utils/network/secure_storage_service.dart';
import '../model/user_model.dart';
import '../../features/group_user/visions/bottom_navigation/ugc_bottom_nav.dart';
import '../../features/individual_user/views/bottom_navigation/main_bottom_nav.dart';

class ManualSignInScreenController extends GetxController {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  UserModel? loggedInUser;

  /// ================= LOGIN =================
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    update();

    final body = {
      "email": email,
      "password": password,
    };

    NetworkResponseDio response = await _networkCaller.postRequest(
      AppUrl.loginIndividualAndChildren,
      body: body,
      isLogin: true,
    );

    _isLoading = false;
    update();

    if (response.isSuccess) {
      try {
        final data = response.jsonResponse?['data']?['attributes'];

        // Parse user
        final userJson = data?['user'];
        if (userJson == null) {
          Get.snackbar("Error", "User data not found");
          return false;
        }

        loggedInUser = UserModel.fromJson(userJson);

        // Extract tokens
        final tokens = data?['tokens'];
        final accessToken = tokens?['accessToken'];
        final refreshToken = tokens?['refreshToken'];

        if (accessToken == null) {
          Get.snackbar("Error", "Access token not found");
          return false;
        }

        // Save tokens
        await SecureStorageService.saveAccessToken(accessToken);
        if (refreshToken != null) {
          await SecureStorageService.saveRefreshToken(refreshToken);
        }

        // Save user data
        await SecureStorageService.saveUserData(loggedInUser!.toJson());

        // ✅ Navigate by role
        _navigateByRole();

        return true;
      } catch (e) {
        Get.snackbar("Error", "Parsing failed: ${e.toString()}");
        return false;
      }
    } else {
      Get.snackbar(
        "Login Failed",
        "Something went wrong",
      );
      return false;
    }
  }

  /// ================= ROLE NAVIGATION =================
  void _navigateByRole() {
    if (loggedInUser == null) return;

    if (loggedInUser!.role == 'individual') {
      Get.offAll(() => MainBottomNav());
    } else if (loggedInUser!.role == 'child') {
      Get.offAll(() => UgcMainBottomNav());
    } else {
      Get.offAll(() => GetStartedScreen());
    }
  }
}
