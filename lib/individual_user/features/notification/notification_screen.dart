import 'package:askfemi/utils/app_colors.dart';
import 'package:askfemi/utils/app_texts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text("Notification",style: AppTextStyles.smallHeading,),
        leading: IconButton(onPressed: () {
          Get.back();
        }, icon: Icon(Icons.arrow_back)),
        backgroundColor: AppColors.backgroundColor,
      ),
      body: Center(
        child: Container(
          child: SvgPicture.asset(
              "assets/images/empty_notificaiton_screen_iconWithText.svg"),
        ),
      ),
    );
  }
}
