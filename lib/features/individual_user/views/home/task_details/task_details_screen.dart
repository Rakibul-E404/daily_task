/**
import 'package:askfemi/features/individual_user/views/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:intl/intl.dart';
import '../../../../../utils/app_colors.dart';
import '../../../../../utils/app_texts_style.dart';
import '../../../widget/dotted_border_container.dart';
import '../../../widget/sub_task_list.dart';
import '../../../widget/sub_task_progress.dart';
import '../../bottom_navigation/main_bottom_nav.dart';
import '../../../widget/support_alert_cards.dart';
import 'edit_task_screen.dart';
import 'model/task_model.dart';

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
              Text('Delete Task?', style: AppTextStyles.smallHeading), // Changed from 'Delete subtask?'
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to delete this Task?', // Changed from 'Delete subtask?'
                textAlign: TextAlign.center,
                style: AppTextStyles.defaultTextStyle.copyWith(
                  color: AppColors.grey,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(), // No - go back
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
                      onPressed: () {
                        Get.back(); // Close bottom sheet
                        // Show snackbar and navigate to HomeScreen
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Task Deleted!'),
                            duration: Duration(seconds: 1),
                            backgroundColor: AppColors.black,
                          ),
                        );
                        Get.offAll(() => MainBottomNav()); // Navigate to HomeScreen
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'Yes',
                        style: AppTextStyles.defaultTextStyle.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.task.status == TaskStatus.completed;
    final isAddButtonEnabled = _subtaskController.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text("Details", style: AppTextStyles.smallHeading),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
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
                  decoration: BoxDecoration(
                    shape: BoxShape.circle, // Optional: circular splash
                    // If you want square, remove this
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20), // Match circle or use 8 for square
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
                          buttonSize.width-20,
                          anchorOffset.dy + buttonSize.height,
                        ),
                        items: [
                          if(!isCompleted)
                          PopupMenuItem(
                            value: 'edit',
                            child: Text(
                              'Edit Task',
                              style: AppTextStyles.defaultTextStyle.copyWith(fontSize: 20),
                            ),
                          ),
                          PopupMenuDivider(height: 1, color: AppColors.lightGrey),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text(
                              'Delete Task',
                              style: AppTextStyles.defaultTextStyle.copyWith(fontSize: 20),
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
                          Get.to(() => EditTaskScreen(originalTask: widget.task));
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
        physics: BouncingScrollPhysics(),
        child: SizedBox(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
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
                // if (!isCompleted) // Use the isCompleted variable
                //   subTaskProgress(widget.task),
                const SizedBox(height: 20),
                // if (!isCompleted) // Use the isCompleted variable
                  subTaskList(widget.task),

                /// 🔹 Completed Button (only if pending/in progress)
                if (!isCompleted)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Handle completion logic
                        SupportAlertCards.show(
                          context,
                          type: SupportAlertType.calm100,
                          onButtonTap: () {
                            Get.to(() => MainBottomNav());
                          }
                        );
                        // Get.to(() => MainBottomNav());

                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: AppColors.white,
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

    // You can customize colors based on history
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








*/











///
///
///
///
/// todO:: adding with api
///
///
///
///




import 'package:askfemi/features/individual_user/views/home/home_screen.dart';
import 'package:askfemi/features/individual_user/views/home/task_details/task_details_screen_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../../utils/app_colors.dart';
import '../../../../../utils/app_texts_style.dart';
import '../../../widget/dotted_border_container.dart';
import '../../../widget/sub_task_list.dart';
import '../../../widget/sub_task_progress.dart';
import '../../bottom_navigation/main_bottom_nav.dart';
import '../../../widget/support_alert_cards.dart';
import 'edit_task_screen.dart';
import 'model/task_model.dart';

class TaskDetailsScreen extends StatefulWidget {
  final Task? task;
  final String? taskId;

  const TaskDetailsScreen({super.key, this.task, this.taskId});

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  late final TaskDetailsScreenController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(TaskDetailsScreenController());

    // If task is passed directly, set it
    if (widget.task != null) {
      controller.task.value = widget.task;
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

    String newStatus;
    String successMessage;

    if (currentTask.status == TaskStatus.pending) {
      newStatus = 'inProgress';
      successMessage = 'Task started successfully!';
    } else if (currentTask.status == TaskStatus.inProgress) {
      newStatus = 'completed';
      successMessage = 'Task completed successfully!';
    } else {
      return;
    }

    final success = await controller.updateTaskStatus(currentTask.id, newStatus);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(successMessage),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
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

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Show loading state
      if (controller.isLoading.value && controller.task.value == null) {
        return Scaffold(
          backgroundColor: AppColors.white,
          body: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      // Show error state
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
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    final taskId = widget.taskId ?? controller.task.value?.id;
                    if (taskId != null) {
                      controller.fetchTaskDetails(taskId);
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

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text("Details", style: AppTextStyles.smallHeading),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
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
                  decoration: BoxDecoration(
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
                            PopupMenuItem(
                              value: 'edit',
                              child: Text(
                                'Edit Task',
                                style: AppTextStyles.defaultTextStyle.copyWith(fontSize: 20),
                              ),
                            ),
                          PopupMenuDivider(height: 1, color: AppColors.lightGrey),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text(
                              'Delete Task',
                              style: AppTextStyles.defaultTextStyle.copyWith(fontSize: 20),
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
              /// Status Card with badge positioned at top-right
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
                  /// Status Badge positioned at top-right corner
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
              if (task.subtasks.isNotEmpty)
                _buildSubTaskProgress(task),
              const SizedBox(height: 20),

              /// Subtask List with Circular Checkboxes
              if (task.subtasks.isNotEmpty)
                _buildSubTaskList(task),
              const SizedBox(height: 16),

              /// Completed Button (only if pending/in progress)
              if (!isCompleted)
                SizedBox(
                  width: double.infinity,
                  child: Obx(() => ElevatedButton(
                    onPressed: controller.isUpdatingStatus.value
                        ? null
                        : _handleStatusUpdate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: controller.isUpdatingStatus.value
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : Text(
                      isPending ? 'Start' : 'Complete',
                      style: AppTextStyles.defaultTextStyle.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )),
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

  Widget _buildSubTaskList(Task task) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Subtask item (${task.subtasks.length})',
          style: AppTextStyles.defaultTextStyle.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...task.subtasks.asMap().entries.map((entry) {
          final index = entry.key;
          final subtask = entry.value;
          final isChecked = subtask.isCompleted;

          return Obx(() => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: controller.isTogglingSubtask.value
                      ? null
                      : () => controller.toggleSubtaskStatus(
                    task.id,
                    subtask.id,  // ✅ This can be null now, handled in controller
                    !isChecked,
                    index,
                  ),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isChecked ? AppColors.primaryColor : Colors.transparent,
                      border: Border.all(
                        color: isChecked ? AppColors.primaryColor : Colors.grey.shade400,
                        width: 2,
                      ),
                    ),
                    child: isChecked
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    subtask.title,
                    style: TextStyle(
                      fontSize: 16,
                      decoration: isChecked ? TextDecoration.lineThrough : null,
                      color: isChecked ? Colors.grey.shade500 : Colors.black87,
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
    // final label = status.name.capitalize();
    final label = status.name.capitalizeFirst;

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
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Text(
        label!,
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

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}