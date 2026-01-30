/**
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../utils/app_colors.dart';
import '../add_task/add_screen.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../status/ststus_screen.dart';

class MainBottomNav extends StatefulWidget {
  const MainBottomNav({super.key});

  @override
  State<MainBottomNav> createState() => _MainBottomNavState();
}

class _MainBottomNavState extends State<MainBottomNav> {
  int _selectedIndex = 0;

  // Screens list
  final List<Widget> _screens = [
    const HomeScreen(),
    const AddTaskScreen(),
    const StatusScreen(),
    const ProfileScreen(),
  ];

  // Custom navigation items data
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: _screens[_selectedIndex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(14,8,14,8),
        child: Container(
          height: 90.0,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.mainBottomNavColor,
            borderRadius: BorderRadius.circular(12)
          ),
          child: Row(
            children: List.generate(_navItems.length, (index) {
              final item = _navItems[index];
              final isSelected = _selectedIndex == index;
              final isIcon = item['isIcon'] == true;

              return Expanded(
                child: GestureDetector(
                  onTap: () => _onItemTapped(index),
                  child: Container(
                    height: MediaQuery.of(context).size.height*0.5,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Label
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

                        // Icon/Image
                        if (isIcon)
                          Icon(
                            isSelected ? item['activeIcon'] : item['icon'],
                            size: 28,
                            color: isSelected ? AppColors.white : Colors.grey,
                          )
                        else
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
        ),
      ),
    );
  }
}*/




import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../utils/app_colors.dart';
import '../add_task/add_screen.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../status/ststus_screen.dart';

class MainBottomNav extends StatefulWidget {
  const MainBottomNav({super.key});

  @override
  State<MainBottomNav> createState() => _MainBottomNavState();
}

class _MainBottomNavState extends State<MainBottomNav> {
  int _selectedIndex = 0;
  late PageController _pageController;

  // Custom navigation items data
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
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const BouncingScrollPhysics(), // Optional: adds bounce effect
        children: const [
          HomeScreen(),
          AddTaskScreen(),
          StatusScreen(),
          ProfileScreen(),
        ],
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
              final isIcon = item['isIcon'] == true;

              return Expanded(
                child: GestureDetector(
                  onTap: () => _onItemTapped(index),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.5,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color:
                      isSelected ? AppColors.primaryColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Label
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

                        // Icon/Image
                        if (isIcon)
                          Icon(
                            isSelected ? item['activeIcon'] : item['icon'],
                            size: 28,
                            color: isSelected ? AppColors.white : Colors.grey,
                          )
                        else
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
        ),
      ),
    );
  }
}