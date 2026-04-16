import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../utils/network/app_url.dart';
import '../../../../../utils/network/network_caller_dio.dart';
import '../../../../../utils/network/secure_storage_service.dart';
import '../../../widget/support_alert_cards.dart';
import 'model/sub_task_model.dart';
import 'model/task_model.dart';

class TaskDetailsScreenController extends GetxController {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();

  var task = Rx<Task?>(null);
  var isLoading = false.obs;
  var isUpdatingStatus = false.obs;
  var isDeleting = false.obs;
  var isTogglingSubtask = false.obs;
  var currentTogglingSubtaskIndex = (-1).obs;
  var errorMessage = RxString('');

  // Creative response data
  var creativeMode = RxString('');
  var creativeMilestone = RxString('');
  var creativePopupTitle = RxString('');
  var creativePopupMessage = RxString('');
  var creativePopupIcon = RxString('');
  var creativePopupButtonText = RxString('');
  var showCreativePopup = false.obs;
  var pendingAlertType = Rx<SupportAlertType?>(null);

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> fetchTaskDetails(String taskId) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final token = await SecureStorageService.instance.getAccessToken();

      if (token == null) {
        errorMessage.value = 'No access token found';
        print('No access token found');
        return;
      }

      final response = await _networkCaller.getRequest(
        AppUrl.getTaskDetails(taskId),
        headers: {'Authorization': 'Bearer $token'},
      );

      print('Response success: ${response.isSuccess}');
      print('Response status code: ${response.statusCode}');

      if (response.isSuccess && response.jsonResponse != null) {
        final attributes = response.jsonResponse?['data']?['attributes'];

        if (attributes != null) {
          final fetchedTask = _mapApiResponseToTask(attributes);
          task.value = fetchedTask;
          print('Task fetched successfully: ${fetchedTask.title}');
          print('Subtask count: ${fetchedTask.subtasks.length}');
          for (var st in fetchedTask.subtasks) {
            print('  Subtask - ID: ${st.id}, Title: ${st.title}');
          }
        } else {
          errorMessage.value = 'Task data not found';
        }
      } else {
        errorMessage.value = response.errorMessage ?? 'Failed to load task';
        print('API error: ${response.errorMessage}');
      }
    } on SocketException catch (e) {
      print('SocketException: $e');
      errorMessage.value = 'No internet connection. Please check your network.';
    } catch (e) {
      errorMessage.value = e.toString();
      print('Error fetching task details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleSubtaskStatus(String taskId, String subtaskId, bool isCompleted, int subtaskIndex) async {
    if (isTogglingSubtask.value) return;

    // ✅ Validate subtaskId
    if (subtaskId.isEmpty) {
      print('❌ Subtask ID is empty!');
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        const SnackBar(
          content: Text('Invalid subtask ID'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    isTogglingSubtask.value = true;
    currentTogglingSubtaskIndex.value = subtaskIndex;
    errorMessage.value = '';

    try {
      final token = await SecureStorageService.instance.getAccessToken();

      if (token == null) {
        errorMessage.value = 'No access token found';
        isTogglingSubtask.value = false;
        currentTogglingSubtaskIndex.value = -1;
        return;
      }

      final Map<String, dynamic> requestBody = {
        "isCompleted": isCompleted,
      };

      final url = AppUrl.updateSubTaskStatus(taskId, subtaskId);
      print('📤 Toggling subtask status');
      print('📤 URL: $url');
      print('📤 Subtask ID: $subtaskId');
      print('📤 Request body: $requestBody');

      final response = await _networkCaller.putRequest(
        url,
        body: requestBody,
        headers: {'Authorization': 'Bearer $token'},
      );

      print('📡 Response status code: ${response.statusCode}');
      print('📡 Response success: ${response.isSuccess}');

      if (response.isSuccess || response.statusCode == 200) {
        // Update local task data
        final currentTask = task.value;
        if (currentTask != null) {
          final updatedSubtasks = List<SubTask>.from(currentTask.subtasks);
          updatedSubtasks[subtaskIndex] = updatedSubtasks[subtaskIndex].copyWith(
            isCompleted: isCompleted,
          );

          int newCompletedCount = updatedSubtasks.where((s) => s.isCompleted).length;

          final updatedTask = currentTask.copyWith(
            subtasks: updatedSubtasks,
            completedSubtasks: newCompletedCount,
          );

          task.value = updatedTask;
        }

        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(
            content: Text(isCompleted ? 'Subtask completed!' : 'Subtask uncompleted'),
            duration: const Duration(seconds: 1),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        String error = response.errorMessage ?? 'Failed to update subtask';
        if (response.jsonResponse != null) {
          error = response.jsonResponse?['message'] ?? error;
        }
        errorMessage.value = error;
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(
            content: Text(error),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error toggling subtask status: $e');
      errorMessage.value = 'An error occurred. Please try again.';
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        const SnackBar(
          content: Text('An error occurred. Please try again.'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      isTogglingSubtask.value = false;
      currentTogglingSubtaskIndex.value = -1;
    }
  }

  Future<bool> updateTaskStatus(String taskId, String status) async {
    isUpdatingStatus.value = true;
    errorMessage.value = '';

    try {
      final token = await SecureStorageService.instance.getAccessToken();

      if (token == null) {
        errorMessage.value = 'No access token found';
        isUpdatingStatus.value = false;
        return false;
      }

      final Map<String, dynamic> requestBody = {
        "status": status,
      };

      print('📤 Updating task status to: $status');
      print('📤 Request body: $requestBody');

      final response = await _networkCaller.putRequest(
        AppUrl.taskStatusUpdate(taskId),
        body: requestBody,
        headers: {'Authorization': 'Bearer $token'},
      );

      print('📡 Response status code: ${response.statusCode}');
      print('📡 Response success: ${response.isSuccess}');

      if (response.isSuccess || response.statusCode == 200) {
        _parseCreativeResponse(response.jsonResponse);
        await fetchTaskDetails(taskId);
        isUpdatingStatus.value = false;
        return true;
      } else {
        String error = response.errorMessage ?? 'Failed to update task status';
        if (response.jsonResponse != null) {
          error = response.jsonResponse?['message'] ?? error;
        }
        errorMessage.value = error;
        isUpdatingStatus.value = false;
        return false;
      }
    } catch (e) {
      print('Error updating task status: $e');
      errorMessage.value = 'An error occurred. Please try again.';
      isUpdatingStatus.value = false;
      return false;
    }
  }

  Future<bool> deleteTask(String taskId) async {
    isDeleting.value = true;
    errorMessage.value = '';

    try {
      final token = await SecureStorageService.instance.getAccessToken();

      if (token == null) {
        errorMessage.value = 'No access token found';
        isDeleting.value = false;
        return false;
      }

      print('📤 Deleting task with ID: $taskId');

      final response = await _networkCaller.deleteRequest(
        AppUrl.deleteTask(taskId),
        headers: {'Authorization': 'Bearer $token'},
      );

      print('📡 Response status code: ${response.statusCode}');
      print('📡 Response success: ${response.isSuccess}');

      if (response.isSuccess || response.statusCode == 200) {
        isDeleting.value = false;
        return true;
      } else {
        String error = response.errorMessage ?? 'Failed to delete task';
        if (response.jsonResponse != null) {
          error = response.jsonResponse?['message'] ?? error;
        }
        errorMessage.value = error;
        isDeleting.value = false;
        return false;
      }
    } catch (e) {
      print('Error deleting task: $e');
      errorMessage.value = 'An error occurred. Please try again.';
      isDeleting.value = false;
      return false;
    }
  }

  void _parseCreativeResponse(Map<String, dynamic>? jsonResponse) {
    if (jsonResponse == null) return;

    try {
      final attributes = jsonResponse['data']?['attributes'];
      final creativeResponse = attributes?['creativeResponse'];

      if (creativeResponse != null) {
        creativeMode.value = creativeResponse['mode'] ?? '';
        creativeMilestone.value = creativeResponse['milestone'] ?? '';
        showCreativePopup.value = creativeResponse['showPopup'] ?? false;
        pendingAlertType.value = _getAlertTypeFromCreativeResponse();
      }
    } catch (e) {
      print('Error parsing creative response: $e');
    }
  }

  SupportAlertType? _getAlertTypeFromCreativeResponse() {
    final milestone = creativeMilestone.value;
    final mode = creativeMode.value;

    bool isCompleted = milestone == '100' || milestone == '100_percent' || milestone == 'completed';
    bool isHalfway = milestone == 'started' || milestone == '1/2' || milestone == 'halfway';

    if (isHalfway) {
      if (mode == 'calm') return SupportAlertType.calm50;
      if (mode == 'encouraging') return SupportAlertType.encouraging50;
      if (mode == 'logical') return SupportAlertType.logical50;
      return SupportAlertType.encouraging50;
    }

    if (isCompleted) {
      if (mode == 'calm') return SupportAlertType.calm100;
      if (mode == 'encouraging') return SupportAlertType.encouraging100;
      if (mode == 'logical') return SupportAlertType.logical100;
      return SupportAlertType.encouraging100;
    }

    return null;
  }

  void showSupportAlertIfNeeded(BuildContext context) {
    if (!showCreativePopup.value) return;

    final alertType = pendingAlertType.value;
    if (alertType == null) return;

    Future.delayed(const Duration(milliseconds: 300), () {
      if (context.mounted) {
        SupportAlertCards.show(
          context,
          type: alertType,
          onButtonTap: () {
            showCreativePopup.value = false;
            pendingAlertType.value = null;
          },
        );
      }
    });
  }

  Task _mapApiResponseToTask(Map<String, dynamic> json) {
    TaskStatus status = _parseTaskStatus(json['status'] ?? 'pending');

    List<SubTask> subtasks = [];
    if (json['subtasks'] != null && json['subtasks'] is List) {
      subtasks = (json['subtasks'] as List).map((subtaskJson) {
        return SubTask(
          id: subtaskJson['_id']?.toString() ?? '', // ✅ Extract subtask ID
          title: subtaskJson['title'] ?? '',
          isCompleted: subtaskJson['isCompleted'] ?? false,
          duration: subtaskJson['duration']?.toString(),
        );
      }).toList();
    }

    DateTime createdAt = DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now();
    DateTime startTime = DateTime.tryParse(json['startTime'] ?? '') ?? DateTime.now();
    DateTime? completedTime = json['completedTime'] != null
        ? DateTime.tryParse(json['completedTime'])
        : null;
    DateTime? dueDate = json['dueDate'] != null
        ? DateTime.tryParse(json['dueDate'])
        : null;

    String formattedTime = _formatTo12HourFormat(json['scheduledTime'] ?? '');

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

  String _formatTo12HourFormat(String time24) {
    if (time24.isEmpty) return 'Not set';
    try {
      if (time24.contains('AM') || time24.contains('PM')) return time24;
      final parts = time24.split(':');
      if (parts.length != 2) return time24;
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);
      final period = hour >= 12 ? 'PM' : 'AM';
      int hour12 = hour % 12;
      if (hour12 == 0) hour12 = 12;
      return '$hour12:${minute.toString().padLeft(2, '0')} $period';
    } catch (e) {
      return time24;
    }
  }
}