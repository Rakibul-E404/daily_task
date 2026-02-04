import 'package:askfemi/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

import '../../../../auth/sign_in/singn_in_screen.dart';
import '../../../../widget/dotted_line_widget.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Stack(
        children: [
          // Top-right background image
          Positioned(
            top: 30,
            right: -50,
            child: Image.asset(
              'assets/images/onbording_anguler_shape.png',
              width: 200,
              height: 200,
            ),
          ),

          // Bottom-left background image
          Positioned(
            bottom: 110,
            left: -50,
            child: Image.asset(
              'assets/images/onbording_bottom_shape.png',
              width: 200,
              height: 200,
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  SizedBox(height: MediaQuery
                      .of(context)
                      .size
                      .height * 0.2),
                  // Expanded scrollable content
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 20),

                          // Title
                          Text(
                            "Less is More",
                            style: const TextStyle(
                              fontSize: 26,
                              fontFamily: 'Plus Jakarta Sans',
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 12),
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "Clarity helps you focus on ",
                                  style: TextStyle(
                                    color: AppColors.black,
                                    fontSize: 15,
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                TextSpan(
                                  text: "3-5 ",
                                  style: const TextStyle(
                                    color: AppColors.primaryColor,
                                    fontSize: 15,
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                TextSpan(
                                  text:
                                  "meaningful tasks per day. No overwhelm, just intentional progress",
                                  style: const TextStyle(
                                    color: AppColors.black,
                                    fontSize: 15,
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 40),

                          // Info Card
                          Card(
                            color: AppColors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                width: 1.5,
                                color: AppColors.secondaryColor,
                              ),
                            ),
                            elevation: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  _buildInfoRow(
                                    icon:  SvgPicture.asset("assets/images/daily_focus.svg"),
                                    title: 'Daily Focus',
                                    subtitle: '3–5 tasks max per day',
                                  ),
                                  const DottedLine(
                                    height: 1,
                                    color: AppColors.primaryColor,
                                    dashWidth: 4,
                                    dashSpacing: 4,
                                  ),
                                  _buildInfoRow(
                                    icon:  SvgPicture.asset("assets/images/mental_clarity.svg"),
                                    title: 'Mental Clarity',
                                    subtitle: 'Calm interface, zero clutter',
                                  ),
                                  const DottedLine(
                                    height: 1,
                                    color: AppColors.primaryColor,
                                    dashWidth: 4,
                                    dashSpacing: 4,
                                  ),
                                  _buildInfoRow(
                                    icon:  SvgPicture.asset("assets/images/adaptive_support.svg",),
                                    title: 'Adaptive Support',
                                    subtitle: 'Learns your rhythm and adapts',
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),

                  // Continue button at bottom
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
                        Get.to(SignInScreen());
                      },
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          color: AppColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: MediaQuery
                      .of(context)
                      .size
                      .height * 0.03),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required Widget icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: Center(child: icon),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


}
