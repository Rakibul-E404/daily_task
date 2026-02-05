import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_texts_style.dart';

class EditUpdateButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;

  const EditUpdateButton({
    super.key,
    required this.title,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          title,
          style: AppTextStyles.defaultTextStyle.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
}