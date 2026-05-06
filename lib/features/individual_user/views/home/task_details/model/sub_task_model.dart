/**
///=====================
/// subtask_model.dart
///=====================

class SubTask {
  final String id;
  final String title;
  final bool isCompleted;
  final String? duration;

  SubTask({
    this.id,
    required this.title,
    this.isCompleted = false,
    this.duration,
  });

  SubTask copyWith({
    String? title,
    bool? isCompleted,
    String? duration,
  }) {
    return SubTask(
      id: title ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      duration: duration ?? this.duration,
    );
  }
}*/










class SubTask {
  final String? id;  // ✅ Make it nullable instead of default empty string
  final String title;
  final bool isCompleted;
  final String? duration;

  SubTask({
    this.id,  // ✅ No default value, can be null
    required this.title,
    this.isCompleted = false,
    this.duration,
  });

  SubTask copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    String? duration,
  }) {
    return SubTask(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      duration: duration ?? this.duration,
    );
  }
}