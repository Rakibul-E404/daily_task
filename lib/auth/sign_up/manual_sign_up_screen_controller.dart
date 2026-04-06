import 'dart:math';
import 'package:get/get.dart';
import '../../utils/network/app_url.dart';
import '../../utils/network/network_caller_dio.dart';
import '../model/auth_flow_model.dart';
import '../verify/verify_email_screen.dart';

class ManualSignUpController extends GetxController {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();

  // Reactive variables
  var isLoading = false.obs;
  var errorMessage = RxString('');

  // Form field values
  var name = ''.obs;
  var email = ''.obs;
  var phoneNumber = ''.obs;
  var gender = ''.obs;
  var dateOfBirth = ''.obs;
  var age = ''.obs;
  var password = ''.obs;
  var agreeToTerms = false.obs;

  // Password visibility
  var isPasswordObscured = true.obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    super.onClose();
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordObscured.value = !isPasswordObscured.value;
  }

  // Update name
  void updateName(String value) {
    name.value = value;
  }

  // Update email
  void updateEmail(String value) {
    email.value = value;
  }

  // Update phone number
  void updatePhoneNumber(String value) {
    phoneNumber.value = value;
  }

  // Update gender
  void updateGender(String value) {
    gender.value = value;
  }

  // Update date of birth - expects date in DD/MM/YYYY format from DateOfBirthField
  void updateDateOfBirth(String value) {
    dateOfBirth.value = value;
  }

  // Update age
  void updateAge(String value) {
    age.value = value;
  }

  // Update password
  void updatePassword(String value) {
    password.value = value;
  }

  // Update terms agreement
  void updateTermsAgreement(bool value) {
    agreeToTerms.value = value;
  }

  // Convert date from DD/MM/YYYY to YYYY-MM-DD (ISO format)
  String _formatDateToISO(String date) {
    if (date.isEmpty) return '';
    // Remove any spaces
    String cleanDate = date.replaceAll(' ', '');

    // Check if date is in DD/MM/YYYY format
    if (cleanDate.contains('/')) {
      final parts = cleanDate.split('/');
      if (parts.length == 3) {
        final day = parts[0].padLeft(2, '0');
        final month = parts[1].padLeft(2, '0');
        final year = parts[2];
        return '$year-$month-$day';
      }
    }

    // Check if date is in DD-MM-YYYY format
    if (cleanDate.contains('-')) {
      final parts = cleanDate.split('-');
      if (parts.length == 3) {
        final day = parts[0].padLeft(2, '0');
        final month = parts[1].padLeft(2, '0');
        final year = parts[2];
        return '$year-$month-$day';
      }
    }

    return date;
  }

  // Validate form
  bool validateForm() {
    if (name.value.trim().isEmpty) {
      errorMessage.value = 'Please enter your name';
      return false;
    }

    if (email.value.trim().isEmpty) {
      errorMessage.value = 'Please enter your email';
      return false;
    }

    if (!_isValidEmail(email.value.trim())) {
      errorMessage.value = 'Please enter a valid email address';
      return false;
    }

    if (phoneNumber.value.trim().isEmpty) {
      errorMessage.value = 'Please enter your phone number';
      return false;
    }

    if (gender.value.isEmpty) {
      errorMessage.value = 'Please select your gender';
      return false;
    }

    if (dateOfBirth.value.isEmpty) {
      errorMessage.value = 'Please select your date of birth';
      return false;
    }

    if (age.value.trim().isEmpty) {
      errorMessage.value = 'Please enter your age';
      return false;
    }

    if (password.value.trim().isEmpty) {
      errorMessage.value = 'Please enter a password';
      return false;
    }

    if (password.value.trim().length < 6) {
      errorMessage.value = 'Password must be at least 6 characters';
      return false;
    }

    if (!agreeToTerms.value) {
      errorMessage.value = 'Please agree to the Terms & Conditions';
      return false;
    }

    errorMessage.value = '';
    return true;
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  // Sign up method with retry logic for rate limiting
  Future<bool> signUp({int retryCount = 0}) async {
    const maxRetries = 3;

    // Validate form first
    if (!validateForm()) {
      return false;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Format date of birth to ISO format (YYYY-MM-DD)
      final formattedDob = _formatDateToISO(dateOfBirth.value);

      // Prepare request body
      final Map<String, dynamic> requestBody = {
        "name": name.value.trim(),
        "email": email.value.trim(),
        "password": password.value.trim(),
        "phoneNumber": phoneNumber.value.trim(),
        "role": "individual",
        "acceptTOC": true,
        "age": int.tryParse(age.value.trim()) ?? 0,
        "dob": formattedDob,
        "gender": gender.value.toLowerCase(),
      };

      print('📤 Sign up request: $requestBody');
      print('📤 Formatted DOB: $formattedDob');

      final response = await _networkCaller.postRequest(
        AppUrl.signUpIndevidual,
        body: requestBody,
      );

      print('📡 Response status code: ${response.statusCode}');
      print('📡 Response success: ${response.isSuccess}');
      print('📡 Response body: ${response.jsonResponse}');

      // After successful signup response
      if (response.isSuccess) {
        final attributes = response.jsonResponse?['data']?['attributes'];
        final verificationToken = attributes?['verificationToken'];
        final userEmail = email.value.trim();

        isLoading.value = false;

        // Navigate to verify screen
        Get.to(() => const VerifyEmailScreen(), arguments: {
          'verificationToken': verificationToken,
          'email': userEmail,
          'authFlow': AuthFlowModel.signUp,
        });

        return true;
      }
      // Handle rate limiting (429)
      else if (response.statusCode == 429 && retryCount < maxRetries) {
        isLoading.value = false;

        // Calculate delay with exponential backoff: 2^retryCount seconds
        final delaySeconds = pow(2, retryCount).toInt();
        print('⚠️ Rate limited (429). Retrying in $delaySeconds seconds... (Attempt ${retryCount + 1}/$maxRetries)');

        // Show user-friendly message
        errorMessage.value = 'Too many attempts. Retrying in $delaySeconds seconds...';

        await Future.delayed(Duration(seconds: delaySeconds));

        // Clear error message and retry
        errorMessage.value = '';
        return signUp(retryCount: retryCount + 1);
      }
      else {
        String error = response.errorMessage ?? 'Sign up failed';
        if (response.jsonResponse != null) {
          error = response.jsonResponse?['message'] ?? error;
        }

        // Provide more specific error messages
        if (response.statusCode == 400) {
          error = 'Invalid information. Please check your details.';
        } else if (response.statusCode == 409) {
          error = 'Email already exists. Please use a different email.';
        } else if (response.statusCode == 500) {
          error = 'Server error. Please try again later.';
        }

        errorMessage.value = error;
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      print('Error during sign up: $e');
      errorMessage.value = 'An error occurred. Please try again.';
      isLoading.value = false;
      return false;
    }
  }

  // Reset form
  void resetForm() {
    name.value = '';
    email.value = '';
    phoneNumber.value = '';
    gender.value = '';
    dateOfBirth.value = '';
    age.value = '';
    password.value = '';
    agreeToTerms.value = false;
    errorMessage.value = '';
  }
}