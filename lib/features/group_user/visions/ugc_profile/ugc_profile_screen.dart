import 'dart:io';
import 'package:askfemi/auth/sign_in/singn_in_screen.dart';
import 'package:askfemi/features/individual_user/views/notification/notification_style_screen.dart';
import 'package:askfemi/features/individual_user/views/subscription/subscription_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../../screens/personal_information/personal_Infromation_screen_controller.dart';
import '../../../../screens/personal_information/personal_profile_info_screen.dart';
import '../../../../screens/settings/settings_screen.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_texts_style.dart';
import '../../../../utils/network/app_url.dart';
import '../../../../utils/network/secure_storage_service.dart';
import '../../../../utils/temp/cache.dart';
import '../../../individual_user/views/choose_support_mode/choose_support_mode_screen.dart';

class UgcProfileScreen extends StatelessWidget {
  const UgcProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PersonalInformationController controller = Get.isRegistered<PersonalInformationController>()
        ? Get.find<PersonalInformationController>()
        : Get.put(PersonalInformationController());

    // Trigger background refresh when screen is shown (no indicator)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.backgroundRefresh();
    });

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Obx(() {
          // Show loading only on first load with no data
          if (controller.isLoading.value && controller.userName.value.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Profile Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.lightGrey),
                          color: AppColors.backgroundColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 0,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // ✅ FIXED: Profile Image with proper cached image support + URL trimming
                            Stack(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey.shade200,
                                  ),
                                  child: ClipOval(
                                    child: _buildProfileImage(controller),
                                  ),
                                ),
                                if (controller.isAccountSecondary.value)
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.amber,
                                      ),
                                      child: SvgPicture.asset(
                                        "assets/images/task_manager_permission.svg",
                                        fit: BoxFit.scaleDown,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  controller.userName.value.isEmpty ? 'User' : controller.userName.value,
                                  style: AppTextStyles.largeHeading,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  controller.userEmail.value.isEmpty ? 'Not specified' : controller.userEmail.value,
                                  style: AppTextStyles.smallText.copyWith(
                                    color: AppColors.black,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                if (controller.isAccountSecondary.value)
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      color: AppColors.batchColor,
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: Text(
                                      'Task Manager',
                                      style: AppTextStyles.smallText.copyWith(
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Preferred Time Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.lightGrey),
                          color: AppColors.backgroundColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.access_time,
                                    color: AppColors.backgroundColor,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Preferred time',
                                      style: AppTextStyles.smallHeading,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'When you usually work on tasks',
                                      style: AppTextStyles.smallText,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.backgroundColor,
                                border: Border.all(color: AppColors.grey, width: 1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: const [
                                  Text(
                                    '07 : 00 AM',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF1A1A1A),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Icon(
                                    Icons.access_time_outlined,
                                    color: Color(0xFF999999),
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Menu Items Card
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.lightGrey),
                          color: AppColors.backgroundColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildMenuItem(
                              icon: CupertinoIcons.person_crop_circle,
                              iconColor: AppColors.iconColor,
                              title: 'Personal information',
                              onTap: () async {
                                await Get.to(() => const PersonalInformationScreen());
                                await controller.refreshData(); // Manual refresh with indicator
                              },
                            ),
                            _buildDivider(),
                            _buildMenuItem(
                              icon: Icons.lightbulb_outline,
                              iconColor: AppColors.iconColor,
                              title: 'Support Mode',
                              onTap: () {
                                Get.to(() => const ChooseSupportModeScreen(fromProfile: true));
                              },
                            ),
                            _buildDivider(),
                            _buildMenuItem(
                              icon: Icons.notifications_outlined,
                              iconColor: AppColors.iconColor,
                              title: 'Notification Style',
                              onTap: () {
                                Get.to(() => const NotificationStyleScreen());
                              },
                            ),
                            _buildDivider(),
                            _buildMenuItem(
                              icon: Icons.settings_outlined,
                              iconColor: AppColors.iconColor,
                              title: 'Settings',
                              onTap: () {
                                Get.to(() => const SettingsScreen());
                              },
                            ),
                            _buildDivider(),
                            _buildMenuItem(
                              icon: Icons.logout,
                              iconColor: AppColors.iconColor,
                              title: 'Logout',
                              onTap: () {
                                _showLogoutDialog(context, controller);
                              },
                              isLast: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildProfileImage(PersonalInformationController controller) {
    final imageUrl = controller.userProfileImage.value;

    final hasTemp = controller.hasImageChanges.value &&
        controller.tempProfileImageFile.value != null;

    // ✅ 1. Local image (after picking)
    if (hasTemp && controller.tempProfileImageFile.value != null) {
      final file = controller.tempProfileImageFile.value!;
      if (file.existsSync()) {
        return Image.file(
          file,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
        );
      }
    }

    // ✅ 2. Cached network image
    if (imageUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        cacheKey: imageUrl,

        placeholder: (context, url) => const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),

        errorWidget: (context, url, error) {
          print('❌ Image error: $error');
          print('❌ URL: $url');
          return const Icon(Icons.person, size: 40, color: Colors.grey);
        },
      );
    }

    // ✅ 3. Default fallback
    return const Icon(Icons.person, size: 40, color: Colors.grey);
  }



  void _showLogoutDialog(BuildContext context, PersonalInformationController controller) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Logout"),
          content: const Text("Are you sure you want to logout?"),
          backgroundColor: AppColors.backgroundColor,
          icon: const Icon(Icons.logout_outlined, color: Colors.red),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Get.back();
              },
              child: Text(
                "Cancel",
                style: AppTextStyles.defaultTextStyle.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.liteRedColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                await SecureStorageService.instance.clearAll();
                await CacheService.clearCache();
                Get.offAll(() => SignInScreen());
              },
              child: Text(
                "Logout",
                style: AppTextStyles.defaultTextStyle.copyWith(
                  color: AppColors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    bool hasTag = false,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: subtitle != null ? 16 : 18,
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                      ),
                      if (hasTag) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xFF4CAF50),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'active',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF999999),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Icon(
              Icons.arrow_forward,
              color: Color(0xFFCCCCCC),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.only(left: 60),
      height: 1,
      color: AppColors.grey.withValues(alpha: 0.3),
    );
  }
}