import 'package:askfemi/utils/app_colors.dart';
import 'package:askfemi/widget/dotted_border_container.dart';
import 'package:dashed_line/dashed_line.dart';
import 'package:flutter/material.dart';
import 'package:askfemi/individual_user/features/home/task_details/task_model.dart';

class TaskDetailsScreen extends StatelessWidget {
  final Task task;
  const TaskDetailsScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.status == TaskStatus.completed;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(task.title),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Card(
            elevation: 0,
            color: AppColors.lightBlueColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.circular(12),
            side: BorderSide(
              color: AppColors.lightGrey,
              width: 1.5
            )),
            child: IconButton(
              icon: Icon(Icons.more_horiz,color: AppColors.primaryColor,),
              onPressed: () {},
            ),
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔹 Status Card (without timestamps)
              dottedBorderContainer(
                color: AppColors.primaryColor,
                dashWidth: 5,
                borderRadius: 12,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Status',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          _buildStatusBadge(task.status),
                        ],
                      ),Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Status',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          _buildStatusBadge(task.status),
                        ],
                      ),
                    ],
                  ),
                ),
              ),



              const SizedBox(height: 24),

              /// 🔹 Task Title
              Text('Task Title', style: TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 6),
              Text(
                task.title,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              /// 🔹 Description
              Text('Description', style: TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 6),
              Text(
                task.description,
                style: TextStyle(fontSize: 16, height: 1.5),
              ),

              const SizedBox(height: 20),

              // 🔹 Subtasks Progress
              if (task.totalSubtasks != null && task.completedSubtasks != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Subtasks: ${task.completedSubtasks} / ${task.totalSubtasks}',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: task.totalSubtasks! > 0
                          ? task.completedSubtasks! / task.totalSubtasks!
                          : 0,
                      backgroundColor: Colors.grey[200],
                      color: Colors.blue,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),

              const SizedBox(height: 20),

              // 🔹 Add Subtask Input
              TextField(
                decoration: InputDecoration(
                  hintText: 'Add a subtask...',
                  filled: true,
                  fillColor: Colors.grey[50],
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),

              ),

              const SizedBox(height: 16),

              /// 🔹 Add Task Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.add, size: 18, color: AppColors.black),
                  label: Text('Add Task',
                      style: TextStyle(color: AppColors.black, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFEEF5FF),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              /// 🔹 Completed Button (only if pending/in progress)
              if (!isCompleted)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Handle completion logic
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text('Completed',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusBorderColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return Color(0xFFD1E7FF);
      case TaskStatus.inProgress:
        return Color(0xFFE0E7FF);
      case TaskStatus.completed:
        return Color(0xFFD1F7E0);
    }
  }

  Widget _buildStatusBadge(TaskStatus status) {
    final label = status.name; // or map to custom string if needed
    final bgColor = _getStatusBorderColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label.capitalize(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.blue[800],
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