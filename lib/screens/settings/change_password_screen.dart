import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_texts_style.dart';
import '../../../../utils/network/app_url.dart';
import '../../../../utils/network/network_caller_dio.dart';
import '../../../../utils/network/secure_storage_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();

  // Controllers for text fields
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Control visibility for each field
  bool _isOldPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // Loading state
  bool _isLoading = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    // Validate fields
    if (_oldPasswordController.text.trim().isEmpty) {
      _showErrorSnackbar('Please enter your old password');
      return;
    }

    if (_newPasswordController.text.trim().isEmpty) {
      _showErrorSnackbar('Please enter a new password');
      return;
    }

    if (_newPasswordController.text.trim().length < 6) {
      _showErrorSnackbar('New password must be at least 6 characters');
      return;
    }

    if (_confirmPasswordController.text.trim() != _newPasswordController.text.trim()) {
      _showErrorSnackbar('New password and confirm password do not match');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final token = await SecureStorageService.instance.getAccessToken();

      if (token == null) {
        _showErrorSnackbar('No access token found. Please login again.');
        return;
      }

      // FIXED: Use 'currentPassword' instead of 'oldPassword'
      final Map<String, dynamic> requestBody = {
        "currentPassword": _oldPasswordController.text.trim(),
        "newPassword": _newPasswordController.text.trim(),
      };

      print('📤 Changing password...');
      print('📤 Request body: $requestBody');

      final response = await _networkCaller.postRequest(
        AppUrl.changePassword,
        body: requestBody,
        headers: {'Authorization': 'Bearer $token'},
      );

      print('📡 Response status code: ${response.statusCode}');
      print('📡 Response success: ${response.isSuccess}');
      print('📡 Response body: ${response.jsonResponse}');

      if (response.isSuccess || response.statusCode == 200) {
        // Clear password fields
        _oldPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();

        _showSuccessSnackbar('Password changed successfully!');

        // Optional: Go back after 2 seconds
        Future.delayed(const Duration(seconds: 2), () {
          Get.back();
        });
      } else {
        String error = response.errorMessage ?? 'Failed to change password';
        if (response.jsonResponse != null) {
          error = response.jsonResponse?['message'] ?? error;
          // Check if there's an error array with message
          if (response.jsonResponse?['error'] != null && response.jsonResponse?['error'] is List) {
            final errorList = response.jsonResponse?['error'] as List;
            if (errorList.isNotEmpty && errorList[0]['message'] != null) {
              error = errorList[0]['message'];
            }
          }
        }
        _showErrorSnackbar(error);
      }
    } catch (e) {
      print('Error changing password: $e');
      _showErrorSnackbar('An error occurred. Please try again.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _forgotPassword() {
    // TODO: Navigate to forgot password screen
    print('Forgot password tapped');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        surfaceTintColor: AppColors.transparent,
        foregroundColor: AppColors.iconColor,
        title: Text(
          "Change Password",
          style: AppTextStyles.smallHeading?.copyWith(
            color: AppColors.iconColor,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back_outlined, color: AppColors.iconColor),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Old Password Field
              TextField(
                controller: _oldPasswordController,
                obscureText: !_isOldPasswordVisible,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.white,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppColors.primaryColor ?? Colors.blue, width: 2.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppColors.grey, width: 1.0),
                  ),
                  prefixIcon: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: IntrinsicHeight(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.lock, color: AppColors.iconColor),
                          const SizedBox(width: 12),
                          VerticalDivider(
                            color: AppColors.grey,
                            width: 2,
                            indent: 6,
                            endIndent: 6,
                            thickness: 1.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isOldPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: AppColors.iconColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _isOldPasswordVisible = !_isOldPasswordVisible;
                      });
                    },
                  ),
                  hintText: 'Old Password',
                  hintStyle: const TextStyle(fontFamily: 'Plus Jakarta Sans', color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),

              // New Password Field
              TextField(
                controller: _newPasswordController,
                obscureText: !_isNewPasswordVisible,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppColors.primaryColor, width: 2.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppColors.grey, width: 1.0),
                  ),
                  prefixIcon: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: IntrinsicHeight(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.lock, color: AppColors.iconColor),
                          const SizedBox(width: 12),
                          VerticalDivider(
                            color: AppColors.grey,
                            width: 2,
                            indent: 6,
                            endIndent: 6,
                            thickness: 1.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isNewPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: AppColors.iconColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _isNewPasswordVisible = !_isNewPasswordVisible;
                      });
                    },
                  ),
                  hintText: 'New Password',
                  hintStyle: const TextStyle(fontFamily: 'Plus Jakarta Sans', color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),

              /// Confirm Password Field
              TextField(
                controller: _confirmPasswordController,
                obscureText: !_isConfirmPasswordVisible,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppColors.primaryColor, width: 2.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppColors.grey, width: 1.0),
                  ),
                  prefixIcon: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: IntrinsicHeight(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.lock, color: AppColors.iconColor),
                          const SizedBox(width: 12),
                          VerticalDivider(
                            color: AppColors.grey,
                            width: 2,
                            indent: 6,
                            endIndent: 6,
                            thickness: 1.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: AppColors.iconColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                  ),
                  hintText: 'Confirm Password',
                  hintStyle: const TextStyle(fontFamily: 'Plus Jakarta Sans', color: Colors.grey),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: _forgotPassword,
                    child: Text(
                      "Forgot Password?",
                      style: AppTextStyles.smallText.copyWith(
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.grey,
                        color: AppColors.black,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _isLoading ? null : _changePassword,
                  child: _isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : Text(
                    'Change Password',
                    style: AppTextStyles.smallText.copyWith(
                      fontSize: 18,
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}