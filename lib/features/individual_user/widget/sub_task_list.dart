import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_texts_style.dart';
import '../views/home/task_details/model/sub_task_model.dart';
import '../views/home/task_details/model/task_model.dart';

// Make this a StatefulWidget to handle tap state
class SubTaskListWidget extends StatefulWidget {
  final Task task;

  const SubTaskListWidget({super.key, required this.task});

  @override
  State<SubTaskListWidget> createState() => _SubTaskListWidgetState();
}

class _SubTaskListWidgetState extends State<SubTaskListWidget> {
  late List<SubTask> subtasks;

  @override
  void initState() {
    super.initState();
    // Create a copy of subtasks to manage local state
    subtasks = List.from(widget.task.subtasks);
  }

  // Function to toggle subtask completion
  void _toggleSubTask(int index) {
    setState(() {
      // Create a new SubTask with toggled isCompleted
      subtasks[index] = SubTask(
        title: subtasks[index].title,
        isCompleted: !subtasks[index].isCompleted,
        duration: subtasks[index].duration,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (subtasks.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title with count - EXACTLY AS YOUR DESIGN
        Text(
          'Subtask items (${subtasks.length})',
          style: AppTextStyles.smallHeading.copyWith(),
        ),

        const SizedBox(height: 12),

        // Subtask list - each in separate card - EXACTLY AS YOUR DESIGN
        Column(
          children: subtasks.asMap().entries.map((entry) {
            final index = entry.key;
            final subtask = entry.value;

            return Card(
              color: AppColors.white,
              elevation: 1,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: AppColors.lightGrey,
                  width: 1,
                ),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Custom checkbox - NOW TAPABLE
                    /// Wrap with GestureDetector to make it tapable
                    GestureDetector(
                      onTap: () {
                        _toggleSubTask(index); // This will toggle the state
                      },
                      child: Transform.scale(
                        scale: 1,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: subtask.isCompleted
                                ? AppColors.textColorGreen
                                : AppColors.transparent,
                            border: Border.all(
                              color: subtask.isCompleted
                                  ? AppColors.textColorGreen
                                  : AppColors.primaryColor,
                              width: 1,
                            ),
                          ),
                          child: subtask.isCompleted
                              ? Icon(
                            Icons.check,
                            size: 14,
                            color: Colors.white,
                          )
                              : null,
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    /// ===================================
                    /// title -- duration -- delete icon
                    /// EXACTLY AS YOUR DESIGN
                    /// ===================================
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              subtask.title,
                              style: AppTextStyles.defaultTextStyle.copyWith(
                                color: subtask.isCompleted
                                    ? AppColors.grey
                                    : AppColors.black,
                                decoration: subtask.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              )
                          ),
                          SizedBox(width: 8,),
                          if (subtask.duration != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              subtask.duration!,
                              style: AppTextStyles.defaultTextStyle.copyWith(
                                  color: AppColors.grey
                              ),
                            ),
                          ],
                          Spacer(),
                          if(!subtask.isCompleted)
                            Icon(CupertinoIcons.trash, color: AppColors.grey, size: 20,)
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// If you want to keep the original function name, create a wrapper:
Widget subTaskList(Task task) {
  return SubTaskListWidget(task: task);
}