/**
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import '../../../../utils/app_colors.dart';
import '../subscription/subscription_screen.dart';

class AppOpenHomeScreen extends StatelessWidget {
  const AppOpenHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Greeting + Notification Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          image: const DecorationImage(
                            image: AssetImage("assets/images/dummy_user_image.png"),
                            fit: BoxFit.cover,
                          ),
                          color: Colors.grey[300],
                          shape: BoxShape.circle,
                        ),

                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back!',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const Text(
                            'Hi, Rakibul',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SvgPicture.asset(
                    "assets/icons/notification_rounded.svg",
                    fit: BoxFit.fitHeight,
                    height: 40,
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Title Section
              Center(
                child: Column(
                  children: [
                    Text(
                      'Start Your Day',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF5C9FFB),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'What would you like to focus on today?',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Illustration Image (Placeholder)
              Center(
                child: SvgPicture.asset("assets/images/app_open_home_screen_image.svg",
                height: MediaQuery.of(context).size.height * 0.5,
                fit: BoxFit.contain,),
              ),
              const SizedBox(height: 60),

              // Add Task Button
              ElevatedButton(
                onPressed: () {
                  _showSubscriptionModal(context); // 👈 Trigger modal
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5C9FFB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.add, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Add Task',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showSubscriptionModal(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: double.maxFinite,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                child: SvgPicture.asset(
                  "assets/icons/task.svg", // 👈 Use your own SVG or replace with Icon
                  width: 80,
                  height: 80,
                  color: const Color(0xFF5C9FFB),
                ),
              ),

              // Title
               Text(
                'To create tasks',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 12),

              // Body text
              Text(
                'Please subscribe first. Visit our subscription page to continue. Start Free Trial 7 days. Thank you!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 16,
                  color: AppColors.grey,
                ),
              ),
              const SizedBox(height: 32),

              // Yes Button
              ElevatedButton(
                onPressed: () {
                  Get.to(SubscriptionPage());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5C9FFB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Yes',style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',

                ),),
              ),
            ],
          ),
        ),
      );
    },
  );
}*/



import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_texts_style.dart';
import '../subscription/subscription_screen.dart';
import '../../../../screens/personal_information/personal_Infromation_screen_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AppOpenHomeScreen extends StatelessWidget {
  const AppOpenHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PersonalInformationController controller = Get.isRegistered<PersonalInformationController>()
        ? Get.find<PersonalInformationController>()
        : Get.put(PersonalInformationController());

    // Trigger background refresh when screen is shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.backgroundRefresh();
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Obx(() {
          // Show loading state
          if (controller.isLoading.value && controller.userName.value.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryColor,
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row: Greeting + Notification Icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        // Profile Image - Now fetching from controller
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[300],
                          ),
                          child: ClipOval(
                            child: _buildProfileImage(controller),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome!',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            Obx(() => Text(
                              controller.userName.value.isEmpty
                                  ? 'User'
                                  : controller.userName.value,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            )),
                          ],
                        ),
                      ],
                    ),
                    SvgPicture.asset(
                      "assets/icons/notification_rounded.svg",
                      fit: BoxFit.fitHeight,
                      height: 40,
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // Title Section
                Center(
                  child: Column(
                    children: [
                      const Text(
                        'Start Your Day',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5C9FFB),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'What would you like to focus on today?',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Illustration Image
                Center(
                  child: SvgPicture.asset(
                    "assets/images/app_open_home_screen_image.svg",
                    height: MediaQuery.of(context).size.height * 0.5,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 60),

                // Add Task Button
                ElevatedButton(
                  onPressed: () {
                    _showSubscriptionModal(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5C9FFB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.add, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Add Task',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildProfileImage(PersonalInformationController controller) {
    final imageUrl = controller.userProfileImage.value;
    final hasTemp = controller.hasImageChanges.value &&
        controller.tempProfileImageFile.value != null;

    // 1. Local image (after picking from gallery/camera)
    if (hasTemp && controller.tempProfileImageFile.value != null) {
      final file = controller.tempProfileImageFile.value!;
      if (file.existsSync()) {
        return Image.file(
          file,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
        );
      }
    }

    // 2. Cached network image from API
    if (imageUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        width: 48,
        height: 48,
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
          return const Icon(Icons.person, size: 30, color: Colors.grey);
        },
      );
    }

    // 3. Default fallback icon
    return const Icon(Icons.person, size: 30, color: Colors.grey);
  }
}

void _showSubscriptionModal(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: double.maxFinite,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                child: SvgPicture.asset(
                  "assets/icons/task.svg",
                  width: 80,
                  height: 80,
                  color: const Color(0xFF5C9FFB),
                ),
              ),

              // Title
              const Text(
                'To create tasks',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 12),

              // Body text
              const Text(
                'Please subscribe first. Visit our subscription page to continue. Start Free Trial 7 days. Thank you!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 16,
                  color: AppColors.grey,
                ),
              ),
              const SizedBox(height: 32),

              // Yes Button
              ElevatedButton(
                onPressed: () {
                  Get.to(() => const SubscriptionPage());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5C9FFB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Yes',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}