// // screens/get_started/get_started_controller.dart
// import 'package:askfemi/screens/splash/splash_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get_core/src/get_main.dart';
// import 'package:get/get_navigation/src/extension_navigation.dart'; // Import your next screen
//
// class GetStartedController {
//   final BuildContext context;
//
//   GetStartedController(this.context);
//
//   // Handle Continue button tap
//   Future<void> onContinuePressed() async {
//     Navigator.pushReplacement(
//       context,
//       await Get.to(()=>SplashScreen())
//     );
//   }
//
//   // Optional: Handle skip or other actions
//   void onSkipPressed() {
//     // Navigate directly to home or login
//   }
//
//   // Optional: Track if user has seen get started screen
//   void markAsSeen() {
//     // You can use SharedPreferences or any state management
//     // SharedPreferences prefs = await SharedPreferences.getInstance();
//     // prefs.setBool('hasSeenGetStarted', true);
//   }
// }