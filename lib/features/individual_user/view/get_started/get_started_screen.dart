import 'package:askfemi/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../onboarding/onboarding_screen.dart';


class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          Flexible(
            child: SizedBox(
              width: double.infinity,
              child: Image.asset(
                "assets/images/get_started.png",
                fit: BoxFit.cover, // fit goes inside Image.asset
              ),
            ),
          ),
          SizedBox(
            height:
                MediaQuery.of(context).size.height *
                0.03, // 3% of screen height
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Column(
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Welcome\nto ",
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 60,
                              fontWeight: FontWeight.bold,
                              color: AppColors.black,
                              height: 1.0,
                            ),
                          ),
                          TextSpan(
                            text: "Z3ns!",
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 60,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColorBlue,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.03),
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Expanded(
              child: Text(
                "A mindful space for your daily tasks. We believe in doing less, but better.",
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: AppColors.black,
                  height: 1.1,
                ),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.03),
          SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.09,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () {
                  Get.to(OnboardingScreen());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.textColorBlue,
                  foregroundColor: AppColors.white,
                  textStyle: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Optional rounded corners
                  ),
                  elevation: 0, // Remove shadow if needed
                ),
                child: const Text("Continue"),
              ),
            ),
          )
        ],
      ),
    );
  }
}
