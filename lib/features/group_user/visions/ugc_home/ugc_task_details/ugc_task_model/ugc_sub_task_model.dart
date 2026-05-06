///=====================
/// subtask_model.dart
///=====================

class UgcSubTask {
  final String id;
  final String title;
  final bool isCompleted;
  final String? duration;
  final DateTime? completedAt;

  UgcSubTask({
    this.id = '',
    required this.title,
    this.isCompleted = false,
    this.duration,
    this.completedAt,
  });

  UgcSubTask copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    String? duration,
    DateTime? completedAt,
  }) {
    return UgcSubTask(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      duration: duration ?? this.duration,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}