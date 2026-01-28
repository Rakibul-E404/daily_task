// import 'package:askfemi/auth/sign_up/sign_up_screen.dart';
// import 'package:askfemi/utils/app_colors.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:get/get_core/src/get_main.dart';
// import 'package:get/get_navigation/src/extension_navigation.dart';
// import '../../individual_user/features/home/app_open_home_screen.dart';
//
// class SetNewPasswordScreen extends StatelessWidget {
//   SetNewPasswordScreen({super.key}) {
//     // Initialize the ValueNotifier
//     _obscurePassword = ValueNotifier<bool>(true);
//   }
//
//   // Use ValueNotifier for password visibility
//   late final ValueNotifier<bool> _obscurePassword;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundColor,
//       body: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           SizedBox(height: MediaQuery.of(context).size.height * 0.45),
//           SvgPicture.asset("assets/images/logo.svg"),
//         ],
//       ),
//       bottomSheet: Container(
//         height: MediaQuery.of(context).size.height * 0.65,
//         width: double.infinity,
//         padding: const EdgeInsets.all(24),
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(80),
//             topRight: Radius.circular(80),
//           ),
//           border: Border(
//             top: BorderSide(color: AppColors.primaryColor, width: 1.5),
//           ),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text(
//               "Set New Password",
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 fontFamily: 'Plus Jakarta Sans',
//               ),
//             ),
//             const SizedBox(height: 24),
//
//             ///===============================
//             ///========= password  ===========
//             ///===============================
//             ValueListenableBuilder<bool>(
//               valueListenable: _obscurePassword,
//               builder: (context, isObscured, child) {
//                 return TextField(
//                   obscureText: isObscured,
//                   decoration: InputDecoration(
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                       borderSide: const BorderSide(
//                         color: AppColors.grey,
//                         width: 2.0,
//                       ),
//                     ),
//                     prefixIcon: Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 12),
//                       child: IntrinsicHeight(
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Icon(Icons.lock, color: Colors.grey[700]),
//                             const SizedBox(width: 12),
//                             Padding(
//                               padding: const EdgeInsets.only(top: 8, bottom: 8),
//                               child: VerticalDivider(
//                                 color: AppColors.grey,
//                                 width: 1,
//                                 thickness: 1.0,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     suffixIcon: IconButton(
//                       icon: Icon(
//                         isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
//                         color: AppColors.grey,
//                       ),
//                       onPressed: () {
//                         // Toggle password visibility
//                         _obscurePassword.value = !_obscurePassword.value;
//                       },
//                     ),
//                     hintText: 'Enter Password',
//                     hintStyle: TextStyle(fontFamily: 'Plus Jakarta Sans'),
//                     border: const OutlineInputBorder(
//                       borderRadius: BorderRadius.all(Radius.circular(10)),
//                       borderSide: BorderSide(color: AppColors.grey),
//                     ),
//                     enabledBorder: const OutlineInputBorder(
//                       borderRadius: BorderRadius.all(Radius.circular(10)),
//                       borderSide: BorderSide(color: AppColors.grey),
//                     ),
//                   ),
//                 );
//               },
//             ),
//
//             const SizedBox(height: 16),
//
//             ///===============================
//             ///========= Password ===========
//             ///===============================
//             ValueListenableBuilder<bool>(
//               valueListenable: _obscurePassword,
//               builder: (context, isObscured, child) {
//                 return TextField(
//                   obscureText: isObscured,
//                   decoration: InputDecoration(
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                       borderSide: const BorderSide(
//                         color: AppColors.grey,
//                         width: 2.0,
//                       ),
//                     ),
//                     prefixIcon: Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 12),
//                       child: IntrinsicHeight(
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Icon(Icons.lock, color: Colors.grey[700]),
//                             const SizedBox(width: 12),
//                             Padding(
//                               padding: const EdgeInsets.only(top: 8, bottom: 8),
//                               child: VerticalDivider(
//                                 color: AppColors.grey,
//                                 width: 1,
//                                 thickness: 1.0,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     suffixIcon: IconButton(
//                       icon: Icon(
//                         isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
//                         color: AppColors.grey,
//                       ),
//                       onPressed: () {
//                         // Toggle password visibility
//                         _obscurePassword.value = !_obscurePassword.value;
//                       },
//                     ),
//                     hintText: 'Confirm Password',
//                     hintStyle: TextStyle(fontFamily: 'Plus Jakarta Sans'),
//                     border: const OutlineInputBorder(
//                       borderRadius: BorderRadius.all(Radius.circular(10)),
//                       borderSide: BorderSide(color: AppColors.grey),
//                     ),
//                     enabledBorder: const OutlineInputBorder(
//                       borderRadius: BorderRadius.all(Radius.circular(10)),
//                       borderSide: BorderSide(color: AppColors.grey),
//                     ),
//                   ),
//                 );
//               },
//             ),
//             const SizedBox(height: 30),
//             ///=======================
//             /// sign in button
//             /// ========================
//             SizedBox(
//               width: double.infinity,
//               height: 50,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.primaryColor,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 onPressed: () {
//                   Get.offAll(AppOpenHomeScreen());
//                 },
//                 child: const Text(
//                   'Save Password',
//                   style: TextStyle(
//                     fontFamily: 'Plus Jakarta Sans',
//                     color: AppColors.white,
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:askfemi/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../individual_user/features/home/app_open_home_screen.dart';

class SetNewPasswordScreen extends StatelessWidget {
  SetNewPasswordScreen({super.key}) {
    _obscurePassword = ValueNotifier<bool>(true);
  }

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
          children: [
            const Text(
              "Set New Password",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Plus Jakarta Sans',
              ),
            ),
            const SizedBox(height: 24),

            /// New Password
            ValueListenableBuilder<bool>(
              valueListenable: _obscurePassword,
              builder: (context, isObscured, _) {
                return TextField(
                  obscureText: isObscured,
                  decoration: _inputDecoration(
                    hint: "Enter Password",
                    isObscured: isObscured,
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            /// Confirm Password
            ValueListenableBuilder<bool>(
              valueListenable: _obscurePassword,
              builder: (context, isObscured, _) {
                return TextField(
                  obscureText: isObscured,
                  decoration: _inputDecoration(
                    hint: "Confirm Password",
                    isObscured: isObscured,
                  ),
                );
              },
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
                ),
                onPressed: () {
                  _showSuccessBottomSheet(context);
                },
                child: const Text(
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
    );
  }

  /// Input Decoration
  InputDecoration _inputDecoration({
    required String hint,
    required bool isObscured,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontFamily: 'Plus Jakarta Sans'),
      prefixIcon: const Icon(Icons.lock, color: AppColors.grey),
      suffixIcon: IconButton(
        icon: Icon(
          isObscured
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          color: AppColors.grey,
        ),
        onPressed: () {
          _obscurePassword.value = !_obscurePassword.value;
        },
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.grey),
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
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(30),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),

              /// Key Circle (SVG)
              Container(
                height: 90,
                width: 90,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFE8F1FF),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    "assets/icons/key.svg",
                    height: 40,
                    width: 40,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                "Password Update Successfully",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Plus Jakarta Sans',
                ),
              ),

              const SizedBox(height: 8),

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
                    "Go to homepage",
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
