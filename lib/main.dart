import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'features/splash/splash_screen.dart';

void main() {
  runApp(const TaskManagement());
}

class TaskManagement extends StatelessWidget {
  const TaskManagement({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Task Management',
      home:  const  SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

