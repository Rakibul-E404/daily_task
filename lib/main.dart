import 'package:askfemi/auth/forgot_password/forgot_password_screen.dart';
import 'package:askfemi/features/group_user/visions/bottom_navigation/ugc_bottom_nav.dart';
import 'package:askfemi/features/group_user/visions/ugc_task_status/ugc_task_status_screen.dart';
import 'package:askfemi/screens/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_storage/get_storage.dart';


void main() async {
  await GetStorage.init();
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
      // home: ForgotPasswordScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

