import 'dart:async';
import 'package:askfemi/auth/model/auth_flow_model.dart';
import 'package:askfemi/auth/password/set_new_password_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import '../../utils/app_colors.dart';
import '../../utils/congratulations_screen.dart';
import '../../utils/network/app_url.dart';
import '../../utils/network/network_caller_dio.dart';
import '../../utils/network/secure_storage_service.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();

  final pinController = TextEditingController();
  final focusNode = FocusNode();

  int _countdownSeconds = 30;
  bool _isTimerActive = true;
  Timer? _timer;

  bool _isLoading = false;
  String? _verificationToken;
  String? _userEmail;
  AuthFlowModel? _authFlow;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _extractArguments();
  }

  void _extractArguments() {
    final arguments = Get.arguments;
    print('🔍 Full arguments: $arguments');

    if (arguments != null) {
      if (arguments is Map) {
        // For SignUp flow: 'verificationToken'
        // For ForgotPassword flow: 'resetToken'
        _verificationToken = arguments['verificationToken'] as String? ??
            arguments['resetToken'] as String?;
        _userEmail = arguments['email'] as String?;
        _authFlow = arguments['authFlow'] as AuthFlowModel?;

        // Also try to get from temporary storage if not in arguments
        if (_verificationToken == null) {
          _getTokenFromStorage();
        }
        if (_userEmail == null) {
          _getEmailFromStorage();
        }
        if (_authFlow == null) {
          _getAuthFlowFromStorage();
        }
      } else if (arguments is AuthFlowModel) {
        _authFlow = arguments;
        // Try to get email and token from storage
        _getEmailFromStorage();
        _getTokenFromStorage();
        _getAuthFlowFromStorage();
      }
    } else {
      // Try to get from storage if no arguments
      _getEmailFromStorage();
      _getTokenFromStorage();
      _getAuthFlowFromStorage();
    }

    print('📧 Verification/Reset Token: $_verificationToken');
    print('📧 User Email: $_userEmail');
    print('📧 Auth Flow: $_authFlow');
  }

  Future<void> _getTokenFromStorage() async {
    try {
      // Try to get reset token (for forgot password)
      final resetToken = await SecureStorageService.instance.getTemporaryData('reset_password_token');
      if (resetToken != null && resetToken.isNotEmpty) {
        setState(() {
          _verificationToken = resetToken;
        });
        print('✅ Retrieved reset token from storage: $_verificationToken');
      }
    } catch (e) {
      print('Error getting token from storage: $e');
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

  Future<void> _getAuthFlowFromStorage() async {
    try {
      final flow = await SecureStorageService.instance.getTemporaryData('auth_flow');
      if (flow != null && flow.isNotEmpty) {
        if (flow == 'forgot_password') {
          setState(() {
            _authFlow = AuthFlowModel.forgotPassword;
          });
        } else if (flow == 'sign_up') {
          setState(() {
            _authFlow = AuthFlowModel.signUp;
          });
        }
        print('✅ Retrieved auth flow from storage: $_authFlow');
      }
    } catch (e) {
      print('Error getting auth flow from storage: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    pinController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void _startTimer() {
    _countdownSeconds = 30;
    _isTimerActive = true;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_countdownSeconds > 0) {
            _countdownSeconds--;
          } else {
            _isTimerActive = false;
            timer.cancel();
          }
        });
      }
    });
  }

  Future<void> _resendCode() async {
    if (!_isTimerActive && _userEmail != null && !_isLoading) {
      setState(() {
        _isLoading = true;
      });

      try {
        final isForgotPassword = _authFlow == AuthFlowModel.forgotPassword;
        final apiUrl = AppUrl.resendVerificationCode;

        final response = await _networkCaller.postRequest(
          apiUrl,
          body: {"email": _userEmail},
        );

        if (response.isSuccess) {
          _startTimer();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Verification code has been resent"),
                backgroundColor: Colors.green,
              ),
            );
          }

          // Extract new verification token if provided
          if (response.jsonResponse != null) {
            final newToken = response.jsonResponse?['data']?['attributes']?['verificationToken'] ??
                response.jsonResponse?['data']?['attributes']?['resetPasswordToken'];
            if (newToken != null && newToken.isNotEmpty) {
              setState(() {
                _verificationToken = newToken;
              });
              // Update stored token for forgot password flow
              if (isForgotPassword) {
                await SecureStorageService.instance.saveTemporaryData('reset_password_token', newToken);
              }
            }
          }
        } else {
          String error = response.errorMessage ?? 'Failed to resend code';
          if (response.jsonResponse != null) {
            error = response.jsonResponse?['message'] ?? error;
          }
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(error), backgroundColor: Colors.red),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _verifyAndNavigate() async {
    if (pinController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter the complete 6-digit code")),
      );
      return;
    }

    if (_userEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email not found. Please go back and try again.")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final isForgotPassword = _authFlow == AuthFlowModel.forgotPassword;
      final apiUrl = AppUrl.verifyEmail;

      // Prepare request body
      final Map<String, dynamic> requestBody = {
        "email": _userEmail,
        "otp": pinController.text,
      };

      // ✅ IMPORTANT: For SignUp flow, also need to send the verification token
      // For ForgotPassword flow, send the reset token
      if (_verificationToken != null && _verificationToken!.isNotEmpty) {
        requestBody["token"] = _verificationToken;
      }

      print('📤 Verify request to: $apiUrl');
      print('📤 Request body: $requestBody');
      print('📤 Auth Flow: ${isForgotPassword ? "Forgot Password" : "Sign Up"}');
      print('📤 Token included: ${_verificationToken != null}');

      final response = await _networkCaller.postRequest(
        apiUrl,
        body: requestBody,
      );

      print('📡 Response status: ${response.isSuccess}');
      print('📡 Response body: ${response.jsonResponse}');

      if (response.isSuccess) {
        // For signup flow, save tokens if provided
        if (!isForgotPassword) {
          final data = response.jsonResponse?['data']?['attributes'];
          if (data != null) {
            final accessToken = data['accessToken'];
            final refreshToken = data['refreshToken'];

            if (accessToken != null) {
              await SecureStorageService.instance.saveAccessToken(accessToken);
            }
            if (refreshToken != null) {
              await SecureStorageService.instance.saveRefreshToken(refreshToken);
            }
          }
        }

        // Clear temporary data after successful verification
        await SecureStorageService.instance.clearTemporaryData('reset_password_token');
        await SecureStorageService.instance.clearTemporaryData('reset_password_email');
        await SecureStorageService.instance.clearTemporaryData('auth_flow');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Email verified successfully!"),
              backgroundColor: Colors.green,
            ),
          );
        }

        // Navigate based on auth flow
        if (isForgotPassword) {
          // Forgot password flow - go to SetNewPasswordScreen
          Get.off(() => SetNewPasswordScreen(
            userEmail: _userEmail,
            otp: pinController.text,
          ));
        } else {
          // Sign up flow - go to CongratulationsScreen
          Get.off(() => const CongratulationsScreen());
        }
      } else {
        String error = response.errorMessage ?? 'Verification failed';
        if (response.jsonResponse != null) {
          error = response.jsonResponse?['message'] ?? error;
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      print('Error during verification: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    const focusedBorderColor = AppColors.primaryColor;
    const borderColor = AppColors.grey;

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Color.fromRGBO(30, 60, 87, 1),
        fontFamily: 'Plus Jakarta Sans',
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.15),
          Center(child: SvgPicture.asset("assets/images/logo.svg")),
          const Expanded(child: SizedBox()),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Verify E-mail",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Plus Jakarta Sans',
                ),
              ),
              const SizedBox(height: 12),
              Text(
                textAlign: TextAlign.center,
                "Please check your email ${_userEmail != null ? '($_userEmail)' : ''} and enter the code",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  fontFamily: 'Plus Jakarta Sans',
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 32),

              ///=========================
              /// PIN Input
              /// ========================
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Pinput(
                      length: 6,
                      controller: pinController,
                      focusNode: focusNode,
                      defaultPinTheme: defaultPinTheme,
                      separatorBuilder: (index) => const SizedBox(width: 8),
                      focusedPinTheme: defaultPinTheme.copyWith(
                        decoration: defaultPinTheme.decoration!.copyWith(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: focusedBorderColor),
                        ),
                      ),
                      onCompleted: (pin) {
                        _verifyAndNavigate();
                      },
                      cursor: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(bottom: 9),
                            width: 22,
                            height: 1,
                            color: focusedBorderColor,
                          ),
                        ],
                      ),
                      hapticFeedbackType: HapticFeedbackType.lightImpact,
                    ),
                  ),
                  const SizedBox(height: 24),

                  ///=========================
                  /// Timer Display
                  /// ========================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.clock, color: _isTimerActive ? AppColors.black : Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        _formatTime(_countdownSeconds),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _isTimerActive ? AppColors.black : Colors.grey,
                          fontFamily: 'Plus Jakarta Sans',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  ///=========================
                  /// Verify Button
                  /// ========================
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
                      onPressed: _isLoading ? null : _verifyAndNavigate,
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
                        'Verify Email',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          color: AppColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  ///=========================
                  /// Resend Code button
                  /// ========================
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "Didn't receive code? ",
                          style: TextStyle(
                            color: AppColors.black.withOpacity(0.6),
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 16,
                          ),
                        ),
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: (_isTimerActive || _isLoading) ? null : _resendCode,
                            child: Text(
                              "Resend code",
                              style: TextStyle(
                                color: (_isTimerActive || _isLoading) ? Colors.grey : AppColors.primaryColor,
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}