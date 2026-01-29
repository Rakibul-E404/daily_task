///=====================
/// subtask_model.dart
///=====================
class SubTask {
  final String title;
  final bool isCompleted;
  final String? duration; // Optional: e.g., "10 min", "20 min"

  SubTask({
    required this.title,
    this.isCompleted = false,
    this.duration,
  });
}