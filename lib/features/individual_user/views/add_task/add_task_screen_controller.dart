import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../utils/network/app_url.dart';
import '../../../../../utils/network/network_caller_dio.dart';
import '../../../../../utils/network/secure_storage_service.dart';
import '../home/task_details/model/sub_task_model.dart';
import '../home/task_details/model/task_model.dart';

class AddTaskScreenController extends GetxController {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();

  // Reactive variables
  var isLoading = false.obs;
  var isSuccess = false.obs;
  var errorMessage = RxString('');
  var createdTask = Rx<Task?>(null);

  // Form data
  var title = ''.obs;
  var description = ''.obs;
  var startTime = Rx<DateTime?>(null);
  var dueDate = Rx<DateTime?>(null);
  var scheduledTime = ''.obs;
  var subtasks = <SubTask>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Set default start time to now
    if (startTime.value == null) {
      startTime.value = DateTime.now();
    }
    // Set default due date to end of today
    if (dueDate.value == null) {
      final now = DateTime.now();
      dueDate.value = DateTime(now.year, now.month, now.day, 23, 59, 59);
    }
  }

  // Update title
  void updateTitle(String value) {
    title.value = value;
  }

  // Update description
  void updateDescription(String value) {
    description.value = value;
  }



  // Update start time
  void updateStartTime(DateTime dateTime) {
    startTime.value = dateTime;
    // Update scheduled time format
    scheduledTime.value = _formatTo12HourFormat(dateTime);
  }

  // Update due date
  void updateDueDate(DateTime dateTime) {
    dueDate.value = dateTime;
  }

  // Add subtask
  void addSubtask(SubTask subtask) {
    subtasks.add(subtask);
  }

  // Remove subtask at index
  void removeSubtaskAt(int index) {
    subtasks.removeAt(index);
  }

  // Update subtask at index
  void updateSubtaskAt(int index, SubTask subtask) {
    subtasks[index] = subtask;
  }

  // Clear all subtasks
  void clearSubtasks() {
    subtasks.clear();
  }

  // Create personal task
  Future<bool> createPersonalTask() async {
    // Validate required fields
    if (title.value.isEmpty) {
      errorMessage.value = 'Please enter task title';
      Get.snackbar(
        'Error',
        'Please enter task title',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    if (startTime.value == null) {
      errorMessage.value = 'Please select start time';
      Get.snackbar(
        'Error',
        'Please select start time',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    if (dueDate.value == null) {
      errorMessage.value = 'Please select due date';
      Get.snackbar(
        'Error',
        'Please select due date',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final token = await SecureStorageService.instance.getAccessToken();

      if (token == null) {
        errorMessage.value = 'No access token found';
        isLoading.value = false;
        Get.snackbar(
          'Error',
          'No access token found. Please login again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }

      // Prepare request body
      final Map<String, dynamic> requestBody = {
        "title": title.value.trim(),
        "description": description.value.trim(),
        "taskType": "personal",
        "startTime": _formatDateTimeForApi(startTime.value!),
        "scheduledTime": _formatTo12HourFormat(startTime.value!),
        "dueDate": _formatDateTimeForApi(dueDate.value!),
      };

      // Add subtasks if any
      if (subtasks.isNotEmpty) {
        final List<Map<String, dynamic>> subtasksList = [];
        for (int i = 0; i < subtasks.length; i++) {
          final subtask = subtasks[i];
          if (subtask.title.trim().isNotEmpty) {
            subtasksList.add({
              "title": subtask.title.trim(),
              "order": i + 1,
            });
          }
        }
        if (subtasksList.isNotEmpty) {
          requestBody["subtasks"] = subtasksList;
        }
      }

      print('🌐 Making POST request to: ${AppUrl.createPersonalTask}');
      print('📦 Request body: $requestBody');

      final response = await _networkCaller.postRequest(
        AppUrl.createPersonalTask,
        // requestBody,
        headers: {'Authorization': 'Bearer $token'},
      );

      print('📡 Response status code: ${response.statusCode}');
      print('📡 Response success: ${response.isSuccess}');

      if (response.isSuccess && response.jsonResponse != null) {
        final attributes = response.jsonResponse?['data']?['attributes'];
        final taskData = attributes?['task'];

        if (taskData != null) {
          // Parse the created task
          final task = _parseCreatedTask(taskData);
          createdTask.value = task;

          isSuccess.value = true;

          Get.snackbar(
            'Success',
            'Task created successfully!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );

          return true;
        } else {
          errorMessage.value = 'Failed to parse task data';
          return false;
        }
      } else {
        errorMessage.value = response.errorMessage ?? 'Failed to create task';
        Get.snackbar(
          'Error',
          errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } on SocketException catch (e) {
      print('SocketException: $e');
      errorMessage.value = 'No internet connection. Please check your network.';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } catch (e) {
      print('Error creating task: $e');
      errorMessage.value = 'An error occurred. Please try again.';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Reset form data
  void resetForm() {
    title.value = '';
    description.value = '';
    startTime.value = DateTime.now();
    final now = DateTime.now();
    dueDate.value = DateTime(now.year, now.month, now.day, 23, 59, 59);
    scheduledTime.value = '';
    subtasks.clear();
    errorMessage.value = '';
    isSuccess.value = false;
    createdTask.value = null;
  }

  // Parse created task from API response
  Task _parseCreatedTask(Map<String, dynamic> taskData) {
    // Parse status
    TaskStatus status = _parseTaskStatus(taskData['status'] ?? 'pending');

    // Parse subtasks
    List<SubTask> subtasksList = [];
    if (taskData['subtasks'] != null && taskData['subtasks'] is List) {
      subtasksList = (taskData['subtasks'] as List).map((subtaskJson) {
        return SubTask(
          title: subtaskJson['title'] ?? '',
          isCompleted: subtaskJson['isCompleted'] ?? false,
          duration: subtaskJson['duration']?.toString(),
        );
      }).toList();
    }

    // Parse dates
    DateTime createdAt = DateTime.tryParse(taskData['createdAt'] ?? '') ?? DateTime.now();
    DateTime startTimeTask = DateTime.tryParse(taskData['startTime'] ?? '') ?? DateTime.now();
    DateTime? completedTime = taskData['completedTime'] != null
        ? DateTime.tryParse(taskData['completedTime'])
        : null;
    DateTime? dueDateTask = taskData['dueDate'] != null
        ? DateTime.tryParse(taskData['dueDate'])
        : null;

    // Format scheduled time
    String formattedTime = taskData['scheduledTime'] ?? _formatTo12HourFormat(startTimeTask);

    return Task(
      id: taskData['id'] ?? taskData['_taskId'] ?? '',
      title: taskData['title'] ?? '',
      description: taskData['description'] ?? '',
      time: formattedTime,
      totalSubtasks: taskData['totalSubtasks'] ?? 0,
      completedSubtasks: taskData['completedSubtasks'] ?? 0,
      status: status,
      createdAt: createdAt,
      startTime: startTimeTask,
      completedTime: completedTime,
      subtasks: subtasksList,
      taskType: taskData['taskType'] ?? 'personal',
      dueDate: dueDateTask,
      createdBy: null,
    );
  }

  // Parse status string to TaskStatus enum
  TaskStatus _parseTaskStatus(String status) {
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

  // Format DateTime to API format (ISO 8601)
  String _formatDateTimeForApi(DateTime dateTime) {
    return dateTime.toUtc().toIso8601String();
  }

  // Format time to 12-hour format
  String _formatTo12HourFormat(DateTime dateTime) {
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

}