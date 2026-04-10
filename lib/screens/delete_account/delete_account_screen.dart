// delete_account_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_texts_style.dart';
import '../../../../utils/network/secure_storage_service.dart';
import '../../auth/sign_up/sign_up_screen.dart';
import 'delete_account_controller.dart';

class DeleteAccountScreen extends StatelessWidget {
  const DeleteAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DeleteAccountController controller = Get.put(DeleteAccountController());

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Delete Account',
          style: AppTextStyles.largeHeading.copyWith(
            fontSize: 24,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: Colors.red,
                ),
                SizedBox(height: 16),
                Text(
                  'Deleting account...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Warning Icon and Title
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        size: 50,
                        color: Colors.red.shade700,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Are you sure?',
                      style: AppTextStyles.largeHeading.copyWith(
                        fontSize: 28,
                        color: Colors.red.shade700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'This action cannot be undone. Deleting your account will:',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.defaultTextStyle.copyWith(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              /// List of consequences
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    _buildConsequenceItem(
                      Icons.person_off_outlined,
                      'Permanently delete your profile information',
                    ),
                    const SizedBox(height: 12),
                    _buildConsequenceItem(
                      Icons.task_alt_outlined,
                      'Remove all your tasks and history',
                    ),
                    const SizedBox(height: 12),
                    _buildConsequenceItem(
                      Icons.group_off_outlined,
                      'Remove you from all groups and collaborations',
                    ),
                    const SizedBox(height: 12),
                    _buildConsequenceItem(
                      Icons.email_outlined,
                      'Unsubscribe from all notifications',
                    ),
                    const SizedBox(height: 12),
                    _buildConsequenceItem(
                      Icons.cloud_off_outlined,
                      'Permanently delete your data from our servers',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              /// Password confirmation
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Confirm Password',
                      style: AppTextStyles.smallHeading.copyWith(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      onChanged: (value) => controller.updatePassword(value),
                      obscureText: !controller.isPasswordVisible.value,
                      decoration: InputDecoration(
                        hintText: 'Enter your password to confirm',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        prefixIcon: const Icon(Icons.lock_outline, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.isPasswordVisible.value
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20,
                          ),
                          onPressed: () => controller.togglePasswordVisibility(),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: AppColors.primaryColor, width: 1),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),

                    /// Error message
                    if (controller.errorMessage.value.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, size: 16, color: Colors.red.shade400),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                controller.errorMessage.value,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red.shade400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              /// Delete Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    _showDeleteConfirmationDialog(context, controller);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Delete My Account',
                    style: AppTextStyles.defaultTextStyle.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// Contact Support Text
              Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Having trouble? ',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      TextSpan(
                        text: 'Contact Support',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildConsequenceItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.red.shade400),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, DeleteAccountController controller) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permanent Deletion'),
          content: const Text(
            'Are you absolutely sure? This action is permanent and cannot be undone.',
            style: TextStyle(fontSize: 14),
          ),
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Get.back(); // Close dialog
                final success = await controller.deleteAccount();

                if (success) {
                  // Clear all local data
                  await SecureStorageService.instance.clearAll();

                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Account deleted successfully'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );

                  // Navigate to Sign Up screen (not Sign In)
                  Get.offAll(() => const SignUpScreen());
                } else {
                  // Show error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(controller.errorMessage.value),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Yes, Delete'),
            ),
          ],
        );
      },
    );
  }
}