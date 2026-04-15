import 'package:askfemi/features/individual_user/views/home/task_details/model/sub_task_model.dart';

enum TaskStatus { pending, inProgress, completed }

class Task {
  final String id;
  final String title;
  final String description;
  final String time;
  final int totalSubtasks;
  final int completedSubtasks;
  final TaskStatus status;
  final DateTime createdAt;
  final DateTime startTime;
  final DateTime? completedTime;
  final List<SubTask> subtasks;
  final String taskType;
  final String priority;
  final DateTime? dueDate;
  final Map<String, dynamic>? createdBy;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.totalSubtasks,
    required this.completedSubtasks,
    required this.status,
    required this.createdAt,
    required this.startTime,
    this.completedTime,
    this.subtasks = const [],
    this.taskType = 'personal',
    this.priority = 'medium',
    this.dueDate,
    this.createdBy,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? time,
    int? totalSubtasks,
    int? completedSubtasks,
    TaskStatus? status,
    DateTime? createdAt,
    DateTime? startTime,
    DateTime? completedTime,
    List<SubTask>? subtasks,
    String? taskType,
    String? priority,
    DateTime? dueDate,
    Map<String, dynamic>? createdBy,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      time: time ?? this.time,
      totalSubtasks: totalSubtasks ?? this.totalSubtasks,
      completedSubtasks: completedSubtasks ?? this.completedSubtasks,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      startTime: startTime ?? this.startTime,
      completedTime: completedTime ?? this.completedTime,
      subtasks: subtasks ?? this.subtasks,
      taskType: taskType ?? this.taskType,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}