import 'package:askfemi/individual_user/features/bottom_navigation/main_bottom_nav.dart';
import 'package:askfemi/user_type.dart';
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
      home:  const  SplashScreen(),
      // home:    UserTypeSelection(),
      debugShowCheckedModeBanner: false,
    );
  }
}

