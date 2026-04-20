import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../../auth/sign_in/singn_in_screen.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/logout_controller.dart';
import '../subscription/subscription_screen.dart';
import '../../../../screens/personal_information/personal_Infromation_screen_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../utils/app_texts_style.dart';
import 'package:flutter/cupertino.dart';
import '../../../../utils/temp/cache.dart';
import '../../../../utils/network/secure_storage_service.dart';
import '../../../../screens/settings/settings_screen.dart';
import '../choose_support_mode/choose_support_mode_screen.dart';
import '../../../../screens/notification/notification_style_screen.dart';
import '../../../../screens/personal_information/personal_profile_info_screen.dart';

class AppOpenHomeScreen extends StatefulWidget {
  const AppOpenHomeScreen({super.key});

  @override
  State<AppOpenHomeScreen> createState() => _AppOpenHomeScreenState();
}

class _AppOpenHomeScreenState extends State<AppOpenHomeScreen> {
  int _selectedIndex = 0;

  /// Custom navigation items data
  final List<Map<String, dynamic>> _navItems = [
    {
      'icon': 'assets/icons/home_inactive.svg',
      'activeIcon': 'assets/icons/home_active.svg',
      'label': 'Home',
      'index': 0,
    },
    {
      'icon': 'assets/icons/add_inactive.svg',
      'activeIcon': 'assets/icons/add_active.svg',
      'label': 'Add',
      'index': 1,
    },
    {
      'icon': 'assets/icons/history.svg',
      'activeIcon': 'assets/icons/history.svg',
      'label': 'History',
      'index': 2,
    },
    {
      'icon': 'assets/icons/profile_inactive.svg',
      'activeIcon': 'assets/icons/profile_active.svg',
      'label': 'Profile',
      'index': 3,
    },
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Show subscription modal for all tabs except Profile
    if (index != 3) {
      _showSubscriptionModal(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final PersonalInformationController controller = Get.isRegistered<PersonalInformationController>()
        ? Get.find<PersonalInformationController>()
        : Get.put(PersonalInformationController());

    // Trigger background refresh when screen is shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.backgroundRefresh();
      controller.fetchPreferredTime();
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

          return Column(
            children: [
              // Main Content Area
              Expanded(
                child: _selectedIndex == 3
                    ? _buildProfileContent(controller)
                    : _buildMainContent(controller),
              ),
              // Bottom Navigation Bar (always visible)
              _buildBottomNavigationBar(),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildMainContent(PersonalInformationController controller) {
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
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[300],
                    ),
                    child: ClipOval(
                      child: _buildSmallProfileImage(controller),
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

          // Content based on selected index (Home, Add, History)
          Expanded(
            child: _buildContentForIndex(_selectedIndex),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(PersonalInformationController controller) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Profile Card (User Image, Name, Email) - Same as ProfileScreen
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
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
                // Profile Image
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
                // Name and Email from API
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() => Text(
                      controller.userName.value.isEmpty
                          ? 'User'
                          : controller.userName.value,
                      style: AppTextStyles.largeHeading,
                    )),
                    const SizedBox(height: 4),
                    Obx(() => Text(
                      controller.userEmail.value.isEmpty
                          ? 'Not specified'
                          : controller.userEmail.value,
                      style: AppTextStyles.smallText.copyWith(
                        color: AppColors.black,
                      ),
                    )),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Menu Items Card (from subscription card to bottom)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
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
                // Subscription Card
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.grey,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.backgroundColor,
                    ),
                    child: _buildSubscriptionCard(),
                  ),
                ),
                _buildDivider(),
                // Personal Information - Navigate to PersonalInformationScreen
                _buildMenuItem(
                  icon: CupertinoIcons.person_crop_circle,
                  iconColor: AppColors.iconColor,
                  title: 'Personal information',
                  onTap: () {
                    Get.to(() => const PersonalInformationScreen());
                  },
                ),
                _buildDivider(),
                // Support Mode - Navigate to ChooseSupportModeScreen
                _buildMenuItem(
                  icon: Icons.lightbulb_outline,
                  iconColor: AppColors.iconColor,
                  title: 'Support Mode',
                  onTap: () {
                    Get.to(() => const ChooseSupportModeScreen(fromProfile: true));
                  },
                ),
                _buildDivider(),
                // Notification Style - Navigate to NotificationStyleScreen
                _buildMenuItem(
                  icon: Icons.notifications_outlined,
                  iconColor: AppColors.iconColor,
                  title: 'Notification Style',
                  onTap: () {
                    Get.to(() => const NotificationStyleScreen());
                  },
                ),
                _buildDivider(),
                // Setting - Navigate to SettingsScreen
                _buildMenuItem(
                  icon: Icons.settings_outlined,
                  iconColor: AppColors.iconColor,
                  title: 'Settings',
                  onTap: () {
                    Get.to(() => const SettingsScreen());
                  },
                ),
                _buildDivider(),
                // Logout
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
    );
  }

  Widget _buildSubscriptionCard() {
    return InkWell(
      onTap: () {
        Get.to(() => const SubscriptionPage());
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.lightGrey, width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Diamond Icon
            const Icon(
              Icons.diamond_outlined,
              color: Color(0xFFFFB74D),
              size: 30,
            ),
            const SizedBox(width: 12),
            // Title & Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Subscription Package Individual',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Renewal date: 10/06/25',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF8E8E8E),
                        ),
                      ),
                      // Active Tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.green,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Active',
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
          ],
        ),
      ),
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
                            color: const Color(0xFF4CAF50),
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
              color: AppColors.iconColor,
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

  void _showLogoutDialog(BuildContext context, PersonalInformationController controller) {
    final logoutController = Get.isRegistered<LogoutController>()
        ? Get.find<LogoutController>()
        : Get.put(LogoutController());

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Obx(() => AlertDialog(
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
              onPressed: logoutController.isLoading.value ? null : () {
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
              onPressed: logoutController.isLoading.value ? null : () async {
                // Close the dialog first
                Get.back();
                // ✅ FIXED: Actually call the logout method
                await logoutController.logout();
              },
              child: logoutController.isLoading.value
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : Text(
                "Logout",
                style: AppTextStyles.defaultTextStyle.copyWith(
                  color: AppColors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ));
      },
    );
  }

  Widget _buildContentForIndex(int index) {
    switch (index) {
      case 0:
        return _buildHomeContent();
      case 1:
        return _buildAddTaskContent();
      case 2:
        return _buildHistoryContent();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
          const SizedBox(height: 30),
          SvgPicture.asset(
            "assets/images/app_open_home_screen_image.svg",
            height: MediaQuery.of(context).size.height * 0.35,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              _showSubscriptionModal(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5C9FFB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
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
  }

  Widget _buildAddTaskContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            "assets/icons/task.svg",
            width: 80,
            height: 80,
            color: const Color(0xFF5C9FFB),
          ),
          const SizedBox(height: 24),
          const Text(
            'Create New Task',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5C9FFB),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Subscribe to start creating tasks',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              _showSubscriptionModal(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5C9FFB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Subscribe Now'),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            "assets/icons/history.svg",
            width: 80,
            height: 80,
            color: const Color(0xFF5C9FFB),
          ),
          const SizedBox(height: 24),
          const Text(
            'Task History',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5C9FFB),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Subscribe to view your task history',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              _showSubscriptionModal(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5C9FFB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Subscribe Now'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 90.0,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.mainBottomNavColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: List.generate(_navItems.length, (index) {
          final item = _navItems[index];
          final isSelected = _selectedIndex == index;

          return Expanded(
            child: GestureDetector(
              onTap: () => _onItemTapped(index),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item['label'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? AppColors.white : Colors.grey,
                        fontFamily: 'Plus Jakarta Sans',
                      ),
                    ),
                    const SizedBox(height: 8),
                    SvgPicture.asset(
                      isSelected ? item['activeIcon'] : item['icon'],
                      width: 30,
                      height: 30,
                      colorFilter: ColorFilter.mode(
                        isSelected ? AppColors.white : Colors.grey,
                        BlendMode.srcIn,
                      ),
                    ),
                  ],
                ),
              ),
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
          return const Icon(Icons.person, size: 40, color: Colors.grey);
        },
      );
    }

    return const Icon(Icons.person, size: 40, color: Colors.grey);
  }

  Widget _buildSmallProfileImage(PersonalInformationController controller) {
    final imageUrl = controller.userProfileImage.value;
    final hasTemp = controller.hasImageChanges.value &&
        controller.tempProfileImageFile.value != null;

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
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                child: SvgPicture.asset(
                  "assets/icons/task.svg",
                  width: 80,
                  height: 80,
                  color: const Color(0xFF5C9FFB),
                ),
              ),
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
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
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