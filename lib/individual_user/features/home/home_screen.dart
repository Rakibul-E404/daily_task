import 'package:askfemi/individual_user/features/home/task_details/task_model.dart';
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
                // Daily progress
                _buildDailyProgress(),
                const SizedBox(height: 32),

                // Your Tasks section
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
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
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
                      description: 'Solve algebra, geometry and calculus problems.',
                      time: '10:30 AM',
                      status: TaskStatus.pending,
                    ),
                  ),

                  const SizedBox(height: 16),
                  buildTaskCard(
                    context: context,
                      task: Task(
                        totalSubtasks: 6,
                        completedSubtasks: 2,
                        title: 'Complete Math Homework',
                        description: 'Solve algebra, geometry and calculus problems.',
                        time: '10:30 AM',
                        status: TaskStatus.inProgress,
                      ),
                      ),
                  const SizedBox(height: 16),
                  buildTaskCard(
                    context: context,
                    task: Task(
                      totalSubtasks: 6,
                      completedSubtasks: 4,
                      title: 'Complete Math Homework',
                      description: 'Solve algebra, geometry and calculus problems.',
                      time: '10:30 AM',
                      status: TaskStatus.inProgress,
                    ),
                  ),
                  const SizedBox(height: 16),
                  buildTaskCard(
                    context: context,
                    task: Task(
                      totalSubtasks: 5,
                      completedSubtasks: 5,
                      title: 'Complete Math Homework',
                      description: 'Solve algebra, geometry and calculus problems.',
                      time: '10:30 AM',
                      status: TaskStatus.completed,
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
