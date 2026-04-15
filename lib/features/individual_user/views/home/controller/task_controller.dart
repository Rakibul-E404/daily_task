import 'dart:io';
import 'package:get/get.dart';
import '../../../../../utils/network/app_url.dart';
import '../../../../../utils/network/network_caller_dio.dart';
import '../../../../../utils/network/secure_storage_service.dart';
import '../task_details/model/sub_task_model.dart';
import '../task_details/model/task_model.dart';

class TaskController extends GetxController {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();

  // Reactive variables
  var tasks = <Task>[].obs;
  var isLoading = false.obs;
  var isLoadingMore = false.obs;
  var isRefreshing = false.obs;
  var hasMoreData = true.obs;
  var errorMessage = RxString('');
  var isNetworkError = false.obs;
  var isServerError = false.obs;

  // Pagination
  int _currentPage = 1;
  static const int _limit = 10;

  // Daily progress
  var totalTasks = 0.obs;
  var completedTasks = 0.obs;
  var dailyProgress = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTasks();
  }

  // Fetch tasks with pagination
  Future<void> fetchTasks({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      hasMoreData.value = true;
      tasks.clear();
      isLoading.value = true;
    } else if (tasks.isEmpty) {
      isLoading.value = true;
    }

    errorMessage.value = '';
    isNetworkError.value = false;
    isServerError.value = false;

    try {
      final token = await SecureStorageService.instance.getAccessToken();

      if (token == null) {
        errorMessage.value = 'No access token found';
        isLoading.value = false;
        return;
      }

      final url = '${AppUrl.getHomeScreenTask}?page=$_currentPage&limit=$_limit';
      print('🌐 Making API request to: $url');

      final response = await _networkCaller.getRequest(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      print('📡 Response status code: ${response.statusCode}');
      print('📡 Response success: ${response.isSuccess}');

      if (response.isSuccess && response.jsonResponse != null) {
        isNetworkError.value = false;
        isServerError.value = false;

        final attributes = response.jsonResponse?['data']?['attributes'];

        if (attributes != null && attributes is List) {
          final List<dynamic> tasksData = attributes;

          // Check if we have more data
          if (tasksData.length < _limit) {
            hasMoreData.value = false;
          }

          // Parse tasks
          final List<Task> newTasks = tasksData.map((taskJson) {
            return _parseTaskFromJson(taskJson);
          }).toList();

          if (refresh) {
            tasks.value = newTasks;
          } else {
            tasks.addAll(newTasks);
          }

          // Update daily progress
          _updateDailyProgress();

          print('✅ Loaded ${newTasks.length} tasks, total: ${tasks.length}');
        } else {
          hasMoreData.value = false;
          if (tasks.isEmpty) {
            tasks.clear();
          }
        }
      } else {
        // Handle error status codes
        if (response.statusCode == 502 || response.statusCode == 503 ||
            response.statusCode == 504 || response.statusCode == 500) {
          isServerError.value = true;
          isNetworkError.value = true;
          errorMessage.value = _getUserFriendlyErrorMessage(null, statusCode: response.statusCode);
        } else {
          errorMessage.value = response.errorMessage ?? 'Failed to load tasks';
        }
        print('❌ API call failed: ${response.errorMessage}');

        if (tasks.isEmpty) {
          tasks.clear();
        }
      }
    } on SocketException catch (e) {
      print('SocketException: $e');
      isNetworkError.value = true;
      errorMessage.value = _getUserFriendlyErrorMessage(e);
      if (tasks.isEmpty) {
        tasks.clear();
      }
    } catch (e) {
      print('Error fetching tasks: $e');
      errorMessage.value = _getUserFriendlyErrorMessage(e);
      if (tasks.isEmpty) {
        tasks.clear();
      }
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
      isLoadingMore.value = false;
    }
  }

  // Load more tasks (pagination)
  Future<void> loadMoreTasks() async {
    if (!hasMoreData.value || isLoadingMore.value || isLoading.value) {
      return;
    }

    isLoadingMore.value = true;
    _currentPage++;
    await fetchTasks();
  }

  // Refresh tasks (pull to refresh)
  Future<void> refreshTasks() async {
    isRefreshing.value = true;
    _currentPage = 1;
    hasMoreData.value = true;
    await fetchTasks(refresh: true);
  }

  // Update daily progress based on tasks
  void _updateDailyProgress() {
    if (tasks.isEmpty) {
      totalTasks.value = 0;
      completedTasks.value = 0;
      dailyProgress.value = 0.0;
      return;
    }

    totalTasks.value = tasks.length;
    completedTasks.value = tasks.where((task) => task.status == TaskStatus.completed).length;

    if (totalTasks.value > 0) {
      dailyProgress.value = completedTasks.value / totalTasks.value;
    } else {
      dailyProgress.value = 0.0;
    }
  }

  // Get active tasks count (pending + inProgress)
  int getActiveTasksCount() {
    return tasks.where((task) =>
    task.status == TaskStatus.pending ||
        task.status == TaskStatus.inProgress
    ).length;
  }

  // Get completed tasks count
  int getCompletedTasksCount() {
    return tasks.where((task) => task.status == TaskStatus.completed).length;
  }

  // Parse task from JSON
  Task _parseTaskFromJson(Map<String, dynamic> json) {
    // Parse status - use the TaskStatus from task_model.dart
    TaskStatus status = _parseStatus(json['status'] ?? 'pending');

    // Parse subtasks
    List<SubTask> subtasks = [];
    if (json['subtasks'] != null && json['subtasks'] is List) {
      subtasks = (json['subtasks'] as List).map((subtaskJson) {
        return SubTask(
          title: subtaskJson['title'] ?? '',
          isCompleted: subtaskJson['isCompleted'] ?? false,
          duration: subtaskJson['duration']?.toString(),
        );
      }).toList();
    }

    // Parse dates
    DateTime createdAt = DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now();
    DateTime startTime = DateTime.tryParse(json['startTime'] ?? '') ?? DateTime.now();
    DateTime? completedTime = json['completedTime'] != null
        ? DateTime.tryParse(json['completedTime'])
        : null;
    DateTime? dueDate = json['dueDate'] != null
        ? DateTime.tryParse(json['dueDate'])
        : null;

    // Format scheduled time to 12-hour format
    String formattedTime = _formatTo12HourFormat(json['scheduledTime'] ?? '');

    // Parse createdBy
    Map<String, dynamic>? createdBy;
    if (json['createdById'] != null) {
      createdBy = {
        'id': json['createdById']['_id'] ?? '',
        'name': json['createdById']['name'] ?? '',
        'profileImage': json['createdById']['profileImage']?['imageUrl'] ?? '',
      };
    }

    return Task(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      time: formattedTime,
      totalSubtasks: json['totalSubtasks'] ?? 0,
      completedSubtasks: json['completedSubtasks'] ?? 0,
      status: status,
      createdAt: createdAt,
      startTime: startTime,
      completedTime: completedTime,
      subtasks: subtasks,
      taskType: json['taskType'] ?? 'personal',
      priority: json['priority'] ?? 'medium',
      dueDate: dueDate,
      createdBy: createdBy,
    );
  }

  // Parse status string to TaskStatus enum
  TaskStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return TaskStatus.pending;
      case 'inprogress':
      case 'in_progress':
      case 'in-progress':
        return TaskStatus.inProgress;
      case 'completed':
        return TaskStatus.completed;
      default:
        return TaskStatus.pending;
    }
  }

  // Format time to 12-hour format
  String _formatTo12HourFormat(String time24) {
    if (time24.isEmpty) return 'Not set';

    try {
      // Check if time already contains AM/PM
      if (time24.contains('AM') || time24.contains('PM')) {
        return time24;
      }

      final parts = time24.split(':');
      if (parts.length != 2) return time24;

      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);

      final period = hour >= 12 ? 'PM' : 'AM';
      int hour12 = hour % 12;
      if (hour12 == 0) hour12 = 12;

      final minuteStr = minute.toString().padLeft(2, '0');
      return '$hour12:$minuteStr $period';
    } catch (e) {
      return time24;
    }
  }

  // Get user-friendly error message
  String _getUserFriendlyErrorMessage(dynamic error, {int? statusCode}) {
    if (statusCode == 502 || statusCode == 503 || statusCode == 504) {
      return 'Server is temporarily unavailable. Please try again later.';
    }
    if (statusCode == 500) {
      return 'Server error. Please try again later.';
    }
    if (statusCode == 404) {
      return 'Service not found. Please contact support.';
    }
    if (statusCode == 403) {
      return 'Access denied. Please check your permissions.';
    }
    if (statusCode == 401) {
      return 'Session expired. Please login again.';
    }

    if (error.toString().contains('Failed host lookup') ||
        error.toString().contains('SocketException') ||
        error.toString().contains('No address associated with hostname')) {
      return 'Unable to connect to the server. Please check your internet connection.';
    }

    if (error.toString().contains('Connection refused') ||
        error.toString().contains('Connection timed out')) {
      return 'Connection timeout. Please check your internet connection.';
    }

    if (error.toString().contains('Network is unreachable')) {
      return 'No internet connection. Please check your network settings.';
    }

    return 'An error occurred. Please try again later.';
  }

  // Retry fetching tasks
  Future<void> retryFetch() async {
    isNetworkError.value = false;
    isServerError.value = false;
    errorMessage.value = '';
    _currentPage = 1;
    hasMoreData.value = true;
    await fetchTasks(refresh: true);
  }
}