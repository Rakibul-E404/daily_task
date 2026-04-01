import 'package:get/get.dart';
import '../model/user_model.dart';
import '../../utils/network/app_url.dart';
import '../../utils/network/network_caller_dio.dart';
import '../../utils/network/network_response_dio.dart';
import '../../utils/network/secure_storage_service.dart';
import 'package:askfemi/features/group_user/visions/bottom_navigation/ugc_bottom_nav.dart';
import 'package:askfemi/features/individual_user/views/bottom_navigation/main_bottom_nav.dart';

class ManualSignInScreenController extends GetxController {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  UserModel? loggedInUser;

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
        /// 🔑 Extract tokens
        final accessToken = response.jsonResponse?['data']
        ?['attributes']
        ?['tokens']
        ?['accessToken'];
        final refreshToken = response.jsonResponse?['data']
        ?['attributes']
        ?['tokens']
        ?['refreshToken'];

        if (accessToken == null) {
          Get.snackbar("Error", "Access token not found");
          return false;
        }

        /// Save tokens
        await SecureStorageService.saveAccessToken(accessToken);
        if (refreshToken != null) {
          await SecureStorageService.saveRefreshToken(refreshToken);
        }

        /// 🔹 Extract user info
        final userJson = response.jsonResponse?['data']
        ?['attributes']?['user'];
        loggedInUser = UserModel.fromJson(userJson);

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

  /// ✅ Navigate based on role
  void navigateByRole() {
    if (loggedInUser == null) return;

    if (loggedInUser!.role == 'individual') {
      Get.offAll(MainBottomNav());
    } else if (loggedInUser!.role == 'child') {
      Get.offAll(UgcMainBottomNav());
    } else {
      Get.snackbar("Error", "Unknown user role");
    }
  }
}