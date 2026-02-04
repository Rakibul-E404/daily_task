import 'package:askfemi/features/settings/change_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

import 'features/individual_user/views/bottom_navigation/main_bottom_nav.dart';
import 'features/individual_user/views/splash/splash_screen.dart';


void main() async {
  runApp(const TaskManagement());

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
}


class TaskManagement extends StatelessWidget {
  const TaskManagement({super.key});

  // This model is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Task Management',
      home:  const  SplashScreen(),
      // home: MainBottomNav(),
      debugShowCheckedModeBanner: false,
    );
  }
}

