// /**
//     import 'package:flutter/material.dart';
//     import 'package:flutter_svg/flutter_svg.dart';
//     import '../../../../utils/app_colors.dart';
//     import '../ugc_home/ugc_home_screen.dart';
//
//     class UgcMainBottomNav extends StatefulWidget {
//     const UgcMainBottomNav({super.key});
//
//     @override
//     State<UgcMainBottomNav> createState() => _UgcMainBottomNavScreenState();
//     }
//
//     class _UgcMainBottomNavScreenState extends State<UgcMainBottomNav> {
//     int _selectedIndex = 0;
//
//     // Screens list with dummy screens
//     final List<Widget> _screens = const [
//     UgcHomeScreen(),
//     UgcAddTaskScreen(),
//     UgcHistoryScreen(),
//     UgcProfileScreen(),
//     ];
//
//     // Custom navigation items data
//     final List<Map<String, dynamic>> _navItems = [
//     {
//     'icon': 'assets/icons/home_inactive.svg',
//     'activeIcon': 'assets/icons/home_active.svg',
//     'label': 'Home',
//     },
//     {
//     'icon': 'assets/icons/add_inactive.svg',
//     'activeIcon': 'assets/icons/add_active.svg',
//     'label': 'Add',
//     },
//     {
//     'icon': 'assets/icons/status_inactive.svg',
//     'activeIcon': 'assets/icons/status_active.svg',
//     'label': 'Status',
//     },
//     {
//     'icon': 'assets/icons/profile_inactive.svg',
//     'activeIcon': 'assets/icons/profile_active.svg',
//     'label': 'Profile',
//     },
//     ];
//
//     void _onItemTapped(int index) {
//     setState(() {
//     _selectedIndex = index;
//     });
//     }
//
//     @override
//     Widget build(BuildContext context) {
//     return Scaffold(
//     backgroundColor: AppColors.backgroundColor,
//     body: IndexedStack(
//     index: _selectedIndex,
//     children: _screens,
//     ),
//     bottomNavigationBar: Padding(
//     padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
//     child: Container(
//     height: 90.0,
//     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
//     decoration: BoxDecoration(
//     color: AppColors.mainBottomNavColor,
//     borderRadius: BorderRadius.circular(12),
//     ),
//     child: Row(
//     children: List.generate(_navItems.length, (index) {
//     final item = _navItems[index];
//     final isSelected = _selectedIndex == index;
//
//     return Expanded(
//     child: GestureDetector(
//     onTap: () => _onItemTapped(index),
//     child: Container(
//     margin: const EdgeInsets.symmetric(horizontal: 2),
//     decoration: BoxDecoration(
//     color: isSelected ? AppColors.primaryColor : Colors.transparent,
//     borderRadius: BorderRadius.circular(6),
//     ),
//     child: Column(
//     mainAxisAlignment: MainAxisAlignment.center,
//     children: [
//     Text(
//     item['label'],
//     style: TextStyle(
//     fontSize: 16,
//     fontWeight: FontWeight.w500,
//     color: isSelected ? AppColors.white : Colors.grey,
//     fontFamily: 'Plus Jakarta Sans',
//     ),
//     ),
//     const SizedBox(height: 8),
//     SvgPicture.asset(
//     isSelected ? item['activeIcon'] : item['icon'],
//     width: 30,
//     height: 30,
//     colorFilter: ColorFilter.mode(
//     isSelected ? AppColors.white : Colors.grey,
//     BlendMode.srcIn,
//     ),
//     ),
//     ],
//     ),
//     ),
//     ),
//     );
//     }),
//     ),
//     ),
//     ),
//     );
//     }
//     }
//
//     /// Dummy Screens below
//
//
//     class UgcAddTaskScreen extends StatelessWidget {
//     const UgcAddTaskScreen({super.key});
//
//     @override
//     Widget build(BuildContext context) {
//     return Scaffold(
//     backgroundColor: AppColors.backgroundColor,
//     body: const Center(
//     child: Text(
//     'Add Task Screen',
//     style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//     ),
//     ),
//     );
//     }
//     }
//
//     class UgcHistoryScreen extends StatelessWidget {
//     const UgcHistoryScreen({super.key});
//
//     @override
//     Widget build(BuildContext context) {
//     return Scaffold(
//     backgroundColor: AppColors.backgroundColor,
//     body: const Center(
//     child: Text(
//     'History Screen',
//     style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//     ),
//     ),
//     );
//     }
//     }
//
//     class UgcProfileScreen extends StatelessWidget {
//     const UgcProfileScreen({super.key});
//
//     @override
//     Widget build(BuildContext context) {
//     return Scaffold(
//     backgroundColor: AppColors.backgroundColor,
//     body: const Center(
//     child: Text(
//     'Profile Screen',
//     style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//     ),
//     ),
//     );
//     }
//     }
//  */
//
// import 'package:askfemi/auth/sign_in/singn_in_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:get/get_core/src/get_main.dart';
// import 'package:get/get_navigation/src/extension_navigation.dart';
// import '../../../../utils/app_colors.dart';
// import '../ugc_add_task/ugc_add_task_screen.dart';
// import '../ugc_home/ugc_home_screen.dart';
// import '../ugc_profile/ugc_profile_screen.dart';
// import '../ugc_task_status/ugc_task_status_screen.dart';
//
// class UgcMainBottomNav extends StatefulWidget {
//   const UgcMainBottomNav({super.key});
//
//   @override
//   State<UgcMainBottomNav> createState() => _UgcMainBottomNavScreenState();
// }
//
// class _UgcMainBottomNavScreenState extends State<UgcMainBottomNav> {
//   int _selectedIndex = 0;
//
//   /// This function can be passed to child screens to programmatically switch tabs
//   void switchTab(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }
//
//   // Screens list with dummy screens
//   late final List<Widget> _screens = [
//     UgcHomeScreen(onAddTaskPressed: () => switchTab(1)), // Pass callback
//     const UgcAddTaskScreen(),
//     const UgcTaskStatusScreen(),
//     const UgcProfileScreen(),
//   ];
//
//   // Custom navigation items data
//   final List<Map<String, dynamic>> _navItems = [
//     {
//       'icon': 'assets/icons/home_inactive.svg',
//       'activeIcon': 'assets/icons/home_active.svg',
//       'label': 'Home',
//     },
//     {
//       'icon': 'assets/icons/add_inactive.svg',
//       'activeIcon': 'assets/icons/add_active.svg',
//       'label': 'Add',
//     },
//     {
//       'icon': 'assets/icons/status_inactive.svg',
//       'activeIcon': 'assets/icons/status_active.svg',
//       'label': 'Status',
//     },
//     {
//       'icon': 'assets/icons/profile_inactive.svg',
//       'activeIcon': 'assets/icons/profile_active.svg',
//       'label': 'Profile',
//     },
//   ];
//
//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundColor,
//       body: IndexedStack(index: _selectedIndex, children: _screens),
//       bottomNavigationBar: Padding(
//         padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
//         child: Container(
//           height: 90.0,
//           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
//           decoration: BoxDecoration(
//             color: AppColors.mainBottomNavColor,
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Row(
//             children: List.generate(_navItems.length, (index) {
//               final item = _navItems[index];
//               final isSelected = _selectedIndex == index;
//
//               return Expanded(
//                 child: GestureDetector(
//                   onTap: () => _onItemTapped(index),
//                   child: Container(
//                     margin: const EdgeInsets.symmetric(horizontal: 2),
//                     decoration: BoxDecoration(
//                       color: isSelected
//                           ? AppColors.primaryColor
//                           : Colors.transparent,
//                       borderRadius: BorderRadius.circular(6),
//                     ),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           item['label'],
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w500,
//                             color: isSelected ? AppColors.white : Colors.grey,
//                             fontFamily: 'Plus Jakarta Sans',
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         SvgPicture.asset(
//                           isSelected ? item['activeIcon'] : item['icon'],
//                           width: 30,
//                           height: 30,
//                           colorFilter: ColorFilter.mode(
//                             isSelected ? AppColors.white : Colors.grey,
//                             BlendMode.srcIn,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             }),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
//
//
//
//
//

///
///
/// todo:: trying to increase speed
///
///
///


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

  // Declare callback variable
  late VoidCallback _onAddTaskCallback;

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
    // Initialize callback in initState
    _onAddTaskCallback = () => switchTab(1);
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

  Widget _buildCurrentScreen() {
    switch (_selectedIndex) {
      case 0:
        return UgcHomeScreen(onAddTaskPressed: _onAddTaskCallback);
      case 1:
        return const UgcAddTaskScreen();
      case 2:
        return const UgcTaskStatusScreen();
      case 3:
        return const UgcProfileScreen();
      default:
        return UgcHomeScreen(onAddTaskPressed: _onAddTaskCallback);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: _buildCurrentScreen(),
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
        ),
      ),
    );
  }
}