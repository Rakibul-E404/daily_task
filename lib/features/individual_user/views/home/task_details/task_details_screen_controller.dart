/**
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

  // ✅ Creative response data (same as UGC)
  var creativeMode = RxString('');
  var creativeMilestone = RxString('');
  var creativePopupTitle = RxString('');
  var creativePopupMessage = RxString('');
  var creativePopupIcon = RxString('');
  var creativePopupButtonText = RxString('');
  var showCreativePopup = false.obs;
  var pendingAlertType = Rx<SupportAlertType?>(null);

  // ✅ Milestone tracking flags — reset on each fresh fetch
  bool _shown50Milestone = false;
  bool _shown100Milestone = false;

  // ✅ Store previous status for fallback logic
  TaskStatus? _previousStatus;

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> fetchTaskDetails(String taskId) async {
    isLoading.value = true;
    errorMessage.value = '';

    // ✅ Reset milestone flags on every fresh fetch
    _shown50Milestone = false;
    _shown100Milestone = false;

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

  // ✅ Silent refresh — updates task data without showing any loading indicator
  Future<void> _silentRefreshTaskDetails(String taskId) async {
    try {
      final token = await SecureStorageService.instance.getAccessToken();
      if (token == null) return;

      final response = await _networkCaller.getRequest(
        AppUrl.getTaskDetails(taskId),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.isSuccess && response.jsonResponse != null) {
        final attributes = response.jsonResponse?['data']?['attributes'];
        if (attributes != null) {
          final fetchedTask = _mapApiResponseToTask(attributes);
          // ✅ Preserve milestone flags — do NOT reset them here
          task.value = fetchedTask;
          print('✅ Silent refresh done: ${fetchedTask.title}');
        }
      }
    } catch (e) {
      print('Silent refresh error: $e');
    }
  }

  // ✅ Toggle subtask status with silent refresh + milestone check
  Future<void> toggleSubtaskStatus(
      String taskId,
      String subtaskId,
      bool isCompleted,
      int subtaskIndex,
      ) async {
    if (isTogglingSubtask.value) return;

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

      final Map<String, dynamic> requestBody = {"isCompleted": isCompleted};

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
        // ✅ Optimistically update local state immediately (no flicker)
        final currentTask = task.value;
        if (currentTask != null) {
          final updatedSubtasks = List<SubTask>.from(currentTask.subtasks);
          updatedSubtasks[subtaskIndex] = updatedSubtasks[subtaskIndex].copyWith(
            isCompleted: isCompleted,
          );

          final int newCompletedCount =
              updatedSubtasks.where((s) => s.isCompleted).length;
          final int totalCount = updatedSubtasks.length;

          final updatedTask = currentTask.copyWith(
            subtasks: updatedSubtasks,
            completedSubtasks: newCompletedCount,
          );

          task.value = updatedTask;

          // ✅ Silent refresh from server (no loading spinner shown)
          await _silentRefreshTaskDetails(taskId);

          // ✅ Check milestone only when marking as completed (not unchecking)
          if (isCompleted) {
            _checkSubtaskMilestone(
              context: Get.context!,
              completedCount: newCompletedCount,
              totalCount: totalCount,
            );
          }
        }
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

  // ✅ Check subtask completion milestone and show support card
  void _checkSubtaskMilestone({
    required BuildContext context,
    required int completedCount,
    required int totalCount,
  }) {
    if (totalCount == 0) return;

    print(
      '📊 Subtask milestone check: $completedCount/$totalCount = ${(completedCount / totalCount * 100).toStringAsFixed(0)}%',
    );

    SupportAlertType? alertType;

    // ✅ 50% milestone
    if (completedCount == (totalCount / 2).ceil() && !_shown50Milestone) {
      _shown50Milestone = true;
      final mode = creativeMode.value.isNotEmpty ? creativeMode.value : 'encouraging';
      alertType = _getAlertTypeForMilestone('50_percent', mode);
      print('🎯 50% milestone reached! Mode: $mode → Alert: $alertType');
    }

    // ✅ 100% milestone
    else if (completedCount == totalCount && !_shown100Milestone) {
      _shown100Milestone = true;
      final mode = creativeMode.value.isNotEmpty ? creativeMode.value : 'encouraging';
      alertType = _getAlertTypeForMilestone('100_percent', mode);
      print('🎯 100% milestone reached! Mode: $mode → Alert: $alertType');
    }

    if (alertType != null) {
      pendingAlertType.value = alertType;
      showCreativePopup.value = true;

      Future.delayed(const Duration(milliseconds: 400), () {
        if (context.mounted) {
          SupportAlertCards.show(
            context,
            type: alertType!,
            onButtonTap: () {
              showCreativePopup.value = false;
              pendingAlertType.value = null;
            },
          );
        }
      });
    }
  }

  // ✅ Maps milestone string + mode → correct SupportAlertType
  SupportAlertType _getAlertTypeForMilestone(String milestone, String mode) {
    final bool isHalf = milestone == '50_percent';
    switch (mode) {
      case 'calm':
        return isHalf ? SupportAlertType.calm50 : SupportAlertType.calm100;
      case 'logical':
        return isHalf ? SupportAlertType.logical50 : SupportAlertType.logical100;
      case 'encouraging':
      default:
        return isHalf ? SupportAlertType.encouraging50 : SupportAlertType.encouraging100;
    }
  }

  // ✅ Called from screen after bulk auto-complete via Complete button
  void checkMilestoneAfterBulkComplete(BuildContext context, Task currentTask) {
    final int completedCount = currentTask.subtasks.where((s) => s.isCompleted).length;
    final int totalCount = currentTask.subtasks.length;

    _checkSubtaskMilestone(
      context: context,
      completedCount: completedCount,
      totalCount: totalCount,
    );
  }

  // ✅ Update task status with creative response parsing (same as UGC)
  Future<bool> updateTaskStatus(String taskId, String status) async {
    isUpdatingStatus.value = true;
    errorMessage.value = '';

    _previousStatus = task.value?.status; // Store for fallback

    try {
      final token = await SecureStorageService.instance.getAccessToken();

      if (token == null) {
        errorMessage.value = 'No access token found';
        isUpdatingStatus.value = false;
        return false;
      }

      final Map<String, dynamic> requestBody = {"status": status};

      print('📤 Updating task status to: $status');
      print('📤 Request body: $requestBody');

      final url = '${AppUrl.baseUrl}/tasks/$taskId/status';
      print('📤 URL: $url');

      final response = await _networkCaller.putRequest(
        url,
        body: requestBody,
        headers: {'Authorization': 'Bearer $token'},
      );

      print('📡 Response status code: ${response.statusCode}');
      print('📡 Response success: ${response.isSuccess}');

      if (response.isSuccess || response.statusCode == 200) {
        // ✅ Parse creative response (same logic as UGC)
        final hasCreativeResponse = _parseCreativeResponse(response.jsonResponse);
        await fetchTaskDetails(taskId);
        isUpdatingStatus.value = false;

        // ✅ Fallback alert if no creative response from API
        if (!hasCreativeResponse && _previousStatus != null) {
          _createFallbackAlert(status);
        }

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

  // ✅ Fallback alert creation (same as UGC)
  void _createFallbackAlert(String newStatus) {
    print('🔄 Creating fallback alert for status: $newStatus');

    SupportAlertType? alertType;

    if (newStatus == 'inProgress') {
      alertType = SupportAlertType.encouraging50;
    } else if (newStatus == 'completed') {
      alertType = SupportAlertType.encouraging100;
    }

    if (alertType != null) {
      pendingAlertType.value = alertType;
      showCreativePopup.value = true;
      print('✅ Fallback alert created: $alertType');
    }
  }

  // ✅ Parse creative response (FULL version - same as UGC)
  bool _parseCreativeResponse(Map<String, dynamic>? jsonResponse) {
    if (jsonResponse == null) {
      print('❌ No JSON response to parse');
      return false;
    }

    try {
      print('📦 Full JSON Response: $jsonResponse');

      final attributes = jsonResponse['data']?['attributes'];
      print('📦 Attributes: $attributes');

      final creativeResponse = attributes?['creativeResponse'];
      print('📦 Creative Response: $creativeResponse');

      if (creativeResponse != null) {
        creativeMode.value = creativeResponse['mode'] ?? '';
        creativeMilestone.value = creativeResponse['milestone'] ?? '';

        final popup = creativeResponse['popup'];
        if (popup != null) {
          creativePopupTitle.value = popup['title'] ?? '';
          creativePopupMessage.value = popup['message'] ?? '';
          creativePopupIcon.value = popup['icon'] ?? '';
          creativePopupButtonText.value = popup['buttonText'] ?? 'Continue';
          showCreativePopup.value = creativeResponse['showPopup'] ?? false;

          print('🎉 Creative Response - Mode: ${creativeMode.value}, Milestone: ${creativeMilestone.value}');
          print('📱 Show Popup: ${showCreativePopup.value}');

          pendingAlertType.value = _getAlertTypeFromCreativeResponse();
          print('🎯 Pending Alert Type: ${pendingAlertType.value}');

          return true;
        } else {
          print('❌ No popup data in creative response');
          return false;
        }
      } else {
        print('❌ No creativeResponse in attributes');
        return false;
      }
    } catch (e) {
      print('Error parsing creative response: $e');
      return false;
    }
  }

  // ✅ Get alert type from creative response (same as UGC)
  SupportAlertType? _getAlertTypeFromCreativeResponse() {
    final milestone = creativeMilestone.value;
    final mode = creativeMode.value;

    print('🔍 Determining alert type - Milestone: $milestone, Mode: $mode');

    bool isHalfway = milestone == '1/2' ||
        milestone == 'halfway' ||
        milestone == 'started' ||
        milestone == '50_percent' ||
        milestone == '50%';

    bool isCompleted = milestone == '100' ||
        milestone == '100_percent' ||
        milestone == 'completed' ||
        milestone == 'done' ||
        milestone == '100%';

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

    print('⚠️ No matching alert type found for milestone: $milestone, mode: $mode');
    return null;
  }

  // ✅ Show support alert if needed (same as UGC)
  void showSupportAlertIfNeeded(BuildContext context) {
    print('🔔 showSupportAlertIfNeeded called');
    print('📱 showCreativePopup.value: ${showCreativePopup.value}');
    print('🎯 pendingAlertType.value: ${pendingAlertType.value}');

    if (!showCreativePopup.value) {
      print('❌ showCreativePopup is false, skipping alert');
      return;
    }

    final alertType = pendingAlertType.value;
    if (alertType == null) {
      print('❌ No alert type determined');
      return;
    }

    print('✅ Showing support alert: $alertType');

    Future.delayed(const Duration(milliseconds: 300), () {
      if (context.mounted) {
        SupportAlertCards.show(
          context,
          type: alertType,
          onButtonTap: () {
            print('Alert button tapped');
            showCreativePopup.value = false;
            pendingAlertType.value = null;
          },
        );
      } else {
        print('❌ Context is not mounted');
      }
    });
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

  Task _mapApiResponseToTask(Map<String, dynamic> json) {
    TaskStatus status = _parseTaskStatus(json['status'] ?? 'pending');

    List<SubTask> subtasks = [];
    if (json['subtasks'] != null && json['subtasks'] is List) {
      subtasks = (json['subtasks'] as List).map((subtaskJson) {
        return SubTask(
          id: subtaskJson['_id']?.toString() ?? '',
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
    DateTime? dueDate = json['dueDate'] != null ? DateTime.tryParse(json['dueDate']) : null;

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
}*/









///
///
///
/// todo:: passing the seart time with 'start' button
///
///
///
///





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

  // Creative response data (same as UGC)
  var creativeMode = RxString('');
  var creativeMilestone = RxString('');
  var creativePopupTitle = RxString('');
  var creativePopupMessage = RxString('');
  var creativePopupIcon = RxString('');
  var creativePopupButtonText = RxString('');
  var showCreativePopup = false.obs;
  var pendingAlertType = Rx<SupportAlertType?>(null);

  // Milestone tracking flags — reset on each fresh fetch
  bool _shown50Milestone = false;
  bool _shown100Milestone = false;

  // Store previous status for fallback logic
  TaskStatus? _previousStatus;

  @override
  void onInit() {
    super.onInit();
  }

  // Helper method to format DateTime without 'Z' and milliseconds
  String _formatDateTimeWithoutZ(DateTime dateTime) {
    final year = dateTime.year.toString().padLeft(4, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final second = dateTime.second.toString().padLeft(2, '0');

    // Format: YYYY-MM-DDTHH:MM:SS (no space, no Z)
    return '$year-$month-${day}T$hour:$minute:$second';
  }

  Future<void> fetchTaskDetails(String taskId) async {
    isLoading.value = true;
    errorMessage.value = '';

    // Reset milestone flags on every fresh fetch
    _shown50Milestone = false;
    _shown100Milestone = false;

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

  // Silent refresh — updates task data without showing any loading indicator
  Future<void> _silentRefreshTaskDetails(String taskId) async {
    try {
      final token = await SecureStorageService.instance.getAccessToken();
      if (token == null) return;

      final response = await _networkCaller.getRequest(
        AppUrl.getTaskDetails(taskId),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.isSuccess && response.jsonResponse != null) {
        final attributes = response.jsonResponse?['data']?['attributes'];
        if (attributes != null) {
          final fetchedTask = _mapApiResponseToTask(attributes);
          // Preserve milestone flags — do NOT reset them here
          task.value = fetchedTask;
          print('✅ Silent refresh done: ${fetchedTask.title}');
        }
      }
    } catch (e) {
      print('Silent refresh error: $e');
    }
  }

  // Toggle subtask status with silent refresh + milestone check
  Future<void> toggleSubtaskStatus(
      String taskId,
      String subtaskId,
      bool isCompleted,
      int subtaskIndex,
      ) async {
    if (isTogglingSubtask.value) return;

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

      final Map<String, dynamic> requestBody = {"isCompleted": isCompleted};

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
        // Optimistically update local state immediately (no flicker)
        final currentTask = task.value;
        if (currentTask != null) {
          final updatedSubtasks = List<SubTask>.from(currentTask.subtasks);
          updatedSubtasks[subtaskIndex] = updatedSubtasks[subtaskIndex].copyWith(
            isCompleted: isCompleted,
          );

          final int newCompletedCount =
              updatedSubtasks.where((s) => s.isCompleted).length;
          final int totalCount = updatedSubtasks.length;

          final updatedTask = currentTask.copyWith(
            subtasks: updatedSubtasks,
            completedSubtasks: newCompletedCount,
          );

          task.value = updatedTask;

          // Silent refresh from server (no loading spinner shown)
          await _silentRefreshTaskDetails(taskId);

          // Check milestone only when marking as completed (not unchecking)
          if (isCompleted) {
            _checkSubtaskMilestone(
              context: Get.context!,
              completedCount: newCompletedCount,
              totalCount: totalCount,
            );
          }
        }
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

  // Check subtask completion milestone and show support card
  void _checkSubtaskMilestone({
    required BuildContext context,
    required int completedCount,
    required int totalCount,
  }) {
    if (totalCount == 0) return;

    print(
      '📊 Subtask milestone check: $completedCount/$totalCount = ${(completedCount / totalCount * 100).toStringAsFixed(0)}%',
    );

    SupportAlertType? alertType;

    // 50% milestone
    if (completedCount == (totalCount / 2).ceil() && !_shown50Milestone) {
      _shown50Milestone = true;
      final mode = creativeMode.value.isNotEmpty ? creativeMode.value : 'encouraging';
      alertType = _getAlertTypeForMilestone('50_percent', mode);
      print('🎯 50% milestone reached! Mode: $mode → Alert: $alertType');
    }

    // 100% milestone
    else if (completedCount == totalCount && !_shown100Milestone) {
      _shown100Milestone = true;
      final mode = creativeMode.value.isNotEmpty ? creativeMode.value : 'encouraging';
      alertType = _getAlertTypeForMilestone('100_percent', mode);
      print('🎯 100% milestone reached! Mode: $mode → Alert: $alertType');
    }

    if (alertType != null) {
      pendingAlertType.value = alertType;
      showCreativePopup.value = true;

      Future.delayed(const Duration(milliseconds: 400), () {
        if (context.mounted) {
          SupportAlertCards.show(
            context,
            type: alertType!,
            onButtonTap: () {
              showCreativePopup.value = false;
              pendingAlertType.value = null;
            },
          );
        }
      });
    }
  }

  // Maps milestone string + mode → correct SupportAlertType
  SupportAlertType _getAlertTypeForMilestone(String milestone, String mode) {
    final bool isHalf = milestone == '50_percent';
    switch (mode) {
      case 'calm':
        return isHalf ? SupportAlertType.calm50 : SupportAlertType.calm100;
      case 'logical':
        return isHalf ? SupportAlertType.logical50 : SupportAlertType.logical100;
      case 'encouraging':
      default:
        return isHalf ? SupportAlertType.encouraging50 : SupportAlertType.encouraging100;
    }
  }

  // Called from screen after bulk auto-complete via Complete button
  void checkMilestoneAfterBulkComplete(BuildContext context, Task currentTask) {
    final int completedCount = currentTask.subtasks.where((s) => s.isCompleted).length;
    final int totalCount = currentTask.subtasks.length;

    _checkSubtaskMilestone(
      context: context,
      completedCount: completedCount,
      totalCount: totalCount,
    );
  }

  // Update task status with startTime support
  Future<bool> updateTaskStatus(String taskId, String status, {DateTime? startTime}) async {
    isUpdatingStatus.value = true;
    errorMessage.value = '';

    _previousStatus = task.value?.status; // Store for fallback

    try {
      final token = await SecureStorageService.instance.getAccessToken();

      if (token == null) {
        errorMessage.value = 'No access token found';
        isUpdatingStatus.value = false;
        return false;
      }

      final Map<String, dynamic> requestBody = {"status": status};

      // ✅ Add startTime only when starting a task (status = 'inProgress')
      if (status == 'inProgress' && startTime != null) {
        final formattedStartTime = _formatDateTimeWithoutZ(startTime);
        requestBody["startTime"] = formattedStartTime;
        print('📤 Start Time: $formattedStartTime');
      }

      print('📤 Updating task status to: $status');
      print('📤 Request body: $requestBody');

      final url = '${AppUrl.baseUrl}/tasks/$taskId/status';
      print('📤 URL: $url');

      final response = await _networkCaller.putRequest(
        url,
        body: requestBody,
        headers: {'Authorization': 'Bearer $token'},
      );

      print('📡 Response status code: ${response.statusCode}');
      print('📡 Response success: ${response.isSuccess}');

      if (response.isSuccess || response.statusCode == 200) {
        // Parse creative response (same logic as UGC)
        final hasCreativeResponse = _parseCreativeResponse(response.jsonResponse);
        await fetchTaskDetails(taskId);
        isUpdatingStatus.value = false;

        // Fallback alert if no creative response from API
        if (!hasCreativeResponse && _previousStatus != null) {
          _createFallbackAlert(status);
        }

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

  // Fallback alert creation (same as UGC)
  void _createFallbackAlert(String newStatus) {
    print('🔄 Creating fallback alert for status: $newStatus');

    SupportAlertType? alertType;

    if (newStatus == 'inProgress') {
      alertType = SupportAlertType.encouraging50;
    } else if (newStatus == 'completed') {
      alertType = SupportAlertType.encouraging100;
    }

    if (alertType != null) {
      pendingAlertType.value = alertType;
      showCreativePopup.value = true;
      print('✅ Fallback alert created: $alertType');
    }
  }

  // Parse creative response (FULL version - same as UGC)
  bool _parseCreativeResponse(Map<String, dynamic>? jsonResponse) {
    if (jsonResponse == null) {
      print('❌ No JSON response to parse');
      return false;
    }

    try {
      print('📦 Full JSON Response: $jsonResponse');

      final attributes = jsonResponse['data']?['attributes'];
      print('📦 Attributes: $attributes');

      final creativeResponse = attributes?['creativeResponse'];
      print('📦 Creative Response: $creativeResponse');

      if (creativeResponse != null) {
        creativeMode.value = creativeResponse['mode'] ?? '';
        creativeMilestone.value = creativeResponse['milestone'] ?? '';

        final popup = creativeResponse['popup'];
        if (popup != null) {
          creativePopupTitle.value = popup['title'] ?? '';
          creativePopupMessage.value = popup['message'] ?? '';
          creativePopupIcon.value = popup['icon'] ?? '';
          creativePopupButtonText.value = popup['buttonText'] ?? 'Continue';
          showCreativePopup.value = creativeResponse['showPopup'] ?? false;

          print('🎉 Creative Response - Mode: ${creativeMode.value}, Milestone: ${creativeMilestone.value}');
          print('📱 Show Popup: ${showCreativePopup.value}');

          pendingAlertType.value = _getAlertTypeFromCreativeResponse();
          print('🎯 Pending Alert Type: ${pendingAlertType.value}');

          return true;
        } else {
          print('❌ No popup data in creative response');
          return false;
        }
      } else {
        print('❌ No creativeResponse in attributes');
        return false;
      }
    } catch (e) {
      print('Error parsing creative response: $e');
      return false;
    }
  }

  // Get alert type from creative response (same as UGC)
  SupportAlertType? _getAlertTypeFromCreativeResponse() {
    final milestone = creativeMilestone.value;
    final mode = creativeMode.value;

    print('🔍 Determining alert type - Milestone: $milestone, Mode: $mode');

    bool isHalfway = milestone == '1/2' ||
        milestone == 'halfway' ||
        milestone == 'started' ||
        milestone == '50_percent' ||
        milestone == '50%';

    bool isCompleted = milestone == '100' ||
        milestone == '100_percent' ||
        milestone == 'completed' ||
        milestone == 'done' ||
        milestone == '100%';

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

    print('⚠️ No matching alert type found for milestone: $milestone, mode: $mode');
    return null;
  }

  // Show support alert if needed (same as UGC)
  void showSupportAlertIfNeeded(BuildContext context) {
    print('🔔 showSupportAlertIfNeeded called');
    print('📱 showCreativePopup.value: ${showCreativePopup.value}');
    print('🎯 pendingAlertType.value: ${pendingAlertType.value}');

    if (!showCreativePopup.value) {
      print('❌ showCreativePopup is false, skipping alert');
      return;
    }

    final alertType = pendingAlertType.value;
    if (alertType == null) {
      print('❌ No alert type determined');
      return;
    }

    print('✅ Showing support alert: $alertType');

    Future.delayed(const Duration(milliseconds: 300), () {
      if (context.mounted) {
        SupportAlertCards.show(
          context,
          type: alertType,
          onButtonTap: () {
            print('Alert button tapped');
            showCreativePopup.value = false;
            pendingAlertType.value = null;
          },
        );
      } else {
        print('❌ Context is not mounted');
      }
    });
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

  Task _mapApiResponseToTask(Map<String, dynamic> json) {
    TaskStatus status = _parseTaskStatus(json['status'] ?? 'pending');

    List<SubTask> subtasks = [];
    if (json['subtasks'] != null && json['subtasks'] is List) {
      subtasks = (json['subtasks'] as List).map((subtaskJson) {
        return SubTask(
          id: subtaskJson['_id']?.toString() ?? '',
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
    DateTime? dueDate = json['dueDate'] != null ? DateTime.tryParse(json['dueDate']) : null;

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