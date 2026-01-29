import 'package:askfemi/utils/app_colors.dart';
import 'package:askfemi/utils/app_texts.dart';
import 'package:askfemi/widget/dotted_border_container.dart';
import 'package:flutter/material.dart';
import 'package:askfemi/individual_user/features/home/task_details/model/task_model.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:intl/intl.dart';
import '../../../../widget/sub_task_list.dart';
import '../../../../widget/sub_task_progress.dart';

class TaskDetailsScreen extends StatefulWidget {
  // Changed to StatefulWidget
  final Task task;

  const TaskDetailsScreen({super.key, required this.task});

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  late TextEditingController _subtaskController;
  final FocusNode _subtaskFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _subtaskController = TextEditingController();
    _subtaskController.addListener(() {
      setState(() {}); // Rebuild when text changes
    });
  }

  @override
  void dispose() {
    _subtaskController.dispose();
    _subtaskFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.task.status == TaskStatus.completed;
    final isAddButtonEnabled = _subtaskController.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.white,
      // appBar: AppBar(
      //   title: Text("Details", style: AppTextStyles.smallHeading),
      //   leading: IconButton(
      //     icon: Icon(Icons.arrow_back),
      //     onPressed: () => Get.back(),
      //   ),
      //   actions: [
      //     PopupMenuButton<String>(
      //       color: AppColors.backgroundColor,
      //       offset: Offset(0, 40),
      //       splashRadius: 0.1,
      //       // Removes the splash/ripple effect
      //       itemBuilder: (context) => [
      //         PopupMenuItem(value: 'edit', child: Text('Edit Task')),
      //         PopupMenuItem(value: 'delete', child: Text('Delete Task')),
      //       ],
      //       onSelected: (value) {
      //         if (value == 'edit') {
      //           print("Edit tapped");
      //         } else if (value == 'delete') {
      //           print("Delete tapped");
      //         }
      //       },
      //       child: SizedBox(
      //         width: 60,
      //         height: 100,
      //         child: Center(
      //           child: Padding(
      //             padding: const EdgeInsets.only(right: 18.0),
      //             child: SvgPicture.asset(
      //               "assets/icons/more_horiz_icon.svg",
      //               fit: BoxFit.contain,
      //             ),
      //           ),
      //         ),
      //       ),
      //     ),
      //   ],
      //   backgroundColor: Colors.white,
      //   elevation: 0,
      // ),

      appBar: AppBar(
        title: Text("Details", style: AppTextStyles.smallHeading),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          PopupMenuButton<String>(
            color: AppColors.backgroundColor,
            offset: Offset(0, 40),
            splashRadius: 0.1,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: AppColors.lightGrey, width: 1), // Outline border
              borderRadius: BorderRadius.circular(8), // Rounded corners
            ),
            itemBuilder: (context) => [
              PopupMenuItem(value: 'edit', child: Text('Edit Task',style: AppTextStyles.smallText.copyWith(color: AppColors.black),)),
              PopupMenuDivider(height: 1,color: AppColors.lightGrey,), // Divider between items
              PopupMenuItem(value: 'delete', child: Text('Delete Task',style: AppTextStyles.smallText.copyWith(color: AppColors.black),)),
            ],
            onSelected: (value) {
              if (value == 'edit') {
                print("Edit tapped");
              } else if (value == 'delete') {
                print("Delete tapped");
              }
            },
            child: SizedBox(
              width: 60,
              height: 100,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 18.0),
                  child: SvgPicture.asset(
                    "assets/icons/more_horiz_icon.svg",
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),


      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔹 Status Card with badge positioned at top-right
              Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: dottedBorderContainer(
                      color: AppColors.primaryColor,
                      dashWidth: 5,
                      borderRadius: 12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 10,
                              right: 16,
                              top: 16,
                            ),
                            child: Text(
                              'Status',
                              style: AppTextStyles.defaultTextStyle.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 10,
                              right: 16,
                              bottom: 16,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// Add space at top for the badge
                                const SizedBox(height: 8),

                                /// Timestamps from Task model
                                const SizedBox(height: 8),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "Task Created Time: ",
                                        style: AppTextStyles.smallText,
                                      ),
                                      TextSpan(
                                        text: _formatDateTime(
                                          widget.task.createdAt,
                                        ),
                                        style: TextStyle(
                                          color: AppColors.primaryColor,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                if (widget.task.status == TaskStatus.inProgress)
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: "Task start Time: ",
                                          style: AppTextStyles.smallText,
                                        ),
                                        TextSpan(
                                          text: _formatDateTime(
                                            widget.task.startTime,
                                          ),
                                          style: TextStyle(
                                            color: AppColors.primaryColor,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                if (widget.task.status == TaskStatus.completed)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: "Task completed Time: ",
                                            style: AppTextStyles.smallText,
                                          ),
                                          TextSpan(
                                            text: _formatDateTime(
                                              widget.task.completedTime!,
                                            ),
                                            style: TextStyle(
                                              color: AppColors.primaryColor,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  /// 🔹 Status Badge positioned at top-right corner
                  Positioned(
                    top: 0,
                    right: 15,
                    child: _buildStatusBadge(widget.task.status),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              /// 🔹 Task Title
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.backgroundColor,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Task Title', style: AppTextStyles.defaultTextStyle),
                      const SizedBox(height: 6),
                      Text(
                        widget.task.title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),
                      Divider(),
                      const SizedBox(height: 10),

                      /// 🔹 Description
                      Text(
                        'Description',
                        style: AppTextStyles.smallText.copyWith(fontSize: 14),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.task.description,
                        style: TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
              if (!isCompleted) // Use the isCompleted variable
                subTaskProgress(widget.task),
              const SizedBox(height: 20),
              if (!isCompleted) // Use the isCompleted variable
                subTaskList(widget.task),

              /// 🔹 Add Subtask Input
              if (!isCompleted) // Use the isCompleted variable
                TextField(
                  controller: _subtaskController, // Added controller
                  focusNode: _subtaskFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Add a subtask...',
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.grey, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.grey, width: 1),
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              /// 🔹 Add Task Button - Now conditionally enabled
              if (!isCompleted) // Use the isCompleted variable
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isAddButtonEnabled
                        ? () {
                            // TODO: Add subtask logic
                            print('Adding subtask: ${_subtaskController.text}');
                            _subtaskController.clear(); // Clear after adding
                            _subtaskFocusNode
                                .unfocus(); // Remove keyboard focus
                          }
                        : null, // Disabled when empty
                    icon: Icon(
                      Icons.add,
                      size: 20,
                      color: isAddButtonEnabled
                          ? AppColors.white
                          : AppColors.grey,
                    ),
                    label: Text(
                      'Add Task',
                      style: AppTextStyles.defaultTextStyle.copyWith(
                        color: isAddButtonEnabled
                            ? AppColors.white
                            : AppColors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isAddButtonEnabled
                          ? AppColors.primaryColor
                          : Colors.grey[300], // Different color when disabled
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              /// 🔹 Completed Button (only if pending/in progress)
              if (!isCompleted)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Handle completion logic
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Completed',
                      style: AppTextStyles.defaultTextStyle.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to format DateTime - UPDATED VERSION
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final datePattern = dateTime.year != now.year ? 'MMMM d, y' : 'MMMM d';
    return '${DateFormat(datePattern).format(dateTime)} at ${DateFormat('h:mm a').format(dateTime)}';
  }

  Widget _buildStatusBadge(TaskStatus status) {
    final label = status.name.capitalize();

    // You can customize colors based on status
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case TaskStatus.pending:
        backgroundColor = AppColors.pendingStatusColor;
        textColor = AppColors.black;
        break;
      case TaskStatus.inProgress:
        backgroundColor = AppColors.inProgressStatusColor;
        textColor = AppColors.primaryColor;
        break;
      case TaskStatus.completed:
        backgroundColor = AppColors.completedStatusColor;
        textColor = AppColors.textColorGreen;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontFamily: 'Plus Jakarta Sans',
          fontWeight: FontWeight.normal,
          color: textColor,
        ),
      ),
    );
  }
}

// Helper extension to capitalize first letter
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
