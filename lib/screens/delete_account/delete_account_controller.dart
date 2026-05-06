// delete_account_controller.dart
import 'package:get/get.dart';
import '../../../../utils/network/app_url.dart';
import '../../../../utils/network/network_caller_dio.dart';
import '../../../../utils/network/network_response_dio.dart';
import '../../../../utils/network/secure_storage_service.dart';

class DeleteAccountController extends GetxController {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();

  var isLoading = false.obs;
  var errorMessage = RxString('');
  var isPasswordVisible = false.obs;
  var password = ''.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void updatePassword(String value) {
    password.value = value;
  }

  Future<bool> deleteAccount() async {
    if (password.value.trim().isEmpty) {
      errorMessage.value = 'Please enter your password to confirm';
      return false;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final token = await SecureStorageService.instance.getAccessToken();

      if (token == null) {
        errorMessage.value = 'No access token found. Please login again.';
        isLoading.value = false;
        return false;
      }

      final Map<String, dynamic> requestBody = {
        "password": password.value.trim(),
      };

      print('📤 Deleting account...');

      final response = await _networkCaller.deleteRequest(
        AppUrl.deleteAccount,
        body: requestBody,
        headers: {'Authorization': 'Bearer $token'},
      );

      print('📡 Response status code: ${response.statusCode}');
      print('📡 Response success: ${response.isSuccess}');
      print('📡 Response body: ${response.jsonResponse}');

      if (response.isSuccess || response.statusCode == 200) {
        // Clear all local data
        await SecureStorageService.instance.clearAll();
        isLoading.value = false;
        return true;
      } else {
        String error = response.errorMessage ?? 'Failed to delete account';
        if (response.jsonResponse != null) {
          error = response.jsonResponse?['message'] ?? error;
        }
        errorMessage.value = error;
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      print('Error deleting account: $e');
      errorMessage.value = 'An error occurred. Please try again.';
      isLoading.value = false;
      return false;
    }
  }
}