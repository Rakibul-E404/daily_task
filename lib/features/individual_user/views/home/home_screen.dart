import 'package:askfemi/features/individual_user/views/home/task_details/model/sub_task_model.dart';
import 'package:askfemi/features/individual_user/views/home/task_details/model/task_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../../../screens/notification/notification_screen.dart';
import '../../../../screens/personal_information/personal_Infromation_screen_controller.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_texts_style.dart';
import '../../widget/build_task_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final PersonalInformationController profileController;

  double _pullDistance = 0;
  bool _isRefreshing = false;
  bool _hasTriggered = false;
  final double _refreshThreshold = 60.0;

  @override
  void initState() {
    super.initState();
    // This will load from cache first, then fetch from API in background
    profileController = Get.isRegistered<PersonalInformationController>()
        ? Get.find<PersonalInformationController>()
        : Get.put(PersonalInformationController());
  }

  @override
  void dispose() {
    // Don't delete the controller as it might be used elsewhere
    super.dispose();
  }

  Future<void> _performSilentRefresh() async {
    if (_isRefreshing) return;

    _isRefreshing = true;

    // This refreshes data in background (same as UgcHomeScreen)
    await profileController.backgroundRefresh();

    _isRefreshing = false;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Show loading only on first load with no data
      if (profileController.isLoading.value && profileController.userName.value.isEmpty) {
        return const Scaffold(
          backgroundColor: AppColors.backgroundColor,
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollStartNotification) {
              _pullDistance = 0;
              _hasTriggered = false;
            }

            if (notification is ScrollUpdateNotification) {
              if (notification.metrics.pixels <= 0 &&
                  notification.metrics.extentBefore == 0) {
                final pullOffset = notification.metrics.pixels.abs();
                _pullDistance = pullOffset;

                if (_pullDistance >= _refreshThreshold &&
                    !_hasTriggered &&
                    !_isRefreshing) {
                  _hasTriggered = true;
                  _performSilentRefresh();
                }
              }
            }

            if (notification is ScrollEndNotification) {
              _pullDistance = 0;
              _hasTriggered = false;
            }

            return false;
          },
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              /// Collapsible App Bar with Profile Info (cached data shows instantly)
              _buildSliverAppBar(profileController),

              /// Daily Progress Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: _buildDailyProgress(),
                ),
              ),

              /// Pinned Tasks Header
              _buildPinnedTasksHeader(),

              /// Tasks List
              _buildTasksList(context),

              /// Bottom Padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 16),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSliverAppBar(PersonalInformationController profileController) {
    return SliverAppBar(
      expandedHeight: 80,
      floating: false,
      pinned: true,
      stretch: true,
      surfaceTintColor: Colors.transparent,
      backgroundColor: AppColors.backgroundColor,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        background: Container(
          color: AppColors.backgroundColor,
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                // Profile Image with CachedNetworkImage
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryColor.withOpacity(0.1),
                  ),
                  child: profileController.userProfileImage.value.isNotEmpty &&
                      profileController.userProfileImage.value.startsWith('http')
                      ? ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: profileController.userProfileImage.value,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      cacheKey: profileController.userProfileImage.value,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      errorWidget: (context, url, error) => Icon(
                        Icons.person,
                        size: 24,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  )
                      : Icon(
                    Icons.person,
                    size: 24,
                    color: AppColors.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Welcome back!',
                      style: AppTextStyles.smallText,
                    ),
                    Text(
                      profileController.userName.value.isEmpty ? 'User' : profileController.userName.value,
                      style: AppTextStyles.defaultTextStyle.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10.0, bottom: 8),
              child: InkWell(
                onTap: () => Get.to(() => const NotificationScreen(), transition: Transition.fadeIn),
                child: SvgPicture.asset(
                  "assets/icons/notification_rounded.svg",
                  fit: BoxFit.fitHeight,
                  height: 28,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyProgress() {
    return Card(
      color: AppColors.backgroundColor,
      elevation: 1,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Daily Progress',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                ),
                Chip(
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  label: Text(
                    '1 / 3',
                    style: TextStyle(
                      color: AppColors.black,
                      fontSize: 12,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.bold,
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
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: 1 / 3,
                    backgroundColor: AppColors.grey.withValues(alpha: 0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primaryColor,
                    ),
                    borderRadius: BorderRadius.circular(2),
                    minHeight: 12,
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '3 tasks remaining. You\'ve got this!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontFamily: 'Plus Jakarta Sans',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPinnedTasksHeader() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _TasksHeaderDelegate(
        minHeight: 70,
        maxHeight: 70,
        child: Container(
          color: AppColors.backgroundColor,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Your Tasks',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Chip(
                label: Text(
                  '1 / 3 active',
                  style: TextStyle(
                    color: AppColors.black,
                    fontSize: 12,
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                ),
                backgroundColor: AppColors.lightGrey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                side: const BorderSide(width: 0, color: Colors.transparent),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTasksList(BuildContext context) {
    final tasks = _getTasks();

    // If no tasks, show empty state
    if (tasks.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/images/empty_task.svg',
                height: 200,
              ),
              const SizedBox(height: 24),
              Text(
                'No tasks yet',
                style: AppTextStyles.defaultTextStyle.copyWith(
                  fontSize: 30,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create your task to get started!',
                style: AppTextStyles.defaultTextStyle,
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            final taskIndex = index ~/ 2;
            return Column(
              children: [
                AnimatedOpacity(
                  opacity: 1.0,
                  duration: Duration(milliseconds: 300 + (taskIndex * 100)),
                  child: buildTaskCard(
                    context: context,
                    task: tasks[taskIndex],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            );
          },
          childCount: tasks.length * 2 - 1,
        ),
      ),
    );
  }

  List<Task> _getTasks() {
    return [
      Task(
        title: 'Complete Math Homework',
        description: 'Solve algebra, geometry and calculus problems.',
        time: '10:30 AM',
        status: TaskStatus.pending,
        createdAt: DateTime(2026, 1, 5, 9, 50),
        startTime: DateTime(2026, 1, 5, 10, 30),
      ),
      Task(
        totalSubtasks: 6,
        completedSubtasks: 2,
        title: 'Complete Math Homework',
        description: 'Solve algebra, geometry and calculus problems.',
        time: '10:30 AM',
        status: TaskStatus.inProgress,
        createdAt: DateTime(2026, 1, 5, 9, 50),
        startTime: DateTime(2026, 1, 5, 10, 30),
      ),
      Task(
        totalSubtasks: 3,
        completedSubtasks: 2,
        title: 'Complete Math Homework',
        description: 'Solve algebra, geometry and calculus problems.',
        time: '10:30 AM',
        status: TaskStatus.inProgress,
        createdAt: DateTime(2025, 1, 5, 9, 50),
        startTime: DateTime(2026, 1, 5, 10, 30),
        subtasks: [
          SubTask(
            title: 'Call with team',
            isCompleted: false,
            duration: null,
          ),
          SubTask(
            title: 'Client meeting',
            isCompleted: true,
            duration: '10 min',
          ),
          SubTask(
            title: 'Team discuss',
            isCompleted: true,
            duration: '20 min',
          ),
        ],
      ),
      Task(
        title: 'Complete Math Homework',
        description: 'Solve algebra, geometry and calculus problems.',
        time: '10:30 AM',
        status: TaskStatus.completed,
        createdAt: DateTime(2024, 1, 5, 9, 50),
        startTime: DateTime(2024, 1, 5, 10, 30),
        completedTime: DateTime(2024, 1, 7, 10, 50),
      ),
      Task(
        totalSubtasks: 5,
        completedSubtasks: 5,
        title: 'Complete Math Homework',
        description: 'Solve algebra, geometry and calculus problems.',
        time: '10:30 AM',
        status: TaskStatus.completed,
        createdAt: DateTime(2026, 1, 5, 9, 50),
        startTime: DateTime(2026, 1, 5, 10, 30),
        completedTime: DateTime(2026, 1, 7, 10, 50),
        subtasks: [
          SubTask(
            title: 'Call with team',
            isCompleted: true,
            duration: null,
          ),
          SubTask(
            title: 'Client meeting',
            isCompleted: true,
            duration: '10 min',
          ),
          SubTask(
            title: 'Team discuss',
            isCompleted: true,
            duration: '20 min',
          ),
        ],
      ),
    ];
  }
}

/// Custom Sliver Persistent Header Delegate for pinned Tasks header
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