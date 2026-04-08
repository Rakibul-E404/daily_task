import 'dart:io';
import 'package:askfemi/screens/personal_information/personal_Infromation_screen_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../utils/app_colors.dart';
import '../../../../../utils/app_texts_style.dart';
import '../../features/individual_user/widget/edit_update_button.dart';
import 'edit_personal_profile_info_screen.dart';

/// ===============================================================
/// PERSONAL INFORMATION SCREEN (VIEW MODE)
/// ===============================================================
class PersonalInformationScreen extends StatelessWidget {
  const PersonalInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PersonalInformationController controller = Get.put(PersonalInformationController());

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.transparent,
        elevation: 0,
        title: Text('Personal Information', style: AppTextStyles.largeHeading),
      ),
      body: Obx(() {
        // Show network error UI
        if (controller.isNetworkError.value) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    controller.isServerError.value ? Icons.cloud_off_outlined : Icons.wifi_off_outlined,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    controller.isServerError.value ? 'Server Error' : 'No Internet Connection',
                    style: AppTextStyles.largeHeading.copyWith(
                      fontSize: 20,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    controller.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.smallText.copyWith(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => controller.retryFetch(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Retry',
                      style: AppTextStyles.defaultTextStyle.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }


        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.errorMessage.value.isNotEmpty && !controller.isNetworkError.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.wifi_off_outlined,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  controller.errorMessage.value,
                  style: AppTextStyles.defaultTextStyle.copyWith(
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.retryFetch(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Retry',
                    style: AppTextStyles.defaultTextStyle.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            /// SCROLLABLE CONTENT
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 16),
                child: Card(
                  color: AppColors.backgroundColor,
                  margin: const EdgeInsets.all(16),
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProfileAvatar(
                          imageUrl: controller.userProfileImage.value,
                          userName: controller.userName.value,
                        ),
                        const SizedBox(height: 30),

                        InfoRow(
                          label: 'Name',
                          value: controller.userName.value.isEmpty ? 'Not specified' : controller.userName.value,
                        ),
                        InfoRow(
                          label: 'Email',
                          value: controller.userEmail.value.isEmpty ? 'Not specified' : controller.userEmail.value,
                        ),
                        InfoRow(
                          label: 'Phone number',
                          value: controller.userPhoneNumber.value.isEmpty ? 'Not specified' : controller.userPhoneNumber.value,
                        ),
                        InfoRow(
                          label: 'Address',
                          value: controller.userAddress.value.isEmpty ? 'Not specified' : controller.userAddress.value,
                        ),
                        InfoRow(
                          label: 'Gender',
                          value: controller.userGender.value.isEmpty ? 'Not specified' : controller.userGender.value,
                        ),
                        InfoRow(
                          label: 'Date of Birth',
                          value: controller.userDateOfBirth.value.isEmpty ? 'Not specified' : controller.userDateOfBirth.value,
                        ),
                        InfoRow(
                          label: 'Age',
                          value: controller.userAge.value.isEmpty ? 'Not specified' : controller.userAge.value,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            /// FIXED BOTTOM BUTTON
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              child: EditUpdateButton(
                title: 'Edit Profile',
                onPressed: () {
                  Get.to(() => const EditPersonalProfileInfoScreen());
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}

/// ===============================================================
/// PROFILE AVATAR WIDGET
/// ===============================================================
class ProfileAvatar extends StatelessWidget {
  final String imageUrl;
  final String userName;

  const ProfileAvatar({
    super.key,
    required this.imageUrl,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryColor.withOpacity(0.1),
            ),
            child: ClipOval(
              child: _buildAvatarContent(),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            userName.isEmpty ? 'User' : userName,
            style: AppTextStyles.defaultTextStyle.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarContent() {
    // If imageUrl is empty, show person icon
    if (imageUrl.isEmpty) {
      return Center(
        child: Icon(
          Icons.person,
          size: 60,
          color: AppColors.primaryColor,
        ),
      );
    }

    // If it's a network image
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Icon(
              Icons.person,
              size: 60,
              color: AppColors.primaryColor,
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primaryColor,
              ),
            ),
          );
        },
      );
    }

    // If it's a local file path (temp image from gallery/camera)
    if (imageUrl.startsWith('/')) {
      return Image.file(
        File(imageUrl),
        width: 120,
        height: 120,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Icon(
              Icons.person,
              size: 60,
              color: AppColors.primaryColor,
            ),
          );
        },
      );
    }

    // Fallback for any other case - show person icon
    return Center(
      child: Icon(
        Icons.person,
        size: 60,
        color: AppColors.primaryColor,
      ),
    );
  }
}



/// ===============================================================
/// REUSABLE WIDGETS
/// ===============================================================

/// ----------------------------
/// INFO ROW (VIEW MODE)
/// ----------------------------
class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.smallText.copyWith(color: AppColors.black),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.defaultTextStyle.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Divider(height: 24),
      ],
    );
  }
}

/// ----------------------------
/// LABELED TEXT FIELD (EDIT MODE)
/// ----------------------------
class LabeledTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool enabled;
  final TextInputType keyboardType;
  final String? hintText;

  const LabeledTextField({
    super.key,
    required this.label,
    required this.controller,
    this.enabled = true,
    this.keyboardType = TextInputType.text,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.black.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.smallText.copyWith(
              color: AppColors.black.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            enabled: enabled,
            keyboardType: keyboardType,
            style: AppTextStyles.defaultTextStyle.copyWith(
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              hintText: hintText,
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}



