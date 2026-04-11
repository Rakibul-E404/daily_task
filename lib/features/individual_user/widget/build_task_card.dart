import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/app_colors.dart';
import '../views/home/task_details/model/task_model.dart';
import '../views/home/task_details/task_details_screen.dart';
import 'dotted_line_widget.dart';

Widget buildTaskCard({
  required BuildContext context,
  required Task task,
  TextStyle? titleTextStyle,
  TextStyle? timeTextStyle,
  TextStyle? subtaskTextStyle,
  TextStyle? percentageTextStyle,
  TextStyle? statusTextStyle,
  TextStyle? selfTaskTextStyle,
  TextStyle? startButtonTextStyle,
}) {
  final screenWidth = MediaQuery.of(context).size.width;
  final progressBarWidth = screenWidth * 0.075; // 30px equivalent

  // Status color
  Color getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return AppColors.pendingStatusColor;
      case TaskStatus.inProgress:
        return AppColors.inProgressStatusColor;
      case TaskStatus.completed:
        return AppColors.completedStatusColor;
    }
  }

  Color getStatusTextColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return AppColors.black;
      case TaskStatus.inProgress:
        return AppColors.textColorBlue;
      case TaskStatus.completed:
        return AppColors.textColorGreen;
    }
  }

  double getCompletionPercent() {
    if (task.totalSubtasks != null &&
        task.totalSubtasks! > 0 &&
        task.completedSubtasks != null) {
      return (task.completedSubtasks! / task.totalSubtasks!).clamp(0.0, 1.0);
    }
    return 0.0;
  }

  return InkWell(
    onTap: () {
      Get.to(() => TaskDetailsScreen(task: task), transition: Transition.leftToRight);
    },
    child: Stack(
      children: [
        Container(
          padding: EdgeInsets.all(screenWidth * 0.04), // 16px equivalent
          decoration: BoxDecoration(
            color: AppColors.backgroundColor,
            borderRadius: BorderRadius.circular(screenWidth * 0.03), // 12px equivalent
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: screenWidth * 0.015, // 6px equivalent
                offset: Offset(0, screenWidth * 0.005), // 2px equivalent
              ),
            ],
            border: Border.all(
              color: AppColors.lightGrey,
              width: screenWidth * 0.00375, // 1.5px equivalent
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Title
              Padding(
                padding: EdgeInsets.only(top: screenWidth * 0.05), // 20px equivalent
                child: Row(
                  children: [
                    if (task.status == TaskStatus.completed)
                      Icon(
                        Icons.check_circle,
                        color: AppColors.textColorGreen,
                        size: screenWidth * 0.045, // Responsive icon size
                      ),
                    SizedBox(width: screenWidth * 0.02), // 8px equivalent
                    Expanded(
                      child: Text(
                        task.title,
                        style: titleTextStyle ??
                            TextStyle(
                              fontSize: screenWidth * 0.04, // 16px equivalent
                              fontWeight: FontWeight.bold,
                              color: AppColors.black,
                              decoration: task.status == TaskStatus.completed
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenWidth * 0.03), // 12px equivalent

              /// Time + Progress
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: screenWidth * 0.03, // 12px equivalent
                    color: Colors.grey[500],
                  ),
                  SizedBox(width: screenWidth * 0.01), // 4px equivalent
                  Expanded(
                    flex: 2,
                    child: Text(
                      task.time,
                      style: timeTextStyle ??
                          TextStyle(
                            fontSize: screenWidth * 0.03, // 12px equivalent
                            color: Colors.grey[600],
                          ),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.03), // 12px equivalent
                  if (task.totalSubtasks != null &&
                      task.totalSubtasks! > 0 &&
                      task.completedSubtasks != null)
                    Expanded(
                      flex: 5,
                      child: Row(
                        children: [
                          Icon(
                            Icons.assignment_outlined,
                            size: screenWidth * 0.03, // 12px equivalent
                            color: Colors.grey[500],
                          ),
                          SizedBox(width: screenWidth * 0.01), // 4px equivalent
                          Expanded(
                            flex: 3,
                            child: Text(
                              '${task.completedSubtasks} / ${task.totalSubtasks} subtasks',
                              style: subtaskTextStyle ??
                                  TextStyle(
                                    fontSize: screenWidth * 0.03, // 12px equivalent
                                    color: Colors.grey[600],
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.02), // 8px equivalent
                          Container(
                            width: progressBarWidth,
                            height: screenWidth * 0.015, // 6px equivalent
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(screenWidth * 0.0075), // 3px equivalent
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: getCompletionPercent(),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor,
                                  borderRadius: BorderRadius.circular(screenWidth * 0.0075),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.01), // 4px equivalent
                          Text(
                            '${(getCompletionPercent() * 100).round()}%',
                            style: percentageTextStyle ??
                                TextStyle(
                                  fontSize: screenWidth * 0.03, // 12px equivalent
                                  color: Colors.grey[600],
                                ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              SizedBox(height: screenWidth * 0.02), // 8px equivalent
              const DottedLine(),
              SizedBox(height: screenWidth * 0.02), // 8px equivalent

              // Bottom chips
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Chip(
                    label: Text(
                      'Self Task',
                      style: selfTaskTextStyle ??
                          TextStyle(
                            fontSize: screenWidth * 0.03, // 12px equivalent
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                    ),
                    backgroundColor: AppColors.mainBottomNavColor.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.01), // 4px equivalent
                    ),
                    side: BorderSide(color: AppColors.lightGrey),
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.025,
                      vertical: screenWidth * 0.0125,
                    ),
                  ),

                  if (task.status == TaskStatus.pending)
                    Chip(
                      label: Text(
                        'Start',
                        style: startButtonTextStyle ??
                            TextStyle(
                              fontSize: screenWidth * 0.03, // 12px equivalent
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                      ),
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.01),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.04,
                        vertical: screenWidth * 0.015,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),

        /// Status badge
        Positioned(
          top: screenWidth * 0.005, // Small offset from top
          right: screenWidth * 0.025, // 10px equivalent
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.02, // 8px equivalent
              vertical: screenWidth * 0.01, // 4px equivalent
            ),
            decoration: BoxDecoration(
              color: getStatusColor(task.status),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(screenWidth * 0.03), // 12px equivalent
                bottomRight: Radius.circular(screenWidth * 0.03),
              ),
            ),
            child: Text(
              task.status.name
                  .replaceAll('inProgress', 'In Progress')
                  .toUpperCase(),
              style: statusTextStyle ??
                  TextStyle(
                    fontSize: screenWidth * 0.025, // 10px equivalent
                    fontWeight: FontWeight.bold,
                    color: getStatusTextColor(task.status),
                  ),
            ),
          ),
        ),
      ],
    ),
  );
}