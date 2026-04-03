import 'package:askfemi/features/group_user/visions/ugc_home/ugc_task_details/ugc_task_model/ugc_task_model.dart';
import 'package:askfemi/features/individual_user/widget/dotted_line_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_texts_style.dart';
import '../../../individual_user/views/notification/notification_screen.dart';
import '../../widget/ugc_home_widget/ugc_daily_progress_widget.dart';
import 'controller/ugc_home_screen_controller.dart';

class UgcHomeScreen extends StatefulWidget {
  final VoidCallback onAddTaskPressed;

  const UgcHomeScreen({super.key, required this.onAddTaskPressed});

  @override
  State<UgcHomeScreen> createState() => _UgcHomeScreenState();
}

class _UgcHomeScreenState extends State<UgcHomeScreen> {
  late final UgcHomeController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(UgcHomeController());
  }

  @override
  void dispose() {
    Get.delete<UgcHomeController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Obx(() {
      final tasks = controller.tasks;
      final isEmptyState = tasks.isEmpty && !controller.isLoadingTasks.value;

      final bool showDailyProgress = !isEmptyState &&
          !controller.isLoadingProgress.value &&
          controller.dailyProgress.value != null;

      return Scaffold(
        backgroundColor: isEmptyState ? Colors.white : AppColors.backgroundColor,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          controller: ScrollController()..addListener(() {
            if (ScrollController().position.pixels >=
                ScrollController().position.maxScrollExtent - 200) {
              controller.loadMoreTasks();
            }
          }),
          slivers: [
            /// Collapsible App Bar
            _buildSliverAppBar(context, isEmptyState),

            /// Daily Progress Section (only when data is loaded)
            if (showDailyProgress)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    screenWidth * 0.04,
                    screenWidth * 0.04,
                    screenWidth * 0.04,
                    0,
                  ),
                  child: ugcBuildDailyProgress(controller.dailyProgress.value!, screenWidth),
                ),
              ),

            /// Shimmer Loading for Daily Progress
            if (!isEmptyState && controller.isLoadingProgress.value)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  child: _buildDailyProgressShimmer(screenWidth),
                ),
              ),

            /// Pinned Tasks Header - ALWAYS SHOW (don't wait for loading)
            _buildPinnedTasksHeader(tasks, screenWidth, controller.isLoadingTasks.value),

            /// Shimmer Loading for Tasks (when loading and no tasks)
            if (controller.isLoadingTasks.value && tasks.isEmpty)
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) => Padding(
                      padding: EdgeInsets.only(bottom: screenWidth * 0.04),
                      child: _buildTaskCardShimmer(screenWidth),
                    ),
                    childCount: 5,
                  ),
                ),
              ),

            /// Empty State Content OR Tasks List
            _buildTasksContent(
              context,
              tasks,
              isEmptyState,
              screenWidth,
              screenHeight,
              controller.isLoadingTasks.value,
            ),

            /// Bottom Padding
            SliverToBoxAdapter(child: SizedBox(height: screenWidth * 0.04)),
          ],
        ),
      );
    });
  }

  /// Shimmer for Daily Progress Card
  Widget _buildDailyProgressShimmer(double screenWidth) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Card(
        color: AppColors.white,
        elevation: 1,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(screenWidth * 0.05),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(screenWidth * 0.04),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: screenWidth * 0.3,
                    height: screenWidth * 0.06,
                    color: Colors.white,
                  ),
                  Container(
                    width: screenWidth * 0.15,
                    height: screenWidth * 0.05,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(screenWidth * 0.01),
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenWidth * 0.03),
              Container(
                width: double.infinity,
                height: screenWidth * 0.03,
                color: Colors.white,
              ),
              SizedBox(height: screenWidth * 0.02),
              Container(
                width: screenWidth * 0.5,
                height: screenWidth * 0.04,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Shimmer for Task Card
  Widget _buildTaskCardShimmer(double screenWidth) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Card(
        color: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(screenWidth * 0.04),
          side: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            left: screenWidth * 0.04,
            top: screenWidth * 0.06,
            right: screenWidth * 0.04,
            bottom: screenWidth * 0.04,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title shimmer
              Container(
                width: screenWidth * 0.6,
                height: screenWidth * 0.05,
                color: Colors.white,
              ),
              SizedBox(height: screenWidth * 0.04),

              // Time and subtasks row shimmer
              Row(
                children: [
                  Container(
                    width: screenWidth * 0.1,
                    height: screenWidth * 0.035,
                    color: Colors.white,
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  Container(
                    width: screenWidth * 0.2,
                    height: screenWidth * 0.035,
                    color: Colors.white,
                  ),
                  const Spacer(),
                  Container(
                    width: screenWidth * 0.1,
                    height: screenWidth * 0.035,
                    color: Colors.white,
                  ),
                ],
              ),
              SizedBox(height: screenWidth * 0.04),

              // Divider shimmer
              Container(
                width: double.infinity,
                height: 1,
                color: Colors.white,
              ),
              SizedBox(height: screenWidth * 0.04),

              // Bottom section shimmer
              Row(
                children: [
                  Container(
                    width: screenWidth * 0.3,
                    height: screenWidth * 0.08,
                    color: Colors.white,
                  ),
                  const Spacer(),
                  Container(
                    width: screenWidth * 0.15,
                    height: screenWidth * 0.06,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(screenWidth * 0.02),
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, bool isEmptyState) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SliverAppBar(
      expandedHeight: screenWidth * 0.20,
      floating: false,
      pinned: true,
      stretch: true,
      surfaceTintColor: Colors.transparent,
      backgroundColor: isEmptyState ? Colors.white : AppColors.backgroundColor,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.only(
          left: screenWidth * 0.04,
          bottom: screenWidth * 0.04,
        ),
        background: Container(
          color: isEmptyState ? Colors.white : AppColors.backgroundColor,
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: screenWidth * 0.05,
                  foregroundImage: const AssetImage(
                    "assets/images/dummy_user_image.png",
                  ),
                ),
                SizedBox(width: screenWidth * 0.03),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Welcome back!',
                      style: AppTextStyles.smallText.copyWith(
                        color: isEmptyState ? Colors.grey[600] : null,
                        fontSize: screenWidth * 0.035,
                      ),
                    ),
                    Text(
                      'Rakibul',
                      style: AppTextStyles.defaultTextStyle.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isEmptyState ? Colors.black87 : null,
                        fontSize: screenWidth * 0.045,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(
                right: screenWidth * 0.025,
                bottom: screenWidth * 0.02,
              ),
              child: InkWell(
                onTap: () => Get.to(
                      () => const NotificationScreen(),
                  transition: Transition.fadeIn,
                ),
                child: SvgPicture.asset(
                  "assets/icons/notification_rounded.svg",
                  fit: BoxFit.fitHeight,
                  height: screenWidth * 0.07,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPinnedTasksHeader(List<UgcTask> tasks, double screenWidth, bool isLoadingTasks) {
    // Show active count only when tasks are loaded, otherwise show placeholder
    final activeTasks = tasks.isNotEmpty
        ? tasks.where((task) => task.status != TaskStatus.completed).length
        : 0;

    final taskCount = tasks.isNotEmpty ? tasks.length : 0;

    return SliverPersistentHeader(
      pinned: true,
      delegate: _TasksHeaderDelegate(
        minHeight: screenWidth * 0.175,
        maxHeight: screenWidth * 0.175,
        child: Container(
          color: AppColors.backgroundColor,
          padding: EdgeInsets.fromLTRB(
            screenWidth * 0.04,
            screenWidth * 0.04,
            screenWidth * 0.04,
            screenWidth * 0.02,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Tasks',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: screenWidth * 0.06,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                isLoadingTasks && tasks.isEmpty
                    ? 'Loading...'
                    : '$activeTasks/$taskCount active',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: screenWidth * 0.035,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTasksContent(
      BuildContext context,
      List<UgcTask> tasks,
      bool isEmptyState,
      double screenWidth,
      double screenHeight,
      bool isLoadingTasks,
      ) {
    if (isEmptyState && !isLoadingTasks) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Column(
                  children: [
                    SvgPicture.asset(
                      "assets/images/empty_task.svg",
                      height: screenWidth * 0.375,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: screenWidth * 0.025),
                    Text(
                      "You don't have any current tasks here.\nWe will update you.",
                      style: AppTextStyles.defaultTextStyle.copyWith(
                        fontSize: screenWidth * 0.04,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenWidth * 0.1),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.onAddTaskPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: AppColors.white,
                    padding: EdgeInsets.symmetric(vertical: screenWidth * 0.04),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.03),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, size: screenWidth * 0.05),
                      SizedBox(width: screenWidth * 0.02),
                      Text(
                        'Add Task',
                        style: TextStyle(fontSize: screenWidth * 0.04),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (tasks.isEmpty && isLoadingTasks) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          if (index == tasks.length - 1 && tasks.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              controller.loadMoreTasks();
            });
          }

          return Padding(
            padding: EdgeInsets.only(bottom: screenWidth * 0.04),
            child: AnimatedOpacity(
              opacity: 1.0,
              duration: Duration(milliseconds: 300 + (index * 100)),
              child: _buildTaskCard(context, tasks[index], screenWidth),
            ),
          );
        }, childCount: tasks.length),
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, UgcTask task, double screenWidth) {
    final progress = task.totalSubtasks != null && task.totalSubtasks! > 0
        ? (task.completedSubtasks ?? 0) / task.totalSubtasks!
        : 0.0;

    final isSelfTask = task.assignedBy == null;
    final hasGroupMembers =
        task.groupMembers != null && task.groupMembers!.isNotEmpty;

    return Card(
      color: AppColors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        side: BorderSide(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to task details
        },
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        child: Stack(
          children: [
            // Main content with top padding to accommodate status badge
            Padding(
              padding: EdgeInsets.only(
                left: screenWidth * 0.04,
                top: screenWidth * 0.06,
                right: screenWidth * 0.04,
                bottom: screenWidth * 0.04,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Task Title
                  Text(
                    task.title,
                    style: AppTextStyles.smallHeading.copyWith(
                      fontSize: screenWidth * 0.045,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: screenWidth * 0.04),

                  // Time and Subtasks Row
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: screenWidth * 0.035,
                        color: Colors.grey.shade600,
                      ),
                      SizedBox(width: screenWidth * 0.008),
                      Expanded(
                        flex: 2,
                        child: Text(
                          task.time,
                          style: TextStyle(
                            fontSize: screenWidth * 0.03,
                            color: Colors.grey.shade700,
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      if (task.totalSubtasks != null && task.totalSubtasks! > 0) ...[
                        SizedBox(width: screenWidth * 0.02),
                        Icon(
                          Icons.description_outlined,
                          size: screenWidth * 0.035,
                          color: Colors.grey.shade600,
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            task.status == TaskStatus.inProgress
                                ? '${task.completedSubtasks ?? 0}/${task.totalSubtasks} subtasks'
                                : '${task.totalSubtasks} subtasks',
                            style: TextStyle(
                              fontSize: screenWidth * 0.03,
                              color: Colors.grey.shade700,
                              fontFamily: 'Plus Jakarta Sans',
                              fontWeight: FontWeight.w400,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                      const Spacer(),
                      if (task.totalSubtasks != null)
                        Padding(
                          padding: EdgeInsets.only(right: screenWidth * 0.01),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: screenWidth * 0.075,
                                height: screenWidth * 0.015,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(screenWidth * 0.004),
                                ),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: progress,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColor,
                                      borderRadius: BorderRadius.circular(screenWidth * 0.004),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.005),
                              Text(
                                '${(progress * 100).toInt()}%',
                                style: AppTextStyles.smallText.copyWith(
                                  fontSize: screenWidth * 0.03,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: screenWidth * 0.04),
                  const DottedLine(),
                  SizedBox(height: screenWidth * 0.04),

                  // Bottom Section: Task Type and Actions
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isSelfTask)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.025,
                                  vertical: screenWidth * 0.015,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(screenWidth * 0.015),
                                  border: Border.all(
                                    color: Colors.blue.shade200,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  'Self Task',
                                  style: AppTextStyles.smallText.copyWith(
                                    color: AppColors.primaryColor,
                                    fontSize: screenWidth * 0.03,
                                  ),
                                ),
                              )
                            else if (hasGroupMembers)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: screenWidth * 0.20,
                                    height: screenWidth * 0.0875,
                                    child: Stack(
                                      children: [
                                        for (int i = 0;
                                        i < (task.groupMembers!.length > 3
                                            ? 3
                                            : task.groupMembers!.length);
                                        i++)
                                          Positioned(
                                            left: i * screenWidth * 0.05,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: Colors.white,
                                                  width: screenWidth * 0.005,
                                                ),
                                              ),
                                              child: CircleAvatar(
                                                radius: screenWidth * 0.04,
                                                backgroundImage: task.groupMembers![i].startsWith('http')
                                                    ? NetworkImage(task.groupMembers![i])
                                                    : (task.groupMembers![i].startsWith('assets')
                                                    ? AssetImage(task.groupMembers![i]) as ImageProvider
                                                    : NetworkImage(task.groupMembers![i])),
                                                onBackgroundImageError: (_, __) {},
                                              ),
                                            ),
                                          ),
                                        if (task.groupMembers!.length > 3)
                                          Positioned(
                                            left: screenWidth * 0.15,
                                            child: Container(
                                              width: screenWidth * 0.08,
                                              height: screenWidth * 0.08,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.grey.shade300,
                                                border: Border.all(
                                                  color: Colors.white,
                                                  width: screenWidth * 0.005,
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  '+${task.groupMembers!.length - 3}',
                                                  style: TextStyle(
                                                    fontSize: screenWidth * 0.0275,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.grey.shade700,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: screenWidth * 0.01),
                                  Text(
                                    'Group Task',
                                    style: AppTextStyles.smallText.copyWith(
                                      color: AppColors.black,
                                      fontSize: screenWidth * 0.035,
                                    ),
                                  ),
                                ],
                              )
                            else
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: screenWidth * 0.04,
                                    backgroundImage: task.assignedByImage != null
                                        ? (task.assignedByImage!.startsWith('http')
                                        ? NetworkImage(task.assignedByImage!)
                                        : (task.assignedByImage!.startsWith('assets')
                                        ? AssetImage(task.assignedByImage!) as ImageProvider
                                        : NetworkImage(task.assignedByImage!)))
                                        : const AssetImage("assets/images/dummy_user_image.png") as ImageProvider,
                                    onBackgroundImageError: (_, __) {},
                                  ),
                                  SizedBox(width: screenWidth * 0.02),
                                  Expanded(
                                    child: Text(
                                      'Assigned by ${task.assignedBy ?? "Mr. Tom Alax"}',
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.0325,
                                        color: Colors.grey.shade700,
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            if (hasGroupMembers && task.assignedBy != null)
                              Padding(
                                padding: EdgeInsets.only(top: screenWidth * 0.02),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: screenWidth * 0.035,
                                      backgroundImage: task.assignedByImage != null
                                          ? (task.assignedByImage!.startsWith('http')
                                          ? NetworkImage(task.assignedByImage!)
                                          : (task.assignedByImage!.startsWith('assets')
                                          ? AssetImage(task.assignedByImage!) as ImageProvider
                                          : NetworkImage(task.assignedByImage!)))
                                          : const AssetImage("assets/images/dummy_user_image.png") as ImageProvider,
                                      onBackgroundImageError: (_, __) {},
                                    ),
                                    SizedBox(width: screenWidth * 0.015),
                                    Expanded(
                                      child: Text(
                                        'Assigned by ${task.assignedBy!}',
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.03,
                                          color: Colors.grey.shade600,
                                          fontFamily: 'Plus Jakarta Sans',
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (task.status == TaskStatus.pending)
                        Padding(
                          padding: EdgeInsets.only(top: screenWidth * 0.005),
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              foregroundColor: AppColors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.04,
                                vertical: screenWidth * 0.01,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(screenWidth * 0.02),
                              ),
                              elevation: 0,
                              visualDensity: VisualDensity.compact,
                            ),
                            child: Text(
                              'Start',
                              style: AppTextStyles.smallText.copyWith(
                                color: AppColors.white,
                                fontSize: screenWidth * 0.03,
                              ),
                            ),
                          ),
                        )
                    ],
                  ),
                ],
              ),
            ),

            // Status Badge
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: screenWidth * 0.25,
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.03,
                  vertical: screenWidth * 0.015,
                ),
                decoration: BoxDecoration(
                  color: _getStatusBackgroundColor(task.status),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(screenWidth * 0.04),
                    bottomLeft: Radius.circular(screenWidth * 0.04),
                  ),
                ),
                child: Text(
                  _getStatusText(task.status),
                  style: TextStyle(
                    fontSize: screenWidth * 0.03,
                    fontWeight: FontWeight.w600,
                    color: _getStatusTextColor(task.status),
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusBackgroundColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return Colors.grey.shade100;
      case TaskStatus.inProgress:
        return Colors.blue.shade50;
      case TaskStatus.completed:
        return Colors.green.shade50;
    }
  }

  Color _getStatusTextColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return Colors.grey.shade700;
      case TaskStatus.inProgress:
        return Colors.blue.shade700;
      case TaskStatus.completed:
        return Colors.green.shade700;
    }
  }

  String _getStatusText(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return 'Pending';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.completed:
        return 'Completed';
    }
  }
}

class _TasksHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _TasksHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
      BuildContext context,
      double shrinkOffset,
      bool overlapsContent,
      ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_TasksHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}