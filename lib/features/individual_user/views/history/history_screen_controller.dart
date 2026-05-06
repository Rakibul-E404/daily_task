import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../utils/network/app_url.dart';
import '../../../../../utils/network/network_caller_dio.dart';
import '../../../../../utils/network/secure_storage_service.dart';
import '../home/task_details/model/sub_task_model.dart';
import '../home/task_details/model/task_model.dart';

class HistoryController extends GetxController {
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
  int _totalPages = 0;
  int _totalResults = 0;

  // Filters
  var selectedStatus = Rx<TaskStatus?>(null);
  var selectedFromDate = Rx<DateTime?>(null);
  var selectedToDate = Rx<DateTime?>(null);

  @override
  void onInit() {
    super.onInit();
    // Set default dates: From = 1st of current month, To = current date
    final now = DateTime.now();
    selectedFromDate.value = DateTime(now.year, now.month, 1);
    selectedToDate.value = now;
    fetchHistoryTasks();
  }

  // Fetch history tasks with pagination and filters
  Future<void> fetchHistoryTasks({bool refresh = false}) async {
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

      // Build URL with pagination
      String url = '${AppUrl.getUserIndividualTaskHistory}?page=$_currentPage&limit=$_limit';

      // Add date filters if selected (format: dd-MM-yyyy)
      if (selectedFromDate.value != null) {
        final fromDate = _formatDateForApi(selectedFromDate.value!);
        url += '&from=$fromDate';
      }

      if (selectedToDate.value != null) {
        final toDate = _formatDateForApi(selectedToDate.value!);
        url += '&to=$toDate';
      }

      // Add status filter if selected
      if (selectedStatus.value != null) {
        url += '&status=${_getStatusString(selectedStatus.value!)}';
      }

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
        final results = attributes?['results'];

        if (results != null && results is List) {
          final List<dynamic> tasksData = results;

          // Get pagination info
          _totalPages = attributes?['totalPages'] ?? 0;
          _totalResults = attributes?['totalResults'] ?? 0;

          // Check if we have more data
          if (_currentPage >= _totalPages || tasksData.length < _limit) {
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

          print('✅ Loaded ${newTasks.length} tasks, total: ${tasks.length}, page: $_currentPage/$_totalPages');
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
          errorMessage.value = response.errorMessage ?? 'Failed to load history';
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
      print('Error fetching history tasks: $e');
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
    await fetchHistoryTasks();
  }

  // Refresh tasks (pull to refresh)
  Future<void> refreshTasks() async {
    isRefreshing.value = true;
    _currentPage = 1;
    hasMoreData.value = true;
    await fetchHistoryTasks(refresh: true);
  }

  // Apply filters
  Future<void> applyFilters({
    TaskStatus? status,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    selectedStatus.value = status;
    selectedFromDate.value = fromDate;
    selectedToDate.value = toDate;

    // Reset pagination and fetch
    _currentPage = 1;
    hasMoreData.value = true;
    tasks.clear();
    await fetchHistoryTasks(refresh: true);
  }

  // Clear all filters
  Future<void> clearFilters() async {
    selectedStatus.value = null;
    final now = DateTime.now();
    selectedFromDate.value = DateTime(now.year, now.month, 1);
    selectedToDate.value = now;

    // Reset pagination and fetch
    _currentPage = 1;
    hasMoreData.value = true;
    tasks.clear();
    await fetchHistoryTasks(refresh: true);
  }

  // Reset to current date (today)
  Future<void> resetToCurrentDate() async {
    final now = DateTime.now();
    selectedFromDate.value = DateTime(now.year, now.month, now.day);
    selectedToDate.value = DateTime(now.year, now.month, now.day);

    // Reset pagination and fetch
    _currentPage = 1;
    hasMoreData.value = true;
    tasks.clear();
    await fetchHistoryTasks(refresh: true);
  }

  // Format date for API (dd-MM-yyyy)
  String _formatDateForApi(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day-$month-$year';
  }

  // Get status string for API
  String _getStatusString(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return 'pending';
      case TaskStatus.inProgress:
        return 'inProgress';
      case TaskStatus.completed:
        return 'completed';
    }
  }

  // Parse task from JSON
  Task _parseTaskFromJson(Map<String, dynamic> json) {
    // Parse status
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

    // Get subtask counts from subtaskProgress
    final subtaskProgress = json['subtaskProgress'];
    int totalSubtasks = subtaskProgress?['total'] ?? 0;
    int completedSubtasks = subtaskProgress?['completed'] ?? 0;

    // Parse dates
    DateTime createdAt = DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now();
    DateTime startTime = DateTime.tryParse(json['startTime'] ?? '') ?? DateTime.now();
    DateTime? completedTime = json['completedTime'] != null
        ? DateTime.tryParse(json['completedTime'])
        : null;

    // Format scheduled time - use startTime for display
    String formattedTime = _formatTimeOfDay(startTime);

    // Parse createdBy (for assigned tasks)
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
      totalSubtasks: totalSubtasks,
      completedSubtasks: completedSubtasks,
      status: status,
      createdAt: createdAt,
      startTime: startTime,
      completedTime: completedTime,
      subtasks: subtasks,
      taskType: json['taskType'] ?? 'personal',
      priority: json['priority'] ?? 'medium',
      dueDate: null,
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

  // Format time from DateTime to 12-hour format
  String _formatTimeOfDay(DateTime dateTime) {
    try {
      int hour = dateTime.hour;
      int minute = dateTime.minute;

      final period = hour >= 12 ? 'PM' : 'AM';
      int hour12 = hour % 12;
      if (hour12 == 0) hour12 = 12;

      final minuteStr = minute.toString().padLeft(2, '0');
      return '$hour12:$minuteStr $period';
    } catch (e) {
      return 'Not set';
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
    await fetchHistoryTasks(refresh: true);
  }
}