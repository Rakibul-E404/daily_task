import 'package:askfemi/individual_user/features/bottom_navigation/main_bottom_nav.dart';
import 'package:askfemi/individual_user/features/home/app_open_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

import '../home/home_screen.dart';

class ChooseSupportModeScreen extends StatefulWidget {
  const ChooseSupportModeScreen({super.key});

  @override
  State<ChooseSupportModeScreen> createState() =>
      _ChooseSupportModeScreenState();
}

class _ChooseSupportModeScreenState extends State<ChooseSupportModeScreen> {
  String? selectedMode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 60),

              // Title
              const Text(
                'Choose Your Support Style',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: 'Plus Jakarta Sans',
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Subtitle
              Text(
                'How would you like Clarity to communicate with you?',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontFamily: 'Plus Jakarta Sans',
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Support Style Cards
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildSupportCard(
                        mode: 'calm',
                        emoji: '😌',
                        title: 'Calm',
                        description:
                        'Gentle guidance with peaceful reminders and soothing encouragement.',
                        quote: '"Take your time. Each small step matters."',
                        isSelected: selectedMode == 'calm',
                      ),
                      const SizedBox(height: 16),
                      _buildSupportCard(
                        mode: 'encouraging',
                        emoji: '📢',
                        title: 'Encouraging',
                        description:
                        'Positive energy with motivational reminders and uplifting support.',
                        quote: '"You\'re doing great! Keep up the momentum!"',
                        isSelected: selectedMode == 'encouraging',
                      ),
                      const SizedBox(height: 16),
                      _buildSupportCard(
                        mode: 'logical',
                        emoji: '💡',
                        title: 'Logical',
                        description:
                        'Gentle guidance with peaceful reminders and soothing encouragement.',
                        quote: null,
                        isSelected: selectedMode == 'logical',
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Get Started Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: selectedMode != null
                      ? () {
                    // Handle get started
                    debugPrint('Selected mode: $selectedMode');
                    Get.offAll(MainBottomNav());
                    // Navigate to next screen
                  }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A9DFF),
                    disabledBackgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: selectedMode != null ? Colors.white : Colors.grey[500],
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSupportCard({
    required String mode,
    required String emoji,
    required String title,
    required String description,
    String? quote,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMode = mode;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F4FF) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF4A9DFF) : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emoji and Title Row
            Row(
              children: [
                // Emoji Circle
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _getEmojiBackgroundColor(mode),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Title
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              description,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
                height: 1.5,
                fontFamily: 'Plus Jakarta Sans',
              ),
            ),

            // Quote (if available)
            if (quote != null) ...[
              const SizedBox(height: 12),
              Text(
                quote,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                  fontFamily: 'Plus Jakarta Sans',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getEmojiBackgroundColor(String mode) {
    switch (mode) {
      case 'calm':
        return const Color(0xFFD4E9FF);
      case 'encouraging':
        return const Color(0xFFFFE5E5);
      case 'logical':
        return const Color(0xFFFFF4D4);
      default:
        return Colors.grey[200]!;
    }
  }
}