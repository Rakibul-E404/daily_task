import 'package:askfemi/utils/app_colors.dart';
import 'package:askfemi/utils/app_texts_style.dart';
import 'package:flutter/material.dart';
import 'features/group_user/visions/bottom_navigation/ugc_bottom_nav.dart';
import 'features/individual_user/views/home/app_open_home_screen.dart';

class UserTypeSelection extends StatelessWidget {
  const UserTypeSelection({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            toolbarHeight: 70,
            surfaceTintColor: AppColors.transparent,
            backgroundColor: AppColors.backgroundColor,
            pinned: true,
            floating: false,
            expandedHeight: 100,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 10),
              expandedTitleScale: 1.0,
              title: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Select User Type',
                        style: AppTextStyles.largeHeading.copyWith(
                          fontSize: 30,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Choose how you want to use the app',
                        style: AppTextStyles.smallText.copyWith(fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Simple Info Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 30),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primaryColor),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.crisis_alert_sharp,
                          color: Colors.red,
                          size: 32,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Select your user type to continue',
                          style: AppTextStyles.smallHeading.copyWith(
                            color: AppColors.primaryColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'This screen will be removed after API development',
                          style: AppTextStyles.defaultTextStyle.copyWith(
                            fontSize: 20,
                            color: Colors.redAccent,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  // Individual Button
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 20),
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to Individual User Screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AppOpenHomeScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 24,
                          horizontal: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.person,
                            size: 48,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Individual',
                            style: AppTextStyles.largeHeading.copyWith(
                              fontSize: 24,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'For personal use',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Group Button
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 30),
                    child: ElevatedButton(
                      onPressed: () {
                       /// todo::
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const UgcMainBottomNav(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 24,
                          horizontal: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.group,
                            size: 48,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Group',
                            style: AppTextStyles.largeHeading.copyWith(
                              fontSize: 24,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'For teams & collaboration',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

