import 'package:askfemi/features/group_user/visions/ugc_home/ugc_task_details/ugc_task_model/ugc_task_model.dart';
import 'package:askfemi/features/group_user/widget/ugc_details_widget/ugc_dotted_border_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../../utils/app_colors.dart';
import '../../../../../utils/app_texts_style.dart';
import '../../bottom_navigation/ugc_bottom_nav.dart';
import 'ugs_task_details_screen_controller.dart';
import 'ugc_edit_task_screen.dart';

class UgcTaskDetailsScreen extends StatelessWidget {
  const UgcTaskDetailsScreen({super.key});

  void _confirmDeleteTask(BuildContext context, UgcTaskDetailsController controller, String taskId) {
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
                          Get.offAll(() => UgcMainBottomNav());
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

  Future<void> _handleStatusUpdate(BuildContext context, UgcTaskDetailsController controller, UgcTask task) async {
    String newStatus;
    String successMessage;

    if (task.status == TaskStatus.pending) {
      newStatus = 'inProgress';
      successMessage = 'Task started successfully!';
    } else if (task.status == TaskStatus.inProgress) {
      newStatus = 'completed';
      successMessage = 'Task completed successfully!';
    } else {
      return;
    }

    bool success;

    // Use different API based on task type
    if (task.taskType == 'personal') {
      success = await controller.updatePersonalTaskStatus(task.id, newStatus);
    } else {
      success = await controller.updateTaskStatus(task.id, newStatus);
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(successMessage),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      // Add a small delay to ensure snackbar is shown first, then show alert
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
    final controller = Get.put(UgcTaskDetailsController());

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text("Details", style: AppTextStyles.smallHeading),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        surfaceTintColor: AppColors.transparent,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Obx(() {
            final task = controller.task.value;
            final isPersonalTask = task?.taskType == 'personal';
            final isCompleted = task?.status == TaskStatus.completed;

            if (!isPersonalTask || task == null) {
              return const SizedBox.shrink();
            }

            return Builder(
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
                            _confirmDeleteTask(context, controller, task.id);
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
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  controller.errorMessage.value,
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    final arguments = Get.arguments;
                    String? taskId;
                    if (arguments is String) {
                      taskId = arguments;
                    } else if (arguments is Map) {
                      taskId = arguments['taskId'] as String?;
                    }
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
          );
        }

        final task = controller.task.value;
        if (task == null) {
          return const Center(
            child: Text('No task data available'),
          );
        }

        return _buildContent(context, task, controller);
      }),
    );
  }

  Widget _buildContent(BuildContext context, UgcTask task, UgcTaskDetailsController controller) {
    final isCompleted = task.status == TaskStatus.completed;
    final isGroupTask = task.groupMembers != null && task.groupMembers!.isNotEmpty;
    final isSelfTask = task.assignedBy == null;
    final isPending = task.status == TaskStatus.pending;
    final isPersonalTask = task.taskType == 'personal';

    // Show status update button for all non-completed tasks (both personal and non-personal)
    final bool showStatusButton = !isCompleted;

    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
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
                  child: ugcDottedBorderContainer(
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

            /// Assigned By Section (for non-self tasks)
            if (!isSelfTask) ...[
              _buildAssignedBySection(task),
              const SizedBox(height: 16),
            ],

            /// Group Members Section (for group tasks)
            if (isGroupTask) ...[
              _buildGroupMembersSection(task),
              const SizedBox(height: 16),
            ],

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
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Divider(),
                    const SizedBox(height: 10),

                    /// Description
                    Text(
                      'Description',
                      style: AppTextStyles.smallText.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      task.description,
                      style: TextStyle(fontSize: 16, height: 1.5),
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

            /// Subtask List with Circular Checkboxes and Toggle API
            if (task.subtasks.isNotEmpty)
              _buildSubTaskList(task, controller),
            const SizedBox(height: 16),

            /// Status Update Button (Start/Complete) - Shows for all non-completed tasks
            if (showStatusButton)
              SizedBox(
                width: double.infinity,
                child: Obx(() => ElevatedButton(
                  onPressed: controller.isUpdatingStatus.value
                      ? null
                      : () => _handleStatusUpdate(context, controller, task),
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
    );
  }

  Widget _buildAssignedBySection(UgcTask task) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.backgroundColor,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundImage: task.assignedByImage != null && task.assignedByImage!.startsWith('http')
                  ? NetworkImage(task.assignedByImage!)
                  : const AssetImage("assets/images/dummy_user_image.png") as ImageProvider,
              onBackgroundImageError: (_, __) {},
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Assigned by',
                  style: AppTextStyles.smallText.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  task.assignedBy ?? 'Unknown',
                  style: AppTextStyles.defaultTextStyle.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupMembersSection(UgcTask task) {
    final members = task.groupMembers ?? [];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.backgroundColor,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Group Members',
              style: AppTextStyles.defaultTextStyle.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: members.asMap().entries.map((entry) {
                final index = entry.key;
                final member = entry.value;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: member.startsWith('http')
                          ? NetworkImage(member)
                          : const AssetImage("assets/images/dummy_user_image.png") as ImageProvider,
                      onBackgroundImageError: (_, __) {},
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Child ${index + 1}',
                      style: AppTextStyles.defaultTextStyle.copyWith(
                        fontSize: 14,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubTaskProgress(UgcTask task) {
    final totalSubtasks = task.totalSubtasks ?? 0;
    final completedSubtasks = task.completedSubtasks ?? 0;
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

  // Updated Subtask List with Circular Checkboxes and Toggle API
  Widget _buildSubTaskList(UgcTask task, UgcTaskDetailsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Subtask item (${task.subtasks.length})',
          style: AppTextStyles.defaultTextStyle.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 20
          ),
        ),
        const SizedBox(height: 12),
        ...task.subtasks.asMap().entries.map((entry) {
          final index = entry.key;
          final subtask = entry.value;
          final isChecked = subtask.isCompleted; // ✅ This comes from API

          return Obx(() => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                // Circular Checkbox
                GestureDetector(
                  onTap: controller.isTogglingSubtask.value
                      ? null
                      : () => controller.toggleSubtaskStatus(task.id, subtask.id, !isChecked, index),
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
                      fontSize: 20,
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