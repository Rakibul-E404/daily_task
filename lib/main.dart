import 'package:askfemi/auth/password/set_new_password_screen.dart';
import 'package:askfemi/auth/sign_in/singn_in_screen.dart';
import 'package:askfemi/individual_user/features/bottom_navigation/main_bottom_nav.dart';
import 'package:askfemi/individual_user/features/choose_support_mode/choose_support_mode_screen.dart';
import 'package:askfemi/individual_user/features/notification/notification_screen.dart';
import 'package:askfemi/individual_user/features/subscription/subscription_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'individual_user/features/splash/splash_screen.dart';

void main() {
  runApp(const TaskManagement());
}

class TaskManagement extends StatelessWidget {
  const TaskManagement({super.key});

  // This model is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Task Management',
      // home:  const  SplashScreen(),
      home:    MainBottomNav(),
      debugShowCheckedModeBanner: false,
    );
  }
}

