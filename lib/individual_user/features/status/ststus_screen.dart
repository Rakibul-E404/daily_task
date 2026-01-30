import 'package:askfemi/individual_user/features/home/task_details/model/sub_task_model.dart';
import 'package:askfemi/individual_user/features/home/task_details/model/task_model.dart';
import 'package:askfemi/utils/app_colors.dart';
import 'package:askfemi/widget/build_task_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class StatusScreen extends StatefulWidget {
  final TaskStatus? filterStatus; // null means show all

  const StatusScreen({
    super.key,
    this.filterStatus,
  });

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  late TaskStatus? selectedStatus;

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.filterStatus;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        automaticallyImplyLeading: false,
        title: const Text(
          'All Status History',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            fontFamily: 'Plus Jakarta Sans',
            color: Colors.black87,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: PopupMenuButton<TaskStatus?>(
              offset: const Offset(0, 48),
              splashRadius: 0.1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 8,
              color: Colors.white,
              surfaceTintColor: Colors.white,
              shadowColor: Colors.black.withOpacity(0.15),
              position: PopupMenuPosition.under,
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: null,
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      if (selectedStatus == null)
                        const Icon(Icons.check, size: 20, color: Colors.blue),
                      if (selectedStatus == null) const SizedBox(width: 8),
                      const Text(
                        'All Tasks',
                        style: TextStyle(
                          fontSize: 15,
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(height: 1),
                PopupMenuItem(
                  value: TaskStatus.pending,
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      if (selectedStatus == TaskStatus.pending)
                        const Icon(Icons.check, size: 20, color: Colors.blue),
                      if (selectedStatus == TaskStatus.pending)
                        const SizedBox(width: 8),
                      const Text(
                        'Pending',
                        style: TextStyle(
                          fontSize: 15,
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(height: 1),
                PopupMenuItem(
                  value: TaskStatus.inProgress,
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      if (selectedStatus == TaskStatus.inProgress)
                        const Icon(Icons.check, size: 20, color: Colors.blue),
                      if (selectedStatus == TaskStatus.inProgress)
                        const SizedBox(width: 8),
                      const Text(
                        'In Progress',
                        style: TextStyle(
                          fontSize: 15,
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(height: 1),
                PopupMenuItem(
                  value: TaskStatus.completed,
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      if (selectedStatus == TaskStatus.completed)
                        const Icon(Icons.check, size: 20, color: Colors.blue),
                      if (selectedStatus == TaskStatus.completed)
                        const SizedBox(width: 8),
                      const Text(
                        'Completed',
                        style: TextStyle(
                          fontSize: 15,
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                setState(() {
                  selectedStatus = value;
                });
              },
              child: SizedBox(
                width: 40,
                height: 40,
                child: Center(
                  child: SvgPicture.asset(
                    "assets/icons/filter_icon.svg", // Your filter icon
                    width: 24,
                    height: 24,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section title based on filter
            Text(
              _getSectionTitle(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Plus Jakarta Sans',
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // Task list
            Expanded(
              child: _buildTaskList(),
            ),
          ],
        ),
      ),
    );
  }

  String _getSectionTitle() {
    if (selectedStatus == null) return 'All tasks';

    switch (selectedStatus!) {
      case TaskStatus.pending:
        return 'Pending tasks';
      case TaskStatus.inProgress:
        return 'In Progress tasks';
      case TaskStatus.completed:
        return 'Completed tasks';
    }
  }

  Widget _buildTaskList() {
    final tasks = _getFilteredTasks();

    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'No tasks found',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Plus Jakarta Sans',
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: tasks.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return buildTaskCard(
          context: context,
          task: tasks[index],
        );
      },
    );
  }

  List<Task> _getFilteredTasks() {
    final allTasks = _getAllTasks();

    if (selectedStatus == null) {
      return allTasks;
    }

    return allTasks.where((task) => task.status == selectedStatus).toList();
  }

  // Mock data - Replace with your actual data source
  List<Task> _getAllTasks() {
    return [
      Task(
        title: 'Complete Math Homework',
        description: 'Solve algebra, geometry and calculus problems.',
        time: '10:30 AM',
        status: TaskStatus.completed,
        createdAt: DateTime(2026, 1, 30, 9, 50),
        startTime: DateTime(2026, 1, 30, 10, 30),
        completedTime: DateTime(2026, 1, 30, 12, 45),
        totalSubtasks: 5,
        completedSubtasks: 5,
        subtasks: [
          SubTask(
            title: 'Solve algebra problems',
            isCompleted: true,
            duration: null,
          ),
          SubTask(
            title: 'Complete geometry worksheet',
            isCompleted: true,
            duration: '30 min',
          ),
          SubTask(
            title: 'Study calculus',
            isCompleted: true,
            duration: '45 min',
          ),
          SubTask(
            title: 'Review all solutions',
            isCompleted: true,
            duration: '20 min',
          ),
          SubTask(
            title: 'Submit homework',
            isCompleted: true,
            duration: null,
          ),
        ],
      ),
      Task(
        title: 'Prepare Presentation',
        description: 'Create slides for tomorrow\'s meeting.',
        time: '2:00 PM',
        status: TaskStatus.inProgress,
        createdAt: DateTime(2026, 1, 30, 8, 0),
        startTime: DateTime(2026, 1, 30, 14, 0),
        totalSubtasks: 6,
        completedSubtasks: 3,
      ),
      Task(
        title: 'Team Meeting',
        description: 'Discuss project updates and next steps.',
        time: '3:30 PM',
        status: TaskStatus.pending,
        createdAt: DateTime(2026, 1, 30, 7, 30),
        startTime: DateTime(2026, 1, 30, 15, 30),
      ),
      Task(
        title: 'Code Review',
        description: 'Review pull requests from team members.',
        time: '11:00 AM',
        status: TaskStatus.completed,
        createdAt: DateTime(2026, 1, 29, 10, 0),
        startTime: DateTime(2026, 1, 29, 11, 0),
        completedTime: DateTime(2026, 1, 29, 12, 30),
        totalSubtasks: 3,
        completedSubtasks: 3,
      ),
      Task(
        title: 'Write Documentation',
        description: 'Update API documentation for new features.',
        time: '4:00 PM',
        status: TaskStatus.inProgress,
        createdAt: DateTime(2026, 1, 30, 9, 0),
        startTime: DateTime(2026, 1, 30, 16, 0),
        totalSubtasks: 4,
        completedSubtasks: 1,
      ),
      Task(
        title: 'Client Call',
        description: 'Discuss requirements for new project.',
        time: '1:00 PM',
        status: TaskStatus.pending,
        createdAt: DateTime(2026, 1, 30, 8, 30),
        startTime: DateTime(2026, 1, 30, 13, 0),
      ),
    ];
  }
}