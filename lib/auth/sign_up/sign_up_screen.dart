import 'package:askfemi/auth/sign_in/singn_in_screen.dart';
import 'package:askfemi/auth/verify/verify_email_screen.dart';
import 'package:askfemi/utils/app_colors.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

import '../../widget/date_input_field.dart';

class SignUpScreen extends StatefulWidget {
  SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Use ValueNotifier for password visibility
  late final ValueNotifier<bool> _obscurePassword;
  // Add state for checkbox
  bool _agreeToTerms = false;

  @override
  void initState() {
    super.initState();
    _obscurePassword = ValueNotifier<bool>(true);
  }

  @override
  void dispose() {
    _obscurePassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              const SizedBox(height: 24),

              ///==================================
              ///============ E-mail
              ///==================================
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
              ///============ Phone Number
              ///==================================
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
                  return ["Male", "Female", "Other"];
                },
                popupProps: PopupProps.menu(
                  showSearchBox: false,
                  fit: FlexFit.loose,
                  menuProps: MenuProps(
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
                onChanged: (value) {
                  print("Selected gender: $value");
                },
              ),
              const SizedBox(height: 24),

              ///==================================
              ///============ Date of Birth
              ///==================================
              DateOfBirthField(
                onDateSelected: (dateString) {
                  print('DOB: $dateString'); // e.g., "05 - 14 - 1990"
                },
              ),
              const SizedBox(height: 24),

              ///==================================
              ///============ Age
              ///==================================
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
                  hintText: 'Age',
                  hintStyle: const TextStyle(fontFamily: 'Plus Jakarta Sans'),
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
                          isObscured ? Icons.visibility_off : Icons.visibility,
                          color: AppColors.grey,
                        ),
                        onPressed: () {
                          // Toggle password visibility
                          _obscurePassword.value = !_obscurePassword.value;
                        },
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
                  );
                },
              ),
              const SizedBox(height: 24),

              ///=========================
              /// Terms & Conditions Checkbox
              /// ========================
              Row(
                children: [
                  Checkbox(
                    value: _agreeToTerms,
                    activeColor: AppColors.primaryColor,
                    side: BorderSide(),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                    onChanged: (bool? newValue) {
                      setState(() {
                        _agreeToTerms = newValue ?? false;
                      });
                      print("Terms agreed: $_agreeToTerms");
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // Handle terms and conditions click
                        print("Terms and conditions clicked");
                        // You could navigate to a terms screen here
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
                  onPressed: () {
                    // Optional: Check if terms are agreed before proceeding
                    if (!_agreeToTerms) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please agree to terms & conditions"),
                        ),
                      );
                      return;
                    }
                    Get.to(()=> VerifyEmailScreen());
                  },
                  child: const Text(
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
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Already have an account? ",
                      style: TextStyle(
                        color: AppColors.black.withValues(alpha: 0.6),
                        fontFamily: 'Plus Jakarta Sans',
                      ),
                    ),
                    WidgetSpan(
                      child: GestureDetector(
                        onTap: () {
                          Get.to(() => SignInScreen());
                        },
                        child: Text(
                          "Sign in",
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
              SvgPicture.asset("assets/images/google.svg"),
            ],
          ),
        ),
      ),
    );
  }
}