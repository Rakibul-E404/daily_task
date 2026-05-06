import 'package:askfemi/auth/sign_in/singn_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../utils/app_colors.dart';
import '../../utils/network/app_url.dart';
import '../../utils/network/network_caller_dio.dart';
import '../../utils/network/secure_storage_service.dart';

class SetNewPasswordScreen extends StatefulWidget {
  final String? userEmail;
  final String? otp;

  const SetNewPasswordScreen({
    super.key,
    this.userEmail,
    this.otp,
  });

  @override
  State<SetNewPasswordScreen> createState() => _SetNewPasswordScreenState();
}

class _SetNewPasswordScreenState extends State<SetNewPasswordScreen> {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  late final ValueNotifier<bool> _obscurePassword;
  late final ValueNotifier<bool> _obscureConfirmPassword;

  bool _isLoading = false;
  String? _errorMessage;
  String? _userEmail;
  String? _otp;

  @override
  void initState() {
    super.initState();
    _obscurePassword = ValueNotifier<bool>(true);
    _obscureConfirmPassword = ValueNotifier<bool>(true);
    _extractArguments();
  }

  void _extractArguments() {
    // Try to get from widget parameters first
    _userEmail = widget.userEmail;
    _otp = widget.otp;

    // If not available, try from Get.arguments
    if (_userEmail == null || _otp == null) {
      final arguments = Get.arguments;
      if (arguments is Map) {
        _userEmail = arguments['userEmail'] as String? ?? arguments['email'] as String?;
        _otp = arguments['otp'] as String? ?? arguments['resetToken'] as String?;
      }
    }

    // If still not available, try from storage
    if (_userEmail == null) {
      _getEmailFromStorage();
    }
    if (_otp == null) {
      _getOtpFromStorage();
    }

    print('📧 User Email: $_userEmail');
    print('🔑 OTP: $_otp');
  }

  Future<void> _getOtpFromStorage() async {
    try {
      final otp = await SecureStorageService.instance.getTemporaryData('reset_password_token');
      if (otp != null && otp.isNotEmpty) {
        setState(() {
          _otp = otp;
        });
        print('✅ Retrieved OTP from storage: $_otp');
      }
    } catch (e) {
      print('Error getting OTP from storage: $e');
    }
  }

  Future<void> _getEmailFromStorage() async {
    try {
      final email = await SecureStorageService.instance.getTemporaryData('reset_password_email');
      if (email != null && email.isNotEmpty) {
        setState(() {
          _userEmail = email;
        });
        print('✅ Retrieved email from storage: $_userEmail');
      }
    } catch (e) {
      print('Error getting email from storage: $e');
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _obscurePassword.dispose();
    _obscureConfirmPassword.dispose();
    super.dispose();
  }

  bool _validatePassword(String password) {
    if (password.length < 8) return false;
    if (!password.contains(RegExp(r'[A-Z]'))) return false;
    if (!password.contains(RegExp(r'[0-9]'))) return false;
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) return false;
    return true;
  }

  Future<void> _resetPassword() async {
    final newPassword = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // Validate passwords
    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter both password fields';
      });
      return;
    }

    if (newPassword != confirmPassword) {
      setState(() {
        _errorMessage = 'Passwords do not match';
      });
      return;
    }

    if (!_validatePassword(newPassword)) {
      setState(() {
        _errorMessage = 'Password must be at least 8 characters, contain an uppercase letter, a number, and a special character';
      });
      return;
    }

    if (_userEmail == null) {
      setState(() {
        _errorMessage = 'Email not found. Please go back and try again.';
      });
      return;
    }

    if (_otp == null) {
      setState(() {
        _errorMessage = 'OTP not found. Please request a new reset code.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // ✅ FIXED: Use correct field names: "password" and "otp" (not "newPassword" and "token")
      final Map<String, dynamic> requestBody = {
        "email": _userEmail,
        "otp": _otp,
        "password": newPassword,
      };

      print('📤 Reset password request to: ${AppUrl.resetPassword}');
      print('📤 Request body: $requestBody');

      final response = await _networkCaller.postRequest(
        AppUrl.resetPassword,
        body: requestBody,
      );

      print('📡 Response status: ${response.isSuccess}');
      print('📡 Response body: ${response.jsonResponse}');

      if (response.isSuccess) {
        // Clear temporary data after successful password reset
        await SecureStorageService.instance.clearTemporaryData('reset_password_token');
        await SecureStorageService.instance.clearTemporaryData('reset_password_email');

        if (mounted) {
          _showSuccessBottomSheet(context);
        }
      } else {
        String error = response.errorMessage ?? 'Failed to reset password';
        if (response.jsonResponse != null) {
          error = response.jsonResponse?['message'] ?? error;
        }
        setState(() {
          _errorMessage = error;
        });
      }
    } catch (e) {
      print('Error resetting password: $e');
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.15),
          Center(
            child: SvgPicture.asset(
              "assets/images/logo.svg",
              height: 130,
              width: 130,
              semanticsLabel: 'App Logo',
            ),
          ),
          const Spacer(),
        ],
      ),
      bottomSheet: Container(
        height: MediaQuery.of(context).size.height * 0.65,
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(80),
            topRight: Radius.circular(80),
          ),
          border: Border(
            top: BorderSide(color: AppColors.primaryColor, width: 1.5),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  "Set New Password",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Plus Jakarta Sans',
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              /// Error Message
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 12,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                ),

              /// New Password Field
              ValueListenableBuilder<bool>(
                valueListenable: _obscurePassword,
                builder: (context, isObscured, _) {
                  return TextField(
                    controller: _passwordController,
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      color: AppColors.black,
                    ),
                    obscureText: isObscured,
                    decoration: _inputDecoration(
                      hint: "New password",
                      isObscured: isObscured,
                      onToggle: () {
                        _obscurePassword.value = !_obscurePassword.value;
                      },
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              /// Confirm Password Field
              ValueListenableBuilder<bool>(
                valueListenable: _obscureConfirmPassword,
                builder: (context, isObscured, _) {
                  return TextField(
                    controller: _confirmPasswordController,
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      color: AppColors.black,
                    ),
                    obscureText: isObscured,
                    decoration: _inputDecoration(
                      hint: "Confirm password",
                      isObscured: isObscured,
                      onToggle: () {
                        _obscureConfirmPassword.value = !_obscureConfirmPassword.value;
                      },
                    ),
                  );
                },
              ),

              const SizedBox(height: 8),

              /// Password requirements
              Padding(
                padding: const EdgeInsets.only(left: 4, top: 8),
                child: Text(
                  "• At least 8 characters\n• One uppercase letter\n• One number\n• One special character",
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Plus Jakarta Sans',
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              /// Save Password Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _isLoading ? null : _resetPassword,
                  child: _isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    'Save Password',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      color: AppColors.white,
                      fontSize: 16,
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

  /// Input Decoration with vertical divider
  InputDecoration _inputDecoration({
    required String hint,
    required bool isObscured,
    required VoidCallback onToggle,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        color: Colors.grey,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      prefixIcon: Container(
        padding: const EdgeInsets.only(left: 16, right: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, color: AppColors.iconColor, size: 20),
            const SizedBox(width: 12),
            Container(
              height: 24,
              width: 1,
              color: Colors.grey[300],
            ),
          ],
        ),
      ),
      suffixIcon: IconButton(
        icon: Icon(
          isObscured ? Icons.visibility_off : Icons.visibility,
          color: AppColors.iconColor,
        ),
        onPressed: onToggle,
      ),
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.5),
      ),
    );
  }

  /// Success Bottom Sheet
  void _showSuccessBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.5,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.backgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// Success Icon
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryColor.withOpacity(0.1),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    "assets/icons/key.svg",
                    height: 150,
                    width: 150,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              /// Success Title
              const Text(
                "Password Update Successfully",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Plus Jakarta Sans',
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 8),

              /// Success Message
              const Text(
                "Return to the login page to enter your account with your new password.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Plus Jakarta Sans',
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 24),

              /// Go to Sign In Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    // Clear any temporary data
                    SecureStorageService.instance.clearTemporaryData('reset_password_token');
                    SecureStorageService.instance.clearTemporaryData('reset_password_email');
                    Get.offAll(() =>  SignInScreen());
                  },
                  child: const Text(
                    "Go to Sign in",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}