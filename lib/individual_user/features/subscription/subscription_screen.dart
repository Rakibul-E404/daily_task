import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import '../../../utils/app_colors.dart';
import 'package:askfemi/individual_user/features/bottom_navigation/main_bottom_nav.dart';

class SubscriptionPage extends StatelessWidget {
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0,right: 20,bottom: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  textAlign: TextAlign.center,
                  'Choose The Plan That Fits Your Needs',
                  style: TextStyle(
                    fontFamily: "Plus Jakarta Sans",
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                // Header Subtitle
                const Text(
                  'Manage tasks efficiently — for yourself or your entire group.',
                  style: TextStyle(
                    fontFamily: "Plus Jakarta Sans",
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 32),
            
                // Individual Subscription Card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Bar
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF333333),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             Text(
                              'Individual Subscription',
                              style: TextStyle(
                                fontFamily: "Plus Jakarta Sans",
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 8,),
                            // Description
                            const Text(
                              'Perfect for individuals who want to manage their own tasks with focus and simplicity.',
                              style: TextStyle(
                                fontFamily: "Plus Jakarta Sans",
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),


                      const SizedBox(height: 16),

                      // Price
                      Row(
                        children: [
                          const Text(
                            '\$10.99',
                            style: TextStyle(
                              fontFamily: "Plus Jakarta Sans",
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.subscriptionPriceTextColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '/ Month',
                            style: TextStyle(
                              fontFamily: "Plus Jakarta Sans",
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Label
                      const Text(
                        'Basic Monthly Package',
                        style: TextStyle(
                          fontFamily: "Plus Jakarta Sans",
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Free Trial Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            textAlign: TextAlign.center,
                            'Start Free Trial 7 days',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: "Plus Jakarta Sans",
                              fontSize: 14,
                              color: AppColors.black,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            CupertinoIcons.link,
                            size: 16,
                            color: AppColors.black,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // "Get Started Now" Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Get.to(()=> MainBottomNav());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Get Started Now',
                            style: TextStyle(
                                fontFamily: "Plus Jakarta Sans",
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildFeatureList([
                        'Single-user account',
                        'Create personal tasks',
                        'Single-user account', // duplicate? maybe typo in image
                        'Start tasks anytime',
                        'Mark tasks as completed',
                        'Private task visibility',
                        'No shared tasks or assignments',
                      ]),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
            
                // Business Subscription Card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primaryColor, width: 1),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            textAlign: TextAlign.center,
                            'Business Subscription',
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: "Plus Jakarta Sans",
                              fontWeight: FontWeight.bold,
                              color: AppColors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
            
                      const Text(
                        textAlign: TextAlign.center,
                        'To create and manage group tasks, please upgrade to the Group Subscription. Visit our website to explore and purchase the Group Plan.',
                        style: TextStyle(
                          fontSize: 13,
                          fontFamily: "Plus Jakarta Sans",
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
            
                      GestureDetector(
                        onTap: () {
                          // Open browser or navigate to business page
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Opening business page...')),
                          );
                        },
                        child: const Text(
                          'Learn more at: www.taskmanagement.com',
                          style: TextStyle(
                            fontFamily: "Plus Jakarta Sans",
                            fontSize: 14,
                            color: AppColors.black,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper: Build feature list with radio-style bullets
  Widget _buildFeatureList(List<String> features) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),color: AppColors.primaryColor.withValues(alpha: 0.1)),
      child: Column(
        children: features.map((feature) {
          return Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Icon(Icons.check_circle_outline,color: AppColors.primaryColor,size: 15,),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    feature,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}