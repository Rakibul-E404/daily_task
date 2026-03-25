import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_texts_style.dart';
import '../views/home/task_details/model/task_model.dart';

Widget subTaskProgress(Task task)
{
  // Calculate progress
  final totalSubtasks = task.totalSubtasks ?? 0;
  final completedSubtasks = task.completedSubtasks ?? 0;
  final progress = totalSubtasks > 0 ? completedSubtasks / totalSubtasks : 0.0;

  return Card(
    color: AppColors.backgroundColor,
    elevation: 1,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtask Progress',
                style: AppTextStyles.defaultTextStyle,
              ),
              Chip(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                label: Text(
                  '$completedSubtasks / $totalSubtasks',
                  style: AppTextStyles.smallText.copyWith(
                      color: AppColors.black,
                    fontWeight: FontWeight.bold
                  ),
                ),
                backgroundColor: AppColors.mainBottomNavColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                side: const BorderSide(width: 0, color: Colors.transparent),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.lightBlueColor,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primaryColor,
                  ),
                  borderRadius: BorderRadius.circular(2),
                  minHeight: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}