import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../utils/network/app_url.dart';
import '../../../../../utils/network/network_caller_dio.dart';
import '../../../../../utils/network/secure_storage_service.dart';
import '../../../auth/model/auth_flow_model.dart';
import '../../../auth/verify/verify_email_screen.dart';

class ForgotPasswordController extends GetxController {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();

  var emailController = TextEditingController();
  var isLoading = false.obs;
  var errorMessage = RxString('');
  var resetToken = RxString('');
  var userEmail = RxString('');

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

  Future<void> sendResetOtp() async {
    // Validate email
    if (emailController.text.trim().isEmpty) {
      errorMessage.value = 'Please enter your email';
      Get.snackbar(
        'Error',
        'Please enter your email',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Basic email validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(emailController.text.trim())) {
      errorMessage.value = 'Please enter a valid email address';
      Get.snackbar(
        'Error',
        'Please enter a valid email address',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final token = await SecureStorageService.instance.getAccessToken();

      final Map<String, dynamic> requestBody = {
        "email": emailController.text.trim(),
      };

      // Store the email for next screen
      userEmail.value = emailController.text.trim();

      print('🌐 Making POST request to: ${AppUrl.forgotPassword}');
      print('📦 Request body: $requestBody');

      final response = await _networkCaller.postRequest(
        AppUrl.forgotPassword,
        body: requestBody,
        headers: token != null ? {'Authorization': 'Bearer $token'} : null,
      );

      print('📡 Response status code: ${response.statusCode}');
      print('📡 Response success: ${response.isSuccess}');

      if (response.isSuccess && response.jsonResponse != null) {
        final attributes = response.jsonResponse?['data']?['attributes'];
        final resetPasswordToken = attributes?['resetPasswordToken'] ?? '';

        // Store the token temporarily
        resetToken.value = resetPasswordToken;

        // Store in local storage for temporary use
        if (resetPasswordToken.isNotEmpty) {
          await SecureStorageService.instance.saveTemporaryData(
              'reset_password_token',
              resetPasswordToken
          );
        }

        // Also store the email for verification screen
        await SecureStorageService.instance.saveTemporaryData(
            'reset_password_email',
            userEmail.value
        );

        Get.snackbar(
          'Success',
          response.jsonResponse?['message'] ?? 'OTP sent successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );

        // Navigate to verification screen with email and token
        Get.to(
              () => const VerifyEmailScreen(),
          arguments: {
            'authFlow': AuthFlowModel.forgotPassword,
            'email': userEmail.value,
            'resetToken': resetPasswordToken,
          },
        );

        isLoading.value = false;
      } else {
        String error = response.errorMessage ?? 'Failed to send reset OTP';
        if (response.jsonResponse != null) {
          error = response.jsonResponse?['message'] ?? error;
        }
        errorMessage.value = error;
        Get.snackbar(
          'Error',
          error,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        isLoading.value = false;
      }
    } catch (e) {
      print('Error sending reset OTP: $e');
      errorMessage.value = 'An error occurred. Please try again.';
      Get.snackbar(
        'Error',
        'An error occurred. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      isLoading.value = false;
    }
  }

  String getEmail() {
    return userEmail.value;
  }
}