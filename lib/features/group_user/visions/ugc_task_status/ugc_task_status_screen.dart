
import 'package:askfemi/features/group_user/visions/ugc_task_status/ugc_task_status_screen_controller.dart';
import 'package:askfemi/utils/app_colors.dart';
import 'package:askfemi/utils/app_texts_style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:avatar_stack/avatar_stack.dart';
import 'package:get/get.dart';

import '../../widget/custom_dashed_divider.dart';

class UgcTaskStatusScreen extends StatelessWidget {
  const UgcTaskStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UgcTaskStatusController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value && controller.getCurrentTaskCount() == 0) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'All Status',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        ///todo::
                      },
                      icon: const Icon(CupertinoIcons.calendar_today),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Obx(() => _buildStatusTab(
                        'Pending (${controller.pendingTasks.length})',
                        0,
                        controller.selectedTab.value == 0,
                            () => controller.changeTab(0),
                      )),
                      const SizedBox(width: 8),
                      Obx(() => _buildStatusTab(
                        'In Progress (${controller.inProgressTasks.length})',
                        1,
                        controller.selectedTab.value == 1,
                            () => controller.changeTab(1),
                      )),
                      const SizedBox(width: 8),
                      Obx(() => _buildStatusTab(
                        'Completed (${controller.completedTasks.length})',
                        2,
                        controller.selectedTab.value == 2,
                            () => controller.changeTab(2),
                      )),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => controller.refreshData(),
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      Obx(() {
                        final tasks = controller.getCurrentTasks();
                        if (tasks.isEmpty && !controller.isLoading.value) {
                          return SliverFillRemaining(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.inbox_outlined,
                                    size: 64,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No ${controller.tabTitles[controller.selectedTab.value].toLowerCase()} tasks',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                                (context, index) {
                              final task = tasks[index];
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom: 12,
                                  left: 16,
                                  right: 16,
                                  top: index == 0 ? 0 : 0,
                                ),
                                child: _buildTaskCard(
                                  title: task['title'] as String,
                                  time: task['time'] as String,
                                  subtasks: task['subtasks'] as int?,
                                  progress: task['progress'] as int?,
                                  assignee: task['assignee'] as String?,
                                  taskType: task['taskType'] as String?,
                                  isGroupTask: task['isGroupTask'] as bool,
                                  status: controller.selectedTab.value,
                                  groupMemberImages: task['groupMemberImages'] as List<String>? ?? [],
                                ),
                              );
                            },
                            childCount: tasks.length,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildStatusTab(String text, int index, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4A90E2) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF4A90E2) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade600,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildTaskCard({
    required String title,
    required String time,
    int? subtasks,
    int? progress,
    String? assignee,
    String? taskType,
    required bool isGroupTask,
    required int status,
    List<String> groupMemberImages = const [],
  }) {
    String buttonText = 'Start';
    Color buttonColor = AppColors.primaryColor;
    bool showButton = true;

    switch (status) {
      case 0:
        buttonText = 'Start';
        buttonColor = AppColors.primaryColor;
        break;
      case 1:
        buttonText = 'Completed';
        buttonColor = AppColors.primaryColor;
        break;
      case 2:
        showButton = false;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (status == 2) ...[
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: AppColors.green,
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 11,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],

                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.smallHeading.copyWith(
                      decoration: status == 2
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      decorationColor: AppColors.black,
                      decorationThickness: 1.5,

                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),




            const SizedBox(height: 12),
            Row(
              children: [
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                if (subtasks != null && subtasks > 0) ...[
                  Row(
                    children: [
                      Icon(Icons.list_alt, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        '$subtasks subtasks',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  const Spacer(),
                  if (progress != null)
                    Row(
                      children: [
                        Container(
                          width: 30,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: FractionallySizedBox(
                            widthFactor: progress / 100,
                            alignment: Alignment.centerLeft,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$progress%',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            DashedDivider(
              color: Colors.grey.shade300,
              dashWidth: 6,
              dashSpacing: 4,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  fit: FlexFit.loose,
                  child: _buildBottomSection(
                    taskType: taskType,
                    assignee: assignee,
                    isGroupTask: isGroupTask,
                    groupMemberImages: groupMemberImages,
                  ),
                ),
                const SizedBox(width: 8),
                if (showButton)
                  ElevatedButton(
                    onPressed: () {
                      if (status == 0) {
                        print('Starting task: $title');
                      } else if (status == 1) {
                        print('Completing task: $title');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Text(
                        buttonText,
                        style: AppTextStyles.smallText.copyWith(
                          color: AppColors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection({
    String? taskType,
    String? assignee,
    required bool isGroupTask,
    List<String> groupMemberImages = const [],
  }) {
    if (taskType != null && !isGroupTask) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.lightBlueColor,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          taskType,
          style: const TextStyle(fontSize: 12, color: Color(0xFF4A90E2)),
        ),
      );
    } else if (assignee != null && !isGroupTask) {
      return Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.grey.shade300,
            child: Icon(Icons.person, size: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              assignee,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    } else if (isGroupTask) {
      final images = groupMemberImages.isNotEmpty ? groupMemberImages : [
        "assets/images/dummy_child_user_image.png",
        "assets/images/dummy_child_user_image.png",
        "assets/images/dummy_child_user_image.png",
      ];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 80,
                height: 32,
                child: AvatarStack(
                  height: 32,
                  avatars: images.map((image) {
                    if (image.startsWith('http')) {
                      return NetworkImage(image) as ImageProvider;
                    } else {
                      return AssetImage(image) as ImageProvider;
                    }
                  }).toList(),
                  borderWidth: 2,
                  borderColor: Colors.white,
                  infoWidgetBuilder: (hiddenCount, totalAvatars) {
                    return Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '+$hiddenCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (taskType != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.lightBlueColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                taskType,
                style: const TextStyle(fontSize: 12, color: Color(0xFF4A90E2)),
              ),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey.shade300,
                child: Icon(
                  Icons.person,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  assignee ?? '',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      );
    }
    return const SizedBox();
  }
}


