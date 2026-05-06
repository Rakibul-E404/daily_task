// settings_controller.dart
import 'package:get/get.dart';
import '../../../../utils/network/app_url.dart';
import '../../../../utils/network/network_caller_dio.dart';
import '../../../../utils/network/secure_storage_service.dart';

class SettingsScreenController extends GetxController {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();

  var isLoading = false.obs;
  var errorMessage = RxString('');

  Future<Map<String, dynamic>?> fetchSettingsData(String type) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final token = await SecureStorageService.instance.getAccessToken();

      if (token == null) {
        errorMessage.value = 'No access token found';
        // print('No access token found');
        isLoading.value = false;
        return null;
      }

      final response = await _networkCaller.getRequest(
        AppUrl.getPrivacyPolicyTermsConditionsAboutUs(type),
        headers: {'Authorization': 'Bearer $token'},
      );

      // print('📡 Response status code: ${response.statusCode}');
      // print('📡 Response success: ${response.isSuccess}');

      if (response.isSuccess && response.jsonResponse != null) {
        final attributes = response.jsonResponse?['data']?['attributes'];

        if (attributes != null && attributes is List && attributes.isNotEmpty) {
          final data = attributes[0];
          isLoading.value = false;
          return data;
        }
      }

      isLoading.value = false;
      return null;
    } catch (e) {
      // print('Error fetching settings data: $e');
      errorMessage.value = e.toString();
      isLoading.value = false;
      return null;
    }
  }
}