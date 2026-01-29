/*
import 'package:askfemi/individual_user/features/home/task_details/model/sub_task_model.dart';
import 'package:askfemi/individual_user/features/home/task_details/model/task_model.dart';
import 'package:askfemi/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../widget/build_task_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          title: Row(
            children: [
              CircleAvatar(
                foregroundImage: AssetImage(
                  "assets/images/dummy_user_image.png",
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back!',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const Text(
                    'Hi, Rakibul',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: SvgPicture.asset(
                "assets/icons/notification.svg",
                fit: BoxFit.fitHeight,
                height: 40,
              ),
            ),
          ],
          centerTitle: false,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Daily progress
                _buildDailyProgress(),
                const SizedBox(height: 32),

                /// Your Tasks section
                _buildTasksSection(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDailyProgress() {
    return Card(
      color: AppColors.white,
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
                  padding: EdgeInsets.only(left: 5, right: 5),
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
                  side: BorderSide(width: 0, color: Colors.transparent),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: 1 / 3,
                    backgroundColor: Colors.grey[200],
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

  Widget _buildTasksSection(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                side: BorderSide(width: 0, color: Colors.transparent),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  buildTaskCard(
                    context: context,
                    task: Task(
                      title: 'Complete Math Homework',
                      description:
                          'Solve algebra, geometry and calculus problems.',
                      time: '10:30 AM',
                      status: TaskStatus.pending,
                      createdAt: DateTime(2026, 1, 5, 9, 50),
                      // Jan 5, 9:50 AM
                      startTime: DateTime(
                        2026,
                        1,
                        5,
                        10,
                        30,
                      ), // Jan 5, 10:30 AM
                    ),
                  ),

                  const SizedBox(height: 16),
                  buildTaskCard(
                    context: context,
                    task: Task(
                      totalSubtasks: 6,
                      completedSubtasks: 2,
                      title: 'Complete Math Homework',
                      description:
                          'Solve algebra, geometry and calculus problems.',
                      time: '10:30 AM',
                      status: TaskStatus.inProgress,
                      createdAt: DateTime(2026, 1, 5, 9, 50),
                      // Jan 5, 9:50 AM
                      startTime: DateTime(
                        2026,
                        1,
                        5,
                        10,
                        30,
                      ), // Jan 5, 10:30 AM
                    ),
                  ),
                  const SizedBox(height: 16),
                  buildTaskCard(
                    context: context,
                    task: Task(
                      totalSubtasks: 6,
                      completedSubtasks: 4,
                      title: 'Complete Math Homework',
                      description:
                          'Solve algebra, geometry and calculus problems.',
                      time: '10:30 AM',
                      status: TaskStatus.inProgress,
                      createdAt: DateTime(2025, 1, 5, 9, 50),
                      // Jan 5, 9:50 AM
                      startTime: DateTime(
                        2026,
                        1,
                        5,
                        10,
                        30,
                      ), // Jan 5, 10:30 AM
                    ),
                  ),
                  const SizedBox(height: 16),
                  buildTaskCard(
                    context: context,
                    task: Task(
                      // totalSubtasks: 5,
                      // completedSubtasks: 5,
                      title: 'Complete Math Homework',
                      description:
                          'Solve algebra, geometry and calculus problems.',
                      time: '10:30 AM',
                      status: TaskStatus.completed,
                      createdAt: DateTime(2024, 1, 5, 9, 50),
                      // Jan 5, 9:50 AM
                      startTime: DateTime(2024, 1, 5, 10, 30),
                      // Jan 5, 10:30 AM
                      completedTime: DateTime(
                        2024,
                        1,
                        7,
                        10,
                        50,
                      ), // Jan 7, 10:50 AM
                    ),
                  ),
                  const SizedBox(height: 16),
                  buildTaskCard(
                    context: context,
                    task: Task(
                      totalSubtasks: 5,
                      completedSubtasks: 5,
                      title: 'Complete Math Homework',
                      description:
                          'Solve algebra, geometry and calculus problems.',
                      time: '10:30 AM',
                      status: TaskStatus.completed,
                      createdAt: DateTime(2026, 1, 5, 9, 50),
                      startTime: DateTime(2026, 1, 5, 10, 30),
                      completedTime: DateTime(2026, 1, 7, 10, 50),
                      subtasks: [
                        // Add this list
                        SubTask(
                          title: 'Call with design team',
                          isCompleted: true,
                          duration: null,
                        ),
                        SubTask(
                          title: 'Client meeting',
                          isCompleted: false,
                          duration: '10 min',
                        ),
                        SubTask(
                          title: 'Team discuss',
                          isCompleted: false,
                          duration: '20 min',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
*/
import 'package:askfemi/individual_user/features/home/task_details/model/sub_task_model.dart';
import 'package:askfemi/individual_user/features/home/task_details/model/task_model.dart';
import 'package:askfemi/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../widget/build_task_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          /// Collapsible App Bar
          _buildSliverAppBar(),

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
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 80,
       floating: false,
      pinned: true,
      stretch: true,
      surfaceTintColor: Colors.transparent,
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16 ),
        background: Container(
          color: Colors.white,
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  foregroundImage: AssetImage(
                    "assets/images/dummy_user_image.png",
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Welcome back!',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 11,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    const Text(
                      'Hi, Rakibul',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Plus Jakarta Sans',
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10.0, bottom: 8),
              child: SvgPicture.asset(
                "assets/icons/notification.svg",
                fit: BoxFit.fitHeight,
                height: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyProgress() {
    return Card(
      color: AppColors.white,
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
                    backgroundColor: Colors.grey[200],
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
          color: AppColors.white,
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
                SizedBox(height: 16,)
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
            title: 'Call with design team',
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
            title: 'Call with design team',
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