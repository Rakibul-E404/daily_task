
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
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
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
    return Column(
      children: [
        Container(
          width: 130,
          height: 130,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: ClipOval(
            child: imageUrl.startsWith('http')
                ? Image.network(
              imageUrl,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            )
                : null,
            // Image.asset(
            //   imageUrl,
            //   width: 100,
            //   height: 100,
            //   fit: BoxFit.cover,
            //   errorBuilder: (context, error, stackTrace) {
            //     return const Icon(
            //       Icons.person,
            //       size: 50,
            //       color: Colors.grey,
            //     );
            //   },
            // ),
          ),
        ),
      ],
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

  const LabeledTextField({
    super.key,
    required this.label,
    required this.controller,
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
            style: AppTextStyles.defaultTextStyle.copyWith(
              fontWeight: FontWeight.w600,
            ),
            decoration: const InputDecoration(
              isDense: true,
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }
}


























