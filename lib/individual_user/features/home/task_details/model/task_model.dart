// enum TaskStatus { pending, inProgress, completed }
//
// class Task {
//   final String title;
//   final String description;
//   final String time;
//   final int? totalSubtasks;
//   final int? completedSubtasks;
//   final TaskStatus status;
//   final DateTime createdAt;  // ADD THIS
//   final DateTime startTime;  // ADD THIS
//   final DateTime? completedTime;  // ADD THIS
//
//   Task({
//     required this.title,
//     required this.description,
//     required this.time,
//     this.totalSubtasks,
//     this.completedSubtasks,
//     required this.status,
//     required this.createdAt,  // ADD THIS
//     required this.startTime,  // ADD THIS
//     this.completedTime,  // ADD THIS
//   });
// }




///=====================
///task_model.dart
///=====================
import 'package:askfemi/individual_user/features/home/task_details/model/sub_task_model.dart';


enum TaskStatus { pending, inProgress, completed }

class Task {
  final String title;
  final String description;
  final String time;
  final int? totalSubtasks;
  final int? completedSubtasks;
  final TaskStatus status;
  final DateTime createdAt;
  final DateTime startTime;
  final DateTime? completedTime;
  final List<SubTask> subtasks; // Add this field

  Task({
    required this.title,
    required this.description,
    required this.time,
    this.totalSubtasks,
    this.completedSubtasks,
    required this.status,
    required this.createdAt,
    required this.startTime,
    this.completedTime,
    this.subtasks = const [], // Initialize with empty list
  });
}



