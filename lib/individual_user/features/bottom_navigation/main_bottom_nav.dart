// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import '../add/add_screen.dart';
// import '../home/home_screen.dart';
// import '../profile/profile_screen.dart';
// import '../status/ststus_screen.dart';
// // import '../status/status_screen.dart';
//
// class MainBottomNav extends StatefulWidget {
//   const MainBottomNav({super.key});
//
//   @override
//   State<MainBottomNav> createState() => _MainBottomNavState();
// }
//
// class _MainBottomNavState extends State<MainBottomNav> {
//   int _selectedIndex = 0;
//
//   // Screens list
//   final List<Widget> _screens = [
//     const HomeScreen(),
//     const AddScreen(),
//     const StatusScreen(),
//     const ProfileScreen(),
//   ];
//
//   // Simple bottom navigation using Material icons
//   final List<BottomNavigationBarItem> _bottomNavItems = [
//     BottomNavigationBarItem(
//       icon: SizedBox(
//         width: 24,
//         height: 24,
//         child: SvgPicture.asset("assets/icons/home_inactive.svg"),
//       ),
//
//       activeIcon: SizedBox(
//         child: SvgPicture.asset(
//           "assets/icons/home_active.svg",
//           width: 24,
//           height: 24,
//         ),
//       ),
//       label: 'Home',
//     ),
//
//     const BottomNavigationBarItem(
//       icon: Icon(Icons.add_box_outlined),
//       activeIcon: Icon(Icons.add_box_outlined),
//       label: 'Add',
//     ),
//     const BottomNavigationBarItem(
//       icon: Icon(CupertinoIcons.chart_pie),
//       activeIcon: Icon(Icons.pie_chart_outline),
//       label: 'Status',
//     ),
//     const BottomNavigationBarItem(
//       icon: Icon(Icons.person_outlined),
//       activeIcon: Icon(Icons.person_outlined),
//       label: 'Profile',
//     ),
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
//       body: _screens[_selectedIndex],
//       bottomNavigationBar: BottomNavigationBar(
//         items: _bottomNavItems,
//         currentIndex: _selectedIndex,
//         selectedItemColor: Colors.blue,
//         unselectedItemColor: Colors.grey,
//         showSelectedLabels: true,
//         showUnselectedLabels: true,
//         type: BottomNavigationBarType.fixed,
//         onTap: _onItemTapped,
//       ),
//     );
//   }
// }


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../add/add_screen.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../status/ststus_screen.dart';
// import '../status/status_screen.dart';

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
    const AddScreen(),
    const StatusScreen(),
    const ProfileScreen(),
  ];

  // Simple bottom navigation using Material icons
  final List<BottomNavigationBarItem> _bottomNavItems = [
    BottomNavigationBarItem(
      icon: SvgPicture.asset(
        "assets/icons/home_inactive.svg",
        width: 24,
        height: 24,
      ),
      activeIcon: SvgPicture.asset(
        "assets/icons/home_active.svg",
        width: 24,
        height: 24,
      ),
      label: 'Home',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.add_box_outlined),
      activeIcon: Icon(Icons.add_box_outlined),
      label: 'Add',
    ),
    const BottomNavigationBarItem(
      icon: Icon(CupertinoIcons.chart_pie),
      activeIcon: Icon(Icons.pie_chart_outline),
      label: 'Status',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.person_outlined),
      activeIcon: Icon(Icons.person_outlined),
      label: 'Profile',
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: _bottomNavItems,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
    );
  }
}