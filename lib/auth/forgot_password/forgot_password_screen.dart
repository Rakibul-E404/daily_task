import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../utils/app_colors.dart';
import 'forgot_password_screen_controller.dart';

class ForgotPasswordScreen extends StatelessWidget {
  ForgotPasswordScreen({super.key});

  final ForgotPasswordController controller = Get.put(ForgotPasswordController());

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
          color: AppColors.backgroundColor,
          borderRadius: BorderRadius.only(
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
                "Forgot your Password",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Plus Jakarta Sans',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Please enter your email to reset password.",
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
                controller: controller.emailController,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppColors.grey, width: 2.0),
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

              const SizedBox(height: 20),

              /// Error message display
              Obx(() => controller.errorMessage.value.isNotEmpty
                  ? Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  controller.errorMessage.value,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                ),
              )
                  : const SizedBox.shrink()),

              ///=======================
              /// Send OTP button
              /// ========================
              SizedBox(
                width: double.infinity,
                height: 50,
                child: Obx(() => ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: controller.isLoading.value ? null : () => controller.sendResetOtp(),
                  child: controller.isLoading.value
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    'Send OTP',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      color: AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}