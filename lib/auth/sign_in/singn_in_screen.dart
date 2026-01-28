import 'package:askfemi/auth/password/set_new_password_screen.dart';
import 'package:askfemi/auth/sign_up/sign_up_screen.dart';
import 'package:askfemi/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import '../../individual_user/features/home/app_open_home_screen.dart';

class SignInScreen extends StatelessWidget {
  SignInScreen({super.key}) {
    // Initialize the ValueNotifier
    _obscurePassword = ValueNotifier<bool>(true);
  }

  // Use ValueNotifier for password visibility
  late final ValueNotifier<bool> _obscurePassword;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.45),
          SvgPicture.asset("assets/images/logo.svg"),
        ],
      ),
      bottomSheet: Container(
        height: MediaQuery.of(context).size.height * 0.65,
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(80),
            topRight: Radius.circular(80),
          ),
          border: Border(
            top: BorderSide(color: AppColors.primaryColor, width: 1.5),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Sign in your account",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Plus Jakarta Sans',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Welcome back! Please enter your details.",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.normal,
                fontFamily: 'Plus Jakarta Sans',
              ),
            ),
            const SizedBox(height: 24),

            ///===============================
            ///========= E-mail ===========
            ///===============================
            TextField(
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.grey, width: 2.0),
                ),
                prefixIcon: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: IntrinsicHeight(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.email_rounded, color: Colors.grey[700]),
                        const SizedBox(width: 12),
                        Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 8),
                          child: VerticalDivider(
                            color: AppColors.grey,
                            width: 1,
                            thickness: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                hintText: 'E-mail',
                hintStyle: TextStyle(fontFamily: 'Plus Jakarta Sans'),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(color: AppColors.grey),
                ),
              ),
            ),
            const SizedBox(height: 24),

            ///===============================
            ///========= Password ===========
            ///===============================
            ValueListenableBuilder<bool>(
              valueListenable: _obscurePassword,
              builder: (context, isObscured, child) {
                return TextField(
                  obscureText: isObscured,
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: AppColors.grey,
                        width: 2.0,
                      ),
                    ),
                    prefixIcon: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: IntrinsicHeight(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.lock, color: Colors.grey[700]),
                            const SizedBox(width: 12),
                            Padding(
                              padding: const EdgeInsets.only(top: 8, bottom: 8),
                              child: VerticalDivider(
                                color: AppColors.grey,
                                width: 1,
                                thickness: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isObscured ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.grey,
                      ),
                      onPressed: () {
                        // Toggle password visibility
                        _obscurePassword.value = !_obscurePassword.value;
                      },
                    ),
                    hintText: 'Enter Password',
                    hintStyle: TextStyle(fontFamily: 'Plus Jakarta Sans'),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: AppColors.grey),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: AppColors.grey),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Get.to(()=> SetNewPasswordScreen());
                  },
                  child: Text(
                    "Forgot Password?",
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      color: AppColors.black,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.black,
                      decorationThickness: 1.0,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ///=======================
            /// sign in button
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
                onPressed: () {
                  Get.offAll(AppOpenHomeScreen());
                },
                child: const Text(
                  'Sign in',
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
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "Don’t have an account? ",
                    style: TextStyle(
                      color: AppColors.black.withValues(alpha:0.6),
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: () {
                        Get.to(()=> SignUpScreen());
                      },
                      child: Text(
                        "Sign up",
                        style: TextStyle(
                          color: AppColors.black,
                          fontFamily: 'Plus Jakarta Sans',
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "OR",
              style: TextStyle(
                color: AppColors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                fontFamily: 'Plus Jakarta Sans',
              ),
            ),
            const SizedBox(height: 20),
            SvgPicture.asset("assets/icons/google.svg"),

          ],
        ),
      ),
    );
  }
}
