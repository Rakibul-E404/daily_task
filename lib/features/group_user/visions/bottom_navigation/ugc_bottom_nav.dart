import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../utils/app_colors.dart';
import '../ugc_add_task/ugc_add_task_screen.dart';
import '../ugc_home/ugc_home_screen.dart';
import '../ugc_profile/ugc_profile_screen.dart';
import '../ugc_task_status/ugc_task_status_screen.dart';

class UgcMainBottomNav extends StatefulWidget {
  const UgcMainBottomNav({super.key});

  @override
  State<UgcMainBottomNav> createState() => _UgcMainBottomNavScreenState();
}

class _UgcMainBottomNavScreenState extends State<UgcMainBottomNav> {
  int _selectedIndex = 0;

  late VoidCallback _onAddTaskCallback;

  late final List<Widget> _screens;

  final List<Map<String, dynamic>> _navItems = [
    {
      'icon': 'assets/icons/home_inactive.svg',
      'activeIcon': 'assets/icons/home_active.svg',
      'label': 'Home',
    },
    {
      'icon': 'assets/icons/add_inactive.svg',
      'activeIcon': 'assets/icons/add_active.svg',
      'label': 'Add',
    },
    {
      'icon': 'assets/icons/status_inactive.svg',
      'activeIcon': 'assets/icons/status_active.svg',
      'label': 'Status',
    },
    {
      'icon': 'assets/icons/profile_inactive.svg',
      'activeIcon': 'assets/icons/profile_active.svg',
      'label': 'Profile',
    },
  ];

  @override
  void initState() {
    super.initState();

    // Callback to switch to Add tab
    _onAddTaskCallback = () => switchTab(1);

    // Initialize screens once (important for IndexedStack)
    _screens = [
      UgcHomeScreen(onAddTaskPressed: _onAddTaskCallback),
      const UgcAddTaskScreen(),
      const UgcTaskStatusScreen(),
      const UgcProfileScreen(),
    ];
  }

  void switchTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,

      // ✅ IndexedStack keeps all screens alive
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
        child: Container(
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
                      color: isSelected
                          ? AppColors.primaryColor
                          : Colors.transparent,
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
                            color: isSelected
                                ? AppColors.white
                                : Colors.grey,
                            fontFamily: 'Plus Jakarta Sans',
                          ),
                        ),
                        const SizedBox(height: 8),
                        SvgPicture.asset(
                          isSelected
                              ? item['activeIcon']
                              : item['icon'],
                          width: 30,
                          height: 30,
                          colorFilter: ColorFilter.mode(
                            isSelected
                                ? AppColors.white
                                : Colors.grey,
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
        ),
      ),
    );
  }
}
