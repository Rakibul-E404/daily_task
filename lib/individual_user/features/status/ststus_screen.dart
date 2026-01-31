import 'package:askfemi/individual_user/features/home/task_details/model/sub_task_model.dart';
import 'package:askfemi/individual_user/features/home/task_details/model/task_model.dart';
import 'package:askfemi/utils/app_colors.dart';
import 'package:askfemi/widget/build_task_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StatusScreen extends StatefulWidget {
  final TaskStatus? filterStatus; // null means show all

  const StatusScreen({super.key, this.filterStatus});

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
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.white,
        automaticallyImplyLeading: false,
        title: const Text(
          'Task History',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            fontFamily: 'Plus Jakarta Sans',
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(CupertinoIcons.calendar_today),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 16,left: 16, right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task list
            Expanded(child: _buildTaskList()),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList() {
    final tasks = _getFilteredTasks();

    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task_alt, size: 64, color: Colors.grey[300]),
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
        return buildTaskCard(context: context, task: tasks[index]);
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
          SubTask(title: 'Submit homework', isCompleted: true, duration: null),
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
