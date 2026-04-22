/**
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../../utils/app_colors.dart';
import '../../../../../utils/app_texts_style.dart';
import '../../../widget/dotted_border_container.dart';
import '../../bottom_navigation/main_bottom_nav.dart';
import 'edit_task_screen.dart';
import 'model/task_model.dart';
import 'package:askfemi/features/individual_user/views/home/task_details/task_details_screen_controller.dart';

class TaskDetailsScreen extends StatefulWidget {
  final String? taskId;

  const TaskDetailsScreen({super.key, this.taskId});

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  late final TaskDetailsScreenController controller;
  bool _isMarkingSubtasks = false;

  @override
  void initState() {
    super.initState();
    controller = Get.put(TaskDetailsScreenController());

    if (widget.taskId != null && widget.taskId!.isNotEmpty) {
      controller.fetchTaskDetails(widget.taskId!);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _confirmDeleteTask() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.lightGrey,
                ),
                height: 8,
                width: 50,
              ),
              const SizedBox(height: 32),
              SvgPicture.asset("assets/icons/insert_drive_file.svg"),
              const SizedBox(height: 16),
              Text('Delete Task?', style: AppTextStyles.smallHeading),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to delete this Task?',
                textAlign: TextAlign.center,
                style: AppTextStyles.defaultTextStyle.copyWith(
                  color: AppColors.grey,
                ),
              ),
              const SizedBox(height: 24),
              Obx(() => Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.backgroundColor,
                        side: BorderSide(color: AppColors.primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'No',
                        style: AppTextStyles.defaultTextStyle.copyWith(
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: controller.isDeleting.value
                          ? null
                          : () async {
                        final taskId = controller.task.value?.id;
                        if (taskId == null) return;

                        final success = await controller.deleteTask(taskId);
                        Get.back();

                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Task deleted successfully!'),
                              duration: Duration(seconds: 2),
                              backgroundColor: Colors.green,
                            ),
                          );
                          Get.offAll(() => MainBottomNav());
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(controller.errorMessage.value),
                              duration: const Duration(seconds: 3),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: controller.isDeleting.value
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : Text(
                        'Yes',
                        style: AppTextStyles.defaultTextStyle.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              )),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleStatusUpdate() async {
    final currentTask = controller.task.value;
    if (currentTask == null) return;

    if (currentTask.status == TaskStatus.pending) {
      // Start task
      final success = await controller.updateTaskStatus(currentTask.id, 'inProgress');
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task started successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else if (currentTask.status == TaskStatus.inProgress) {
      // Check if there are any incomplete subtasks
      final incompleteSubtasks = currentTask.subtasks
          .where((subtask) => !subtask.isCompleted)
          .toList();

      if (incompleteSubtasks.isNotEmpty) {
        // Show loading indicator while marking subtasks
        setState(() => _isMarkingSubtasks = true);

        print('📤 Found ${incompleteSubtasks.length} incomplete subtasks, marking them as completed...');

        // Mark all incomplete subtasks as completed
        for (int i = 0; i < currentTask.subtasks.length; i++) {
          final subtask = currentTask.subtasks[i];
          if (!subtask.isCompleted) {
            await controller.toggleSubtaskStatus(
              currentTask.id,
              subtask.id!,
              true,
              i,
            );
            await Future.delayed(const Duration(milliseconds: 50));
          }
        }

        // ✅ Refresh the screen by fetching updated task details
        await controller.fetchTaskDetails(currentTask.id);

        setState(() => _isMarkingSubtasks = false);
        // Don't mark task as completed yet - user needs to tap Complete again
        return;
      } else {
        // All subtasks are completed, now mark task as completed
        final success = await controller.updateTaskStatus(currentTask.id, 'completed');

        if (success) {
          // ✅ Refresh the screen after completion
          await controller.fetchTaskDetails(currentTask.id);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Task completed successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          Future.delayed(const Duration(milliseconds: 500), () {
            controller.showSupportAlertIfNeeded(context);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(controller.errorMessage.value),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.task.value == null) {
        return const Scaffold(
          backgroundColor: AppColors.white,
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      if (controller.errorMessage.value.isNotEmpty && controller.task.value == null) {
        return Scaffold(
          backgroundColor: AppColors.white,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text(
                  controller.errorMessage.value,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (widget.taskId != null) {
                      controller.fetchTaskDetails(widget.taskId!);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      }

      final task = controller.task.value;
      if (task == null) {
        return const Scaffold(
          backgroundColor: AppColors.white,
          body: Center(
            child: Text('No task data available'),
          ),
        );
      }

      return _buildContent(context, task);
    });
  }

  Widget _buildContent(BuildContext context, Task task) {
    final isCompleted = task.status == TaskStatus.completed;
    final isPending = task.status == TaskStatus.pending;
    final isInProgress = task.status == TaskStatus.inProgress;

    // Check if all subtasks are completed (for inProgress tasks)
    final allSubtasksCompleted = task.subtasks.isNotEmpty
        ? task.subtasks.every((subtask) => subtask.isCompleted)
        : true;

    // Subtasks can only be checked when task is IN PROGRESS (not completed)
    final isCheckboxEnabled = isInProgress && !controller.isTogglingSubtask.value && !_isMarkingSubtasks;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text("Details", style: AppTextStyles.smallHeading),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        surfaceTintColor: AppColors.transparent,
        actions: [
          Builder(
            builder: (context) {
              final buttonKey = GlobalKey();
              return Container(
                width: 60,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 18.0),
                child: Ink(
                  key: buttonKey,
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () async {
                      final RenderBox? buttonBox = buttonKey.currentContext?.findRenderObject() as RenderBox?;
                      if (buttonBox == null) return;

                      final Offset anchorOffset = buttonBox.localToGlobal(Offset.zero);
                      final Size buttonSize = buttonBox.size;

                      await showMenu<String>(
                        context: context,
                        position: RelativeRect.fromLTRB(
                          anchorOffset.dx,
                          anchorOffset.dy,
                          buttonSize.width - 20,
                          anchorOffset.dy + buttonSize.height,
                        ),
                        items: [
                          if (!isCompleted)
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text(
                                'Edit Task',
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                          const PopupMenuDivider(height: 1),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text(
                              'Delete Task',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ],
                        color: AppColors.backgroundColor,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: AppColors.lightGrey, width: 1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ).then((value) {
                        if (value == 'edit') {
                          debugPrint("Edit tapped");
                          Get.to(() => EditTaskScreen(originalTask: task));
                        } else if (value == 'delete') {
                          debugPrint("Delete tapped");
                          _confirmDeleteTask();
                        }
                      });
                    },
                    child: SvgPicture.asset(
                      "assets/icons/more_horiz_icon.svg",
                      fit: BoxFit.contain,
                      width: 40,
                      height: 40,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Status Card
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
                                const SizedBox(height: 8),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "Task Created Time: ",
                                        style: AppTextStyles.smallText,
                                      ),
                                      TextSpan(
                                        text: _formatDateTime(task.createdAt),
                                        style: TextStyle(
                                          color: AppColors.primaryColor,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                if (task.status == TaskStatus.inProgress)
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: "Task start Time: ",
                                          style: AppTextStyles.smallText,
                                        ),
                                        TextSpan(
                                          text: _formatDateTime(task.startTime),
                                          style: TextStyle(
                                            color: AppColors.primaryColor,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (task.status == TaskStatus.completed && task.completedTime != null)
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
                                            text: _formatDateTime(task.completedTime!),
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
                  Positioned(
                    top: 0,
                    right: 15,
                    child: _buildStatusBadge(task.status),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              /// Task Title
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
                        task.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Divider(),
                      const SizedBox(height: 10),
                      Text(
                        'Description',
                        style: AppTextStyles.smallText.copyWith(fontSize: 14),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        task.description,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              /// Subtask Progress
              if (task.subtasks.isNotEmpty) _buildSubTaskProgress(task),
              const SizedBox(height: 20),

              /// Subtask List with Circular Checkboxes
              if (task.subtasks.isNotEmpty) _buildSubTaskList(task, isCheckboxEnabled),
              const SizedBox(height: 16),

              /// Info message for pending tasks (subtasks cannot be checked)
              if (isPending && task.subtasks.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.notice.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.notice.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: AppColors.notice.withValues(alpha: 0.7), size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Click 'Start' to begin working on subtasks",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange.shade800,
                              fontFamily: 'Plus Jakarta Sans',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              /// Start/Complete Button
              if (!isCompleted)
                SizedBox(
                  width: double.infinity,
                  child: Obx(() {
                    String buttonText = isPending ? 'Start' : 'Complete';
                    bool isButtonEnabled = !controller.isUpdatingStatus.value && !_isMarkingSubtasks;

                    return ElevatedButton(
                      onPressed: isButtonEnabled ? _handleStatusUpdate : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: (controller.isUpdatingStatus.value || _isMarkingSubtasks)
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : Text(
                        buttonText,
                        style: AppTextStyles.defaultTextStyle.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubTaskProgress(Task task) {
    final totalSubtasks = task.totalSubtasks;
    final completedSubtasks = task.completedSubtasks;
    final progress = totalSubtasks > 0 ? completedSubtasks / totalSubtasks : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Subtask Progress',
              style: AppTextStyles.defaultTextStyle.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '$completedSubtasks/$totalSubtasks',
              style: TextStyle(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  // Widget _buildSubTaskList(Task task, bool isCheckboxEnabled) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         'Subtask item (${task.subtasks.length})',
  //         style: AppTextStyles.defaultTextStyle.copyWith(
  //           fontWeight: FontWeight.w600,
  //           fontSize: 20,
  //         ),
  //       ),
  //       const SizedBox(height: 12),
  //       ...task.subtasks.asMap().entries.map((entry) {
  //         final index = entry.key;
  //         final subtask = entry.value;
  //         final isChecked = subtask.isCompleted;
  //
  //         return Obx(() => Padding(
  //           padding: const EdgeInsets.only(bottom: 12),
  //           child: Row(
  //             children: [
  //               GestureDetector(
  //                 onTap: isCheckboxEnabled
  //                     ? () => controller.toggleSubtaskStatus(
  //                   task.id,
  //                   subtask.id!,
  //                   !isChecked,
  //                   index,
  //                 )
  //                     : null,
  //                 child: Container(
  //                   width: 24,
  //                   height: 24,
  //                   decoration: BoxDecoration(
  //                     shape: BoxShape.circle,
  //                     color: isChecked ? AppColors.green : Colors.transparent,
  //                     border: Border.all(
  //                       color: isChecked ? AppColors.green : Colors.grey.shade400,
  //                       width: 2,
  //                     ),
  //                   ),
  //                   child: isChecked
  //                       ? const Icon(Icons.check, size: 14, color: Colors.white)
  //                       : null,
  //                 ),
  //               ),
  //               const SizedBox(width: 12),
  //               Expanded(
  //                 child: Text(
  //                   subtask.title,
  //                   style: TextStyle(
  //                     fontSize: 20,
  //                     decoration: isChecked ? TextDecoration.lineThrough : null,
  //                     color: isChecked ? Colors.grey.shade500 : Colors.black87,
  //                   ),
  //                 ),
  //               ),
  //               if (controller.isTogglingSubtask.value &&
  //                   controller.currentTogglingSubtaskIndex.value == index)
  //                 const SizedBox(
  //                   width: 20,
  //                   height: 20,
  //                   child: CircularProgressIndicator(
  //                     strokeWidth: 2,
  //                     color: AppColors.primaryColor,
  //                   ),
  //                 ),
  //             ],
  //           ),
  //         ));
  //       }).toList(),
  //     ],
  //   );
  // }



  Widget _buildSubTaskList(Task task, bool isCheckboxEnabled) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Subtask item (${task.subtasks.length})',
          style: AppTextStyles.defaultTextStyle.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 12),
        ...task.subtasks.asMap().entries.map((entry) {
          final index = entry.key;
          final subtask = entry.value;
          final isChecked = subtask.isCompleted;

          return Obx(() => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              // ✅ White card with border
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade100,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    // ✅ Circular Checkbox - FIXED: Added behavior: HitTestBehavior.opaque
                    GestureDetector(
                      behavior: HitTestBehavior.opaque, // 🔥 Fixes tap on transparent areas
                      onTap: isCheckboxEnabled
                          ? () => controller.toggleSubtaskStatus(
                        task.id,
                        subtask.id!,
                        !isChecked,
                        index,
                      )
                          : null,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isChecked ? AppColors.green : Colors.transparent,
                          border: Border.all(
                            color: isChecked ? AppColors.green : Colors.grey.shade400,
                            width: 2,
                          ),
                        ),
                        child: isChecked
                            ? const Icon(Icons.check, size: 14, color: Colors.white)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        subtask.title,
                        style: TextStyle(
                          fontSize: 16, // ✅ Adjusted for card layout
                          decoration: isChecked ? TextDecoration.lineThrough : null,
                          color: isChecked ? Colors.grey.shade500 : Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (controller.isTogglingSubtask.value &&
                        controller.currentTogglingSubtaskIndex.value == index)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primaryColor,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ));
        }).toList(),
      ],
    );
  }


  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final datePattern = dateTime.year != now.year ? 'MMMM d, y' : 'MMMM d';
    return '${DateFormat(datePattern).format(dateTime)} at ${DateFormat('h:mm a').format(dateTime)}';
  }

  Widget _buildStatusBadge(TaskStatus status) {
    String label;
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case TaskStatus.pending:
        label = 'Pending';
        backgroundColor = AppColors.pendingStatusColor;
        textColor = AppColors.black;
        break;
      case TaskStatus.inProgress:
        label = 'In Progress';
        backgroundColor = AppColors.inProgressStatusColor;
        textColor = AppColors.primaryColor;
        break;
      case TaskStatus.completed:
        label = 'Completed';
        backgroundColor = AppColors.completedStatusColor;
        textColor = AppColors.textColorGreen;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.only(
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
}*/






///
///
///
/// todo:: adding the support mode
///
///
///





import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../../utils/app_colors.dart';
import '../../../../../utils/app_texts_style.dart';
import '../../../widget/dotted_border_container.dart';
import '../../bottom_navigation/main_bottom_nav.dart';
import 'edit_task_screen.dart';
import 'model/task_model.dart';
import 'package:askfemi/features/individual_user/views/home/task_details/task_details_screen_controller.dart';

class TaskDetailsScreen extends StatefulWidget {
  final String? taskId;

  const TaskDetailsScreen({super.key, this.taskId});

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  late final TaskDetailsScreenController controller;
  bool _isMarkingSubtasks = false;

  @override
  void initState() {
    super.initState();
    controller = Get.put(TaskDetailsScreenController());

    if (widget.taskId != null && widget.taskId!.isNotEmpty) {
      controller.fetchTaskDetails(widget.taskId!);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _confirmDeleteTask() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.lightGrey,
                ),
                height: 8,
                width: 50,
              ),
              const SizedBox(height: 32),
              SvgPicture.asset("assets/icons/insert_drive_file.svg"),
              const SizedBox(height: 16),
              Text('Delete Task?', style: AppTextStyles.smallHeading),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to delete this Task?',
                textAlign: TextAlign.center,
                style: AppTextStyles.defaultTextStyle.copyWith(
                  color: AppColors.grey,
                ),
              ),
              const SizedBox(height: 24),
              Obx(() => Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.backgroundColor,
                        side: BorderSide(color: AppColors.primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'No',
                        style: AppTextStyles.defaultTextStyle.copyWith(
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: controller.isDeleting.value
                          ? null
                          : () async {
                        final taskId = controller.task.value?.id;
                        if (taskId == null) return;

                        final success =
                        await controller.deleteTask(taskId);
                        Get.back();

                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                              Text('Task deleted successfully!'),
                              duration: Duration(seconds: 2),
                              backgroundColor: Colors.green,
                            ),
                          );
                          Get.offAll(() => MainBottomNav());
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  controller.errorMessage.value),
                              duration: const Duration(seconds: 3),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: controller.isDeleting.value
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : Text(
                        'Yes',
                        style: AppTextStyles.defaultTextStyle
                            .copyWith(color: AppColors.white),
                      ),
                    ),
                  ),
                ],
              )),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleStatusUpdate() async {
    final currentTask = controller.task.value;
    if (currentTask == null) return;

    if (currentTask.status == TaskStatus.pending) {
      // ─── START task ───────────────────────────────────────────────
      final success =
      await controller.updateTaskStatus(currentTask.id, 'inProgress');
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task started successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(controller.errorMessage.value),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } else if (currentTask.status == TaskStatus.inProgress) {
      // ─── COMPLETE button tapped ───────────────────────────────────
      final incompleteSubtasks =
      currentTask.subtasks.where((s) => !s.isCompleted).toList();

      if (incompleteSubtasks.isNotEmpty) {
        // ── Auto-complete all remaining subtasks one by one ──────────
        setState(() => _isMarkingSubtasks = true);

        print(
          '📤 Auto-completing ${incompleteSubtasks.length} incomplete subtasks...',
        );

        for (int i = 0; i < currentTask.subtasks.length; i++) {
          final subtask = currentTask.subtasks[i];
          if (!subtask.isCompleted) {
            await controller.toggleSubtaskStatus(
              currentTask.id,
              subtask.id!,
              true,
              i,
            );
            await Future.delayed(const Duration(milliseconds: 50));
          }
        }

        // ✅ After bulk auto-complete, check 100% milestone
        final refreshedTask = controller.task.value;
        if (refreshedTask != null) {
          final allDone = refreshedTask.subtasks.every((s) => s.isCompleted);
          if (allDone) {
            controller.checkMilestoneAfterBulkComplete(context, refreshedTask);
          }
        }

        setState(() => _isMarkingSubtasks = false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
            Text('All subtasks completed! Tap Complete again to finish.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        return; // User taps Complete again to finish the task
      } else {
        // ── All subtasks already done — mark task as completed ───────
        final success =
        await controller.updateTaskStatus(currentTask.id, 'completed');

        if (success) {
          await controller.fetchTaskDetails(currentTask.id);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Task completed successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          Future.delayed(const Duration(milliseconds: 500), () {
            controller.showSupportAlertIfNeeded(context);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(controller.errorMessage.value),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.task.value == null) {
        return const Scaffold(
          backgroundColor: AppColors.white,
          body: Center(child: CircularProgressIndicator()),
        );
      }

      if (controller.errorMessage.value.isNotEmpty &&
          controller.task.value == null) {
        return Scaffold(
          backgroundColor: AppColors.white,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline,
                    size: 64, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text(
                  controller.errorMessage.value,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (widget.taskId != null) {
                      controller.fetchTaskDetails(widget.taskId!);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      }

      final task = controller.task.value;
      if (task == null) {
        return const Scaffold(
          backgroundColor: AppColors.white,
          body: Center(child: Text('No task data available')),
        );
      }

      return _buildContent(context, task);
    });
  }

  Widget _buildContent(BuildContext context, Task task) {
    final isCompleted = task.status == TaskStatus.completed;
    final isPending = task.status == TaskStatus.pending;
    final isInProgress = task.status == TaskStatus.inProgress;

    final allSubtasksCompleted = task.subtasks.isNotEmpty
        ? task.subtasks.every((subtask) => subtask.isCompleted)
        : true;

    // Subtasks can only be checked when task is IN PROGRESS
    final isCheckboxEnabled = isInProgress &&
        !controller.isTogglingSubtask.value &&
        !_isMarkingSubtasks;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text("Details", style: AppTextStyles.smallHeading),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        surfaceTintColor: AppColors.transparent,
        actions: [
          Builder(
            builder: (context) {
              final buttonKey = GlobalKey();
              return Container(
                width: 60,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 18.0),
                child: Ink(
                  key: buttonKey,
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () async {
                      final RenderBox? buttonBox = buttonKey.currentContext
                          ?.findRenderObject() as RenderBox?;
                      if (buttonBox == null) return;

                      final Offset anchorOffset =
                      buttonBox.localToGlobal(Offset.zero);
                      final Size buttonSize = buttonBox.size;

                      await showMenu<String>(
                        context: context,
                        position: RelativeRect.fromLTRB(
                          anchorOffset.dx,
                          anchorOffset.dy,
                          buttonSize.width - 20,
                          anchorOffset.dy + buttonSize.height,
                        ),
                        items: [
                          if (!isCompleted)
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text(
                                'Edit Task',
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                          const PopupMenuDivider(height: 1),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text(
                              'Delete Task',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ],
                        color: AppColors.backgroundColor,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                              color: AppColors.lightGrey, width: 1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ).then((value) {
                        if (value == 'edit') {
                          debugPrint("Edit tapped");
                          Get.to(() => EditTaskScreen(originalTask: task));
                        } else if (value == 'delete') {
                          debugPrint("Delete tapped");
                          _confirmDeleteTask();
                        }
                      });
                    },
                    child: SvgPicture.asset(
                      "assets/icons/more_horiz_icon.svg",
                      fit: BoxFit.contain,
                      width: 40,
                      height: 40,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Status Card
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
                                left: 10, right: 16, top: 16),
                            child: Text(
                              'Status',
                              style: AppTextStyles.defaultTextStyle.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 10, right: 16, bottom: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "Task Due Time: ",
                                        style: AppTextStyles.smallText,
                                      ),
                                      TextSpan(
                                        text: _formatDateTime(task.createdAt),
                                        style: TextStyle(
                                          color: AppColors.primaryColor,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                if (task.status == TaskStatus.inProgress)
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: "Task start Time: ",
                                          style: AppTextStyles.smallText,
                                        ),
                                        TextSpan(
                                          text:
                                          _formatDateTime(task.startTime),
                                          style: TextStyle(
                                            color: AppColors.primaryColor,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (task.status == TaskStatus.completed &&
                                    task.completedTime != null)
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
                                                task.completedTime!),
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
                  Positioned(
                    top: 0,
                    right: 15,
                    child: _buildStatusBadge(task.status),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              /// Task Title + Description
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
                      Text('Task Title',
                          style: AppTextStyles.defaultTextStyle),
                      const SizedBox(height: 6),
                      Text(
                        task.title,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      const Divider(),
                      const SizedBox(height: 10),
                      Text(
                        'Description',
                        style:
                        AppTextStyles.smallText.copyWith(fontSize: 14),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        task.description,
                        style:
                        const TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              if (task.subtasks.isNotEmpty) _buildSubTaskProgress(task),
              const SizedBox(height: 20),

              if (task.subtasks.isNotEmpty)
                _buildSubTaskList(task, isCheckboxEnabled),
              const SizedBox(height: 16),

              /// Info: pending task hint
              if (isPending && task.subtasks.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.notice.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppColors.notice.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: AppColors.notice.withValues(alpha: 0.7),
                            size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Click 'Start' to begin working on subtasks",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange.shade800,
                              fontFamily: 'Plus Jakarta Sans',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              /// All subtasks done hint
              if (isInProgress &&
                  allSubtasksCompleted &&
                  task.subtasks.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: Colors.green.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle,
                            color: Colors.green, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "All subtasks completed! Tap 'Complete' to finish the task.",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green.shade700,
                              fontFamily: 'Plus Jakarta Sans',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              /// Incomplete subtasks hint
              if (isInProgress &&
                  !allSubtasksCompleted &&
                  task.subtasks.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    'Complete all subtasks to finish this task',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade700,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              /// Start / Complete button
              if (!isCompleted)
                SizedBox(
                  width: double.infinity,
                  child: Obx(() {
                    final buttonText = isPending ? 'Start' : 'Complete';
                    final isButtonEnabled = !controller.isUpdatingStatus.value &&
                        !_isMarkingSubtasks;

                    return ElevatedButton(
                      onPressed:
                      isButtonEnabled ? _handleStatusUpdate : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: (controller.isUpdatingStatus.value ||
                          _isMarkingSubtasks)
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : Text(
                        buttonText,
                        style: AppTextStyles.defaultTextStyle.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubTaskProgress(Task task) {
    final totalSubtasks = task.totalSubtasks;
    final completedSubtasks = task.completedSubtasks;
    final progress =
    totalSubtasks > 0 ? completedSubtasks / totalSubtasks : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Subtask Progress',
              style: AppTextStyles.defaultTextStyle
                  .copyWith(fontWeight: FontWeight.w600),
            ),
            Text(
              '$completedSubtasks/$totalSubtasks',
              style: TextStyle(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade200,
            valueColor:
            AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildSubTaskList(Task task, bool isCheckboxEnabled) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Subtask item (${task.subtasks.length})',
          style: AppTextStyles.defaultTextStyle.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 12),
        ...task.subtasks.asMap().entries.map((entry) {
          final index = entry.key;
          final subtask = entry.value;
          final isChecked = subtask.isCompleted;

          return Obx(() => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade100,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: isCheckboxEnabled
                          ? () => controller.toggleSubtaskStatus(
                        task.id,
                        subtask.id!,
                        !isChecked,
                        index,
                      )
                          : null,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isChecked
                              ? AppColors.green
                              : Colors.transparent,
                          border: Border.all(
                            color: isChecked
                                ? AppColors.green
                                : Colors.grey.shade400,
                            width: 2,
                          ),
                        ),
                        child: isChecked
                            ? const Icon(Icons.check,
                            size: 14, color: Colors.white)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        subtask.title,
                        style: TextStyle(
                          fontSize: 16,
                          decoration: isChecked
                              ? TextDecoration.lineThrough
                              : null,
                          color: isChecked
                              ? Colors.grey.shade500
                              : Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (controller.isTogglingSubtask.value &&
                        controller.currentTogglingSubtaskIndex.value ==
                            index)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primaryColor,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ));
        }).toList(),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final datePattern =
    dateTime.year != now.year ? 'MMMM d, y' : 'MMMM d';
    return '${DateFormat(datePattern).format(dateTime)} at ${DateFormat('h:mm a').format(dateTime)}';
  }

  Widget _buildStatusBadge(TaskStatus status) {
    String label;
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case TaskStatus.pending:
        label = 'Pending';
        backgroundColor = AppColors.pendingStatusColor;
        textColor = AppColors.black;
        break;
      case TaskStatus.inProgress:
        label = 'In Progress';
        backgroundColor = AppColors.inProgressStatusColor;
        textColor = AppColors.primaryColor;
        break;
      case TaskStatus.completed:
        label = 'Completed';
        backgroundColor = AppColors.completedStatusColor;
        textColor = AppColors.textColorGreen;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.only(
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