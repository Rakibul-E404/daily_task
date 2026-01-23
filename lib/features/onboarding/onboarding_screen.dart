import 'package:askfemi/utils/app_colors.dart';
import 'package:flutter/material.dart';

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
            bottom: 30,
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
                  // Skip button
                  Align(
                    alignment: Alignment.topRight,
                    child: TextButton(
                      onPressed: () {
                        // TODO: Navigate to next screen
                      },
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: AppColors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

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

                          // Subtitle
                          Text(
                            "Clarity helps you focus on 3-5 meaningful tasks per day. "
                                "No overwhelm, just intentional progress",
                            style: const TextStyle(
                              fontSize: 15,
                              fontFamily: 'Plus Jakarta Sans',
                              fontWeight: FontWeight.normal,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 40),

                          // Info Card
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  _buildInfoRow(
                                      icon: '🎯',
                                      title: 'Daily Focus',
                                      subtitle: '3–5 tasks max per day'),
                                  const Divider(),
                                  _buildInfoRow(
                                      icon: '🧠',
                                      title: 'Mental Clarity',
                                      subtitle: 'Calm interface, zero clutter'),
                                  const Divider(),
                                  _buildInfoRow(
                                      icon: '🌱',
                                      title: 'Adaptive Support',
                                      subtitle: 'Learns your rhythm and adapts'),
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
                        // TODO: Navigate to next screen
                      },
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required String icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                      fontWeight: FontWeight.normal, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
