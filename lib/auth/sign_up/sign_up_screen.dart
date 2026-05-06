import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../features/individual_user/widget/date_input_field.dart';
import '../../utils/app_colors.dart';
import 'manual_sign_up_screen_controller.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ManualSignUpController());
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Obx(() {
        return Stack(
          children: [
            /// ================= TOP LOGO =================
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: height * 0.12),
                child: SvgPicture.asset(
                  "assets/images/logo.svg",
                  height: height * 0.18,
                ),
              ),
            ),

            /// ================= BOTTOM SHEET =================
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: height * 0.65,
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(80),
                    topRight: Radius.circular(80),
                  ),
                  border: Border(
                    top: BorderSide(
                      color: AppColors.primaryColor,
                      width: 1.5,
                    ),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Create an account",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Plus Jakarta Sans',
                        ),
                      ),

                      const SizedBox(height: 24),



                      ///==================================
                      ///============ User Name
                      ///==================================
                      TextField(
                        maxLength: 18,
                        onChanged: (value) => controller.updateName(value),
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
                                  Icon(
                                    CupertinoIcons.person_crop_circle,
                                    color: Colors.grey[700],
                                  ),
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
                          hintText: 'User Name',
                          hintStyle: const TextStyle(fontFamily: 'Plus Jakarta Sans'),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(color: AppColors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      ///==================================
                      ///============ E-mail
                      ///==================================
                      TextField(
                        onChanged: (value) => controller.updateEmail(value),
                        keyboardType: TextInputType.emailAddress,
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
                                  Icon(Icons.email_outlined, color: Colors.grey[700]),
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
                          hintStyle: const TextStyle(fontFamily: 'Plus Jakarta Sans'),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(color: AppColors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      ///==================================
                      ///============ Phone Number (Numbers and + only)
                      ///==================================
                      TextField(
                        onChanged: (value) => controller.updatePhoneNumber(value),
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^[0-9+]+$')),  // Allows numbers and + symbol
                          LengthLimitingTextInputFormatter(15),  // Limit to 15 characters
                        ],
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
                                  Icon(CupertinoIcons.phone, color: Colors.grey[700]),
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
                          hintText: 'Phone number',
                          hintStyle: const TextStyle(fontFamily: 'Plus Jakarta Sans'),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(color: AppColors.grey),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      ///==================================
                      ///============ Gender
                      ///==================================
                      DropdownSearch<String>(
                        items: (filter, infiniteScrollProps) async {
                          return ["Male", "Female"];
                        },
                        onChanged: (value) {
                          if (value != null) {
                            controller.updateGender(value);
                          }
                        },
                        selectedItem: controller.gender.value.isEmpty ? null : controller.gender.value,
                        popupProps: PopupProps.menu(
                          showSearchBox: false,
                          fit: FlexFit.loose,
                          menuProps: MenuProps(
                            backgroundColor: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            elevation: 4,
                          ),
                        ),
                        decoratorProps: DropDownDecoratorProps(
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: AppColors.grey, width: 2.0),
                            ),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: IntrinsicHeight(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      CupertinoIcons.person,
                                      color: Colors.grey[700],
                                    ),
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
                            hintText: 'Select Gender',
                            hintStyle: const TextStyle(fontFamily: 'Plus Jakarta Sans'),
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(color: AppColors.grey),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      ///==================================
                      ///============ Date of Birth
                      ///==================================
                      DateOfBirthField(
                        onDateSelected: (dateString) {
                          controller.updateDateOfBirth(dateString);
                        },
                      ),
                      const SizedBox(height: 24),

                      ///==================================
                      ///============ Age (Numbers Only)
                      ///==================================
                      Obx(() => TextField(
                        controller: TextEditingController(
                          text: controller.age.value,
                        )..selection = TextSelection.fromPosition(
                          TextPosition(offset: controller.age.value.length),
                        ),
                        onChanged: (value) => controller.updateAge(value),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(3),
                        ],
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
                                  Icon(
                                    CupertinoIcons.person_3_fill,
                                    color: Colors.grey[700],
                                  ),
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
                          hintText: 'Age (Auto-calculated)',
                          hintStyle: const TextStyle(fontFamily: 'Plus Jakarta Sans'),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(color: AppColors.grey),
                          ),
                        ),
                      )),
                      const SizedBox(height: 24),

                      ///===============================
                      ///========= Password ===========
                      ///===============================
                      Obx(() => TextField(
                        onChanged: (value) => controller.updatePassword(value),
                        obscureText: controller.isPasswordObscured.value,
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
                                  Icon(Icons.lock_outline, color: Colors.grey[700]),
                                  const SizedBox(width: 12),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 8,
                                      bottom: 8,
                                    ),
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
                              controller.isPasswordObscured.value
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.grey,
                            ),
                            onPressed: () => controller.togglePasswordVisibility(),
                          ),
                          hintText: 'Enter Password',
                          hintStyle: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                          ),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(color: AppColors.grey),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(color: AppColors.grey),
                          ),
                        ),
                      )),
                      const SizedBox(height: 10),

                      /// Error message
                      Obx(() {
                        if (controller.errorMessage.value.isNotEmpty) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    controller.errorMessage.value,
                                    style: TextStyle(color: Colors.red.shade700, fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }),

                      /// Password requirements
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 4, top: 4),
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
                        ],
                      ),

                      ///=========================
                      /// Terms & Conditions Checkbox
                      /// ========================
                      Row(
                        children: [
                          Obx(() => Checkbox(
                            value: controller.agreeToTerms.value,
                            activeColor: AppColors.primaryColor,
                            side: const BorderSide(),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                            onChanged: (bool? newValue) {
                              controller.updateTermsAgreement(newValue ?? false);
                            },
                          )),
                          const SizedBox(width: 8),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                print("Terms and conditions clicked");
                              },
                              child: const Text(
                                "By creating an account, I accept the Terms & Conditions & Privacy Policy.",
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 14,
                                  color: AppColors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      ///=========================
                      /// Sign Up Button
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
                          onPressed: controller.isLoading.value ? null : () async {
                            final success = await controller.signUp();
                            if (success) {
                              // Navigation handled inside controller
                            }
                          },
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
                            'Sign up',
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
                      /// Sign In Text
                      /// ========================
                      GestureDetector(
                        onTap: () {
                          Get.back();
                        },
                        child: RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: "Already have an account? ",
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontFamily: 'Plus Jakarta Sans',
                                ),
                              ),
                              TextSpan(
                                text: "Sign in",
                                style: TextStyle(
                                  color: AppColors.black,
                                  fontFamily: 'Plus Jakarta Sans',
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      ///=========================
                      /// OR Divider
                      /// ========================
                      const Text(
                        "OR",
                        style: TextStyle(
                          color: AppColors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          fontFamily: 'Plus Jakarta Sans',
                        ),
                      ),
                      const SizedBox(height: 20),

                      ///=========================
                      /// Google Sign In
                      /// ========================
                      GestureDetector(
                        onTap: () {
                          print("Google Sign In tapped");
                        },
                        child: SvgPicture.asset("assets/icons/google.svg"),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}