enum TaskStatus { pending, inProgress, completed }

class Task {
  final String title;
  final String description;
  final String time;
  final int? totalSubtasks;
  final int? completedSubtasks;
  final TaskStatus status;

  Task({
    required this.title,
    required this.description,
    required this.time,
    this.totalSubtasks,
    this.completedSubtasks,
    required this.status,
  });
}
