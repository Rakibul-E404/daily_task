/**
import 'package:askfemi/features/group_user/visions/ugc_home/ugc_task_details/ugc_task_model/ugc_sub_task_model.dart';
import 'package:askfemi/features/group_user/visions/ugc_home/ugc_task_details/ugc_task_model/ugc_task_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../utils/network/app_url.dart';
import '../../../../../utils/network/network_caller_dio.dart';
import '../../../../../utils/network/secure_storage_service.dart';
import '../../../../individual_user/widget/support_alert_cards.dart';

class UgcTaskDetailsController extends GetxController {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();

  var task = Rx<UgcTask?>(null);
  var isLoading = false.obs;
  var isUpdatingStatus = false.obs;
  var isDeleting = false.obs;
  var errorMessage = RxString('');

  // Subtask toggle loading states
  var isTogglingSubtask = false.obs;
  var currentTogglingSubtaskIndex = (-1).obs;

  // Creative response data
  var creativeMode = RxString('');
  var creativeMilestone = RxString('');
  var creativePopupTitle = RxString('');
  var creativePopupMessage = RxString('');
  var creativePopupIcon = RxString('');
  var creativePopupButtonText = RxString('');
  var showCreativePopup = false.obs;

  // Store the alert type to show
  var pendingAlertType = Rx<SupportAlertType?>(null);

  // Store the previous status to detect milestone
  TaskStatus? _previousStatus;

  // ✅ Milestone tracking flags — reset on each task fetch
  bool _shown50Milestone = false;
  bool _shown100Milestone = false;

  @override
  void onInit() {
    super.onInit();
    _getTaskIdAndFetch();
  }

  void _getTaskIdAndFetch() {
    final arguments = Get.arguments;

    if (arguments == null) {
      errorMessage.value = 'No task ID provided';
      print('Error: No arguments passed to UgcTaskDetailsScreen');
      return;
    }

    String? taskId;

    if (arguments is String) {
      taskId = arguments;
    } else if (arguments is Map) {
      taskId = arguments['taskId'] as String?;
    }

    if (taskId == null || taskId.isEmpty) {
      errorMessage.value = 'Invalid task ID';
      print('Error: Invalid task ID: $taskId');
      return;
    }

    print('Fetching task details for ID: $taskId');
    fetchTaskDetails(taskId);
  }

  // ✅ Called from screen after bulk auto-complete via Complete button
  void checkMilestoneAfterBulkComplete(BuildContext context, UgcTask currentTask) {
    final int completedCount =
        currentTask.subtasks.where((s) => s.isCompleted).length;
    final int totalCount = currentTask.subtasks.length;

    _checkSubtaskMilestone(
      context: context,
      completedCount: completedCount,
      totalCount: totalCount,
    );
  }



  Future<void> fetchTaskDetails(String taskId) async {
    isLoading.value = true;
    errorMessage.value = '';

    // ✅ Reset milestone flags on every fresh initial fetch
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
        AppUrl.getUgcTaskDetails(taskId),
        headers: {'Authorization': 'Bearer $token'},
      );

      print('Response success: ${response.isSuccess}');
      print('Response status code: ${response.statusCode}');

      if (response.isSuccess && response.jsonResponse != null) {
        final attributes = response.jsonResponse?['data']?['attributes'];

        if (attributes != null) {
          final fetchedTask = _mapApiResponseToUgcTask(attributes);
          task.value = fetchedTask;
          print('Task fetched successfully: ${fetchedTask.title}');
        } else {
          errorMessage.value = 'Task data not found';
        }
      } else {
        errorMessage.value = response.errorMessage ?? 'Failed to load task';
        print('API error: ${response.errorMessage}');
      }
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
        AppUrl.getUgcTaskDetails(taskId),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.isSuccess && response.jsonResponse != null) {
        final attributes = response.jsonResponse?['data']?['attributes'];
        if (attributes != null) {
          final fetchedTask = _mapApiResponseToUgcTask(attributes);

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

    isTogglingSubtask.value = true;
    currentTogglingSubtaskIndex.value = subtaskIndex;
    errorMessage.value = '';

    try {
      final token = await SecureStorageService.instance.getAccessToken();

      if (token == null) {
        errorMessage.value = 'No access token found';
        print('No access token found');
        isTogglingSubtask.value = false;
        currentTogglingSubtaskIndex.value = -1;
        return;
      }

      final Map<String, dynamic> requestBody = {"isCompleted": isCompleted};

      final url = AppUrl.updateSubTaskStatus(taskId, subtaskId);
      print('📤 Toggling subtask status');
      print('📤 URL: $url');
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
          final updatedSubtasks = List<UgcSubTask>.from(currentTask.subtasks);
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

    // ✅ 50% milestone — triggers when exactly half are done
    if (completedCount == (totalCount / 2).ceil() && !_shown50Milestone) {
      _shown50Milestone = true;
      final mode =
      creativeMode.value.isNotEmpty ? creativeMode.value : 'encouraging';
      alertType = _getAlertTypeForMilestone('50_percent', mode);
      print('🎯 50% milestone reached! Mode: $mode → Alert: $alertType');
    }

    // ✅ 100% milestone — triggers when ALL subtasks are done
    else if (completedCount == totalCount && !_shown100Milestone) {
      _shown100Milestone = true;
      final mode =
      creativeMode.value.isNotEmpty ? creativeMode.value : 'encouraging';
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
        return isHalf
            ? SupportAlertType.encouraging50
            : SupportAlertType.encouraging100;
    }
  }

  // Update task status for non-personal tasks (collaborative/singleAssignment)
  Future<bool> updateTaskStatus(String taskId, String status) async {
    isUpdatingStatus.value = true;
    errorMessage.value = '';

    _previousStatus = task.value?.status;

    try {
      final token = await SecureStorageService.instance.getAccessToken();

      if (token == null) {
        errorMessage.value = 'No access token found';
        print('No access token found');
        isUpdatingStatus.value = false;
        return false;
      }

      final Map<String, dynamic> requestBody = {"status": status};

      print('📤 Updating task status to: $status (Non-personal task)');
      print('📤 Request body: $requestBody');

      final response = await _networkCaller.putRequest(
        AppUrl.ugcTaskStatusUpdate(taskId),
        body: requestBody,
        headers: {'Authorization': 'Bearer $token'},
      );

      print('📡 Response status code: ${response.statusCode}');
      print('📡 Response success: ${response.isSuccess}');
      print('📡 Response body: ${response.jsonResponse}');

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

  // Update task status for personal tasks
  Future<bool> updatePersonalTaskStatus(String taskId, String status) async {
    isUpdatingStatus.value = true;
    errorMessage.value = '';

    _previousStatus = task.value?.status;

    try {
      final token = await SecureStorageService.instance.getAccessToken();

      if (token == null) {
        errorMessage.value = 'No access token found';
        print('No access token found');
        isUpdatingStatus.value = false;
        return false;
      }

      final Map<String, dynamic> requestBody = {"status": status};

      print('📤 Updating personal task status to: $status');
      print('📤 Request body: $requestBody');

      final response = await _networkCaller.putRequest(
        AppUrl.ugcPersonalTaskStatusUpdate(taskId),
        body: requestBody,
        headers: {'Authorization': 'Bearer $token'},
      );

      print('📡 Response status code: ${response.statusCode}');
      print('📡 Response success: ${response.isSuccess}');
      print('📡 Response body: ${response.jsonResponse}');

      if (response.isSuccess || response.statusCode == 200) {
        final hasCreativeResponse = _parseCreativeResponse(response.jsonResponse);
        await fetchTaskDetails(taskId);
        isUpdatingStatus.value = false;

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
      print('Error updating personal task status: $e');
      errorMessage.value = 'An error occurred. Please try again.';
      isUpdatingStatus.value = false;
      return false;
    }
  }

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
        print('No access token found');
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
      print('📡 Response body: ${response.jsonResponse}');

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

  UgcTask _mapApiResponseToUgcTask(Map<String, dynamic> json) {
    TaskStatus taskStatus;
    final status = json['status']?.toString().toLowerCase() ?? 'pending';
    switch (status) {
      case 'completed':
        taskStatus = TaskStatus.completed;
        break;
      case 'inprogress':
        taskStatus = TaskStatus.inProgress;
        break;
      default:
        taskStatus = TaskStatus.pending;
    }

    final List<UgcSubTask> ugcSubtasks = [];
    final subtasksList = json['subtasks'] as List?;
    if (subtasksList != null) {
      for (var subtaskJson in subtasksList) {
        final isCompleted = subtaskJson['isCompleted'] ?? false;

        ugcSubtasks.add(
          UgcSubTask(
            id: subtaskJson['_id'] ?? '',
            title: subtaskJson['title'] ?? '',
            isCompleted: isCompleted,
            duration: subtaskJson['duration']?.toString(),
            completedAt: subtaskJson['completedAt'] != null
                ? DateTime.tryParse(subtaskJson['completedAt'])
                : null,
          ),
        );
      }
    }

    String? assignedBy;
    String? assignedByImage;
    final taskType = json['taskType']?.toString() ?? 'personal';
    final createdBy = json['createdById'];

    if (taskType == 'personal') {
      assignedBy = null;
      assignedByImage = null;
    } else if (createdBy != null && createdBy['name'] != null) {
      assignedBy = createdBy['name'];
      final profileImage = createdBy['profileImage'];
      if (profileImage != null && profileImage['imageUrl'] != null) {
        assignedByImage = _getImageUrl(profileImage['imageUrl']);
      }
    }

    List<String>? groupMembers;
    if (taskType == 'collaborative') {
      final assignedUsers = json['assignedUserIds'] as List?;
      if (assignedUsers != null && assignedUsers.isNotEmpty) {
        groupMembers = [];
        for (var user in assignedUsers) {
          final profileImage = user['profileImage'];
          String imageUrl = "assets/images/dummy_user_image.png";
          if (profileImage != null && profileImage['imageUrl'] != null) {
            imageUrl = _getImageUrl(profileImage['imageUrl']);
          }
          groupMembers.add(imageUrl);
        }
      }
    }

    DateTime createdAt = DateTime.now();
    if (json['createdAt'] != null) {
      createdAt = DateTime.tryParse(json['createdAt']) ?? DateTime.now();
    }

    DateTime startTime = DateTime.now();
    if (json['startTime'] != null) {
      startTime = DateTime.tryParse(json['startTime']) ?? DateTime.now();
    }

    DateTime? completedTime;
    if (json['completedTime'] != null) {
      completedTime = DateTime.tryParse(json['completedTime']);
    }

    DateTime dueDate = DateTime.now();
    if (json['dueDate'] != null) {
      dueDate = DateTime.tryParse(json['dueDate']) ?? DateTime.now();
    }

    final subtaskProgress = json['subtaskProgress'] ?? {};
    final totalSubtasks =
        subtaskProgress['total'] ?? json['totalSubtasks'] ?? 0;
    final completedSubtasks =
        subtaskProgress['completed'] ?? json['completedSubtasks'] ?? 0;

    return UgcTask(
      id: json['_id'] ?? '',
      taskType: taskType,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      time: json['scheduledTime'] ?? '',
      totalSubtasks: totalSubtasks,
      completedSubtasks: completedSubtasks,
      status: taskStatus,
      createdAt: createdAt,
      startTime: startTime,
      completedTime: completedTime,
      dueDate: dueDate,
      priority: json['priority'] ?? 'medium',
      subtasks: ugcSubtasks,
      assignedBy: assignedBy,
      assignedByImage: assignedByImage,
      groupMembers: groupMembers,
    );
  }

  String _getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return "";
    if (imagePath.startsWith('http')) return imagePath;

    String cleanPath = imagePath;
    if (cleanPath.startsWith('/')) {
      cleanPath = cleanPath.substring(1);
    }
    return '${AppUrl.imageBaseUrl}/$cleanPath';
  }
}*/








///
///
///
///
/// todo:: passing start time data
///
///
///



import 'package:askfemi/features/group_user/visions/ugc_home/ugc_task_details/ugc_task_model/ugc_sub_task_model.dart';
import 'package:askfemi/features/group_user/visions/ugc_home/ugc_task_details/ugc_task_model/ugc_task_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../utils/network/app_url.dart';
import '../../../../../utils/network/network_caller_dio.dart';
import '../../../../../utils/network/secure_storage_service.dart';
import '../../../../individual_user/widget/support_alert_cards.dart';

class UgcTaskDetailsController extends GetxController {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();

  var task = Rx<UgcTask?>(null);
  var isLoading = false.obs;
  var isUpdatingStatus = false.obs;
  var isDeleting = false.obs;
  var errorMessage = RxString('');

  // Subtask toggle loading states
  var isTogglingSubtask = false.obs;
  var currentTogglingSubtaskIndex = (-1).obs;

  // Creative response data
  var creativeMode = RxString('');
  var creativeMilestone = RxString('');
  var creativePopupTitle = RxString('');
  var creativePopupMessage = RxString('');
  var creativePopupIcon = RxString('');
  var creativePopupButtonText = RxString('');
  var showCreativePopup = false.obs;

  // Store the alert type to show
  var pendingAlertType = Rx<SupportAlertType?>(null);

  // Store the previous status to detect milestone
  TaskStatus? _previousStatus;

  // Milestone tracking flags — reset on each task fetch
  bool _shown50Milestone = false;
  bool _shown100Milestone = false;

  @override
  void onInit() {
    super.onInit();
    _getTaskIdAndFetch();
  }

  void _getTaskIdAndFetch() {
    final arguments = Get.arguments;

    if (arguments == null) {
      errorMessage.value = 'No task ID provided';
      print('Error: No arguments passed to UgcTaskDetailsScreen');
      return;
    }

    String? taskId;

    if (arguments is String) {
      taskId = arguments;
    } else if (arguments is Map) {
      taskId = arguments['taskId'] as String?;
    }

    if (taskId == null || taskId.isEmpty) {
      errorMessage.value = 'Invalid task ID';
      print('Error: Invalid task ID: $taskId');
      return;
    }

    print('Fetching task details for ID: $taskId');
    fetchTaskDetails(taskId);
  }

  // Called from screen after bulk auto-complete via Complete button
  void checkMilestoneAfterBulkComplete(BuildContext context, UgcTask currentTask) {
    final int completedCount =
        currentTask.subtasks.where((s) => s.isCompleted).length;
    final int totalCount = currentTask.subtasks.length;

    _checkSubtaskMilestone(
      context: context,
      completedCount: completedCount,
      totalCount: totalCount,
    );
  }

  Future<void> fetchTaskDetails(String taskId) async {
    isLoading.value = true;
    errorMessage.value = '';

    // Reset milestone flags on every fresh initial fetch
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
        AppUrl.getUgcTaskDetails(taskId),
        headers: {'Authorization': 'Bearer $token'},
      );

      print('Response success: ${response.isSuccess}');
      print('Response status code: ${response.statusCode}');

      if (response.isSuccess && response.jsonResponse != null) {
        final attributes = response.jsonResponse?['data']?['attributes'];

        if (attributes != null) {
          final fetchedTask = _mapApiResponseToUgcTask(attributes);
          task.value = fetchedTask;
          print('Task fetched successfully: ${fetchedTask.title}');
        } else {
          errorMessage.value = 'Task data not found';
        }
      } else {
        errorMessage.value = response.errorMessage ?? 'Failed to load task';
        print('API error: ${response.errorMessage}');
      }
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
        AppUrl.getUgcTaskDetails(taskId),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.isSuccess && response.jsonResponse != null) {
        final attributes = response.jsonResponse?['data']?['attributes'];
        if (attributes != null) {
          final fetchedTask = _mapApiResponseToUgcTask(attributes);

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

    isTogglingSubtask.value = true;
    currentTogglingSubtaskIndex.value = subtaskIndex;
    errorMessage.value = '';

    try {
      final token = await SecureStorageService.instance.getAccessToken();

      if (token == null) {
        errorMessage.value = 'No access token found';
        print('No access token found');
        isTogglingSubtask.value = false;
        currentTogglingSubtaskIndex.value = -1;
        return;
      }

      final Map<String, dynamic> requestBody = {"isCompleted": isCompleted};

      final url = AppUrl.updateSubTaskStatus(taskId, subtaskId);
      print('📤 Toggling subtask status');
      print('📤 URL: $url');
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
          final updatedSubtasks = List<UgcSubTask>.from(currentTask.subtasks);
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

    // 50% milestone — triggers when exactly half are done
    if (completedCount == (totalCount / 2).ceil() && !_shown50Milestone) {
      _shown50Milestone = true;
      final mode =
      creativeMode.value.isNotEmpty ? creativeMode.value : 'encouraging';
      alertType = _getAlertTypeForMilestone('50_percent', mode);
      print('🎯 50% milestone reached! Mode: $mode → Alert: $alertType');
    }

    // 100% milestone — triggers when ALL subtasks are done
    else if (completedCount == totalCount && !_shown100Milestone) {
      _shown100Milestone = true;
      final mode =
      creativeMode.value.isNotEmpty ? creativeMode.value : 'encouraging';
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
        return isHalf
            ? SupportAlertType.encouraging50
            : SupportAlertType.encouraging100;
    }
  }

  // ✅ UPDATED: Update task status for non-personal tasks with startTime
  Future<bool> updateTaskStatus(String taskId, String status) async {
    isUpdatingStatus.value = true;
    errorMessage.value = '';

    _previousStatus = task.value?.status;

    try {
      final token = await SecureStorageService.instance.getAccessToken();

      if (token == null) {
        errorMessage.value = 'No access token found';
        print('No access token found');
        isUpdatingStatus.value = false;
        return false;
      }

      final Map<String, dynamic> requestBody = {"status": status};

      // For 'inProgress' status, add startTime (without Z at the end)
      if (status == 'inProgress') {
        final now = DateTime.now();
        // Format: YYYY-MM-DDTHH:MM:SS (without Z)
        final formattedStartTime = _formatDateTimeWithoutZ(now);
        requestBody["startTime"] = formattedStartTime;
        print('📤 Adding startTime: $formattedStartTime');
      }

      print('📤 Updating task status to: $status (Non-personal task)');
      print('📤 Request body: $requestBody');

      final response = await _networkCaller.putRequest(
        AppUrl.ugcTaskStatusUpdate(taskId),
        body: requestBody,
        headers: {'Authorization': 'Bearer $token'},
      );

      print('📡 Response status code: ${response.statusCode}');
      print('📡 Response success: ${response.isSuccess}');
      print('📡 Response body: ${response.jsonResponse}');

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

  // ✅ UPDATED: Update task status for personal tasks with startTime
  Future<bool> updatePersonalTaskStatus(String taskId, String status) async {
    isUpdatingStatus.value = true;
    errorMessage.value = '';

    _previousStatus = task.value?.status;

    try {
      final token = await SecureStorageService.instance.getAccessToken();

      if (token == null) {
        errorMessage.value = 'No access token found';
        print('No access token found');
        isUpdatingStatus.value = false;
        return false;
      }

      final Map<String, dynamic> requestBody = {"status": status};

      // For 'inProgress' status, add startTime (without Z at the end)
      if (status == 'inProgress') {
        final now = DateTime.now();
        // Format: YYYY-MM-DDTHH:MM:SS (without Z)
        final formattedStartTime = _formatDateTimeWithoutZ(now);
        requestBody["startTime"] = formattedStartTime;
        print('📤 Adding startTime: $formattedStartTime');
      }

      print('📤 Updating personal task status to: $status');
      print('📤 Request body: $requestBody');

      final response = await _networkCaller.putRequest(
        AppUrl.ugcPersonalTaskStatusUpdate(taskId),
        body: requestBody,
        headers: {'Authorization': 'Bearer $token'},
      );

      print('📡 Response status code: ${response.statusCode}');
      print('📡 Response success: ${response.isSuccess}');
      print('📡 Response body: ${response.jsonResponse}');

      if (response.isSuccess || response.statusCode == 200) {
        final hasCreativeResponse = _parseCreativeResponse(response.jsonResponse);
        await fetchTaskDetails(taskId);
        isUpdatingStatus.value = false;

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
      print('Error updating personal task status: $e');
      errorMessage.value = 'An error occurred. Please try again.';
      isUpdatingStatus.value = false;
      return false;
    }
  }

  // Format DateTime to YYYY-MM-DDTHH:MM:SS (without Z)
  String _formatDateTimeWithoutZ(DateTime dateTime) {
    final year = dateTime.year;
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final second = dateTime.second.toString().padLeft(2, '0');

    return '$year-$month-${day}T$hour:$minute:$second';
  }

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
        print('No access token found');
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
      print('📡 Response body: ${response.jsonResponse}');

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

  UgcTask _mapApiResponseToUgcTask(Map<String, dynamic> json) {
    TaskStatus taskStatus;
    final status = json['status']?.toString().toLowerCase() ?? 'pending';
    switch (status) {
      case 'completed':
        taskStatus = TaskStatus.completed;
        break;
      case 'inprogress':
        taskStatus = TaskStatus.inProgress;
        break;
      default:
        taskStatus = TaskStatus.pending;
    }

    final List<UgcSubTask> ugcSubtasks = [];
    final subtasksList = json['subtasks'] as List?;
    if (subtasksList != null) {
      for (var subtaskJson in subtasksList) {
        final isCompleted = subtaskJson['isCompleted'] ?? false;

        ugcSubtasks.add(
          UgcSubTask(
            id: subtaskJson['_id'] ?? '',
            title: subtaskJson['title'] ?? '',
            isCompleted: isCompleted,
            duration: subtaskJson['duration']?.toString(),
            completedAt: subtaskJson['completedAt'] != null
                ? DateTime.tryParse(subtaskJson['completedAt'])
                : null,
          ),
        );
      }
    }

    String? assignedBy;
    String? assignedByImage;
    final taskType = json['taskType']?.toString() ?? 'personal';
    final createdBy = json['createdById'];

    if (taskType == 'personal') {
      assignedBy = null;
      assignedByImage = null;
    } else if (createdBy != null && createdBy['name'] != null) {
      assignedBy = createdBy['name'];
      final profileImage = createdBy['profileImage'];
      if (profileImage != null && profileImage['imageUrl'] != null) {
        assignedByImage = _getImageUrl(profileImage['imageUrl']);
      }
    }

    List<String>? groupMembers;
    if (taskType == 'collaborative') {
      final assignedUsers = json['assignedUserIds'] as List?;
      if (assignedUsers != null && assignedUsers.isNotEmpty) {
        groupMembers = [];
        for (var user in assignedUsers) {
          final profileImage = user['profileImage'];
          String imageUrl = "assets/images/dummy_user_image.png";
          if (profileImage != null && profileImage['imageUrl'] != null) {
            imageUrl = _getImageUrl(profileImage['imageUrl']);
          }
          groupMembers.add(imageUrl);
        }
      }
    }

    DateTime createdAt = DateTime.now();
    if (json['createdAt'] != null) {
      createdAt = DateTime.tryParse(json['createdAt']) ?? DateTime.now();
    }

    DateTime startTime = DateTime.now();
    if (json['startTime'] != null) {
      startTime = DateTime.tryParse(json['startTime']) ?? DateTime.now();
    }

    DateTime? completedTime;
    if (json['completedTime'] != null) {
      completedTime = DateTime.tryParse(json['completedTime']);
    }

    DateTime dueDate = DateTime.now();
    if (json['dueDate'] != null) {
      dueDate = DateTime.tryParse(json['dueDate']) ?? DateTime.now();
    }

    final subtaskProgress = json['subtaskProgress'] ?? {};
    final totalSubtasks =
        subtaskProgress['total'] ?? json['totalSubtasks'] ?? 0;
    final completedSubtasks =
        subtaskProgress['completed'] ?? json['completedSubtasks'] ?? 0;

    return UgcTask(
      id: json['_id'] ?? '',
      taskType: taskType,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      time: json['scheduledTime'] ?? '',
      totalSubtasks: totalSubtasks,
      completedSubtasks: completedSubtasks,
      status: taskStatus,
      createdAt: createdAt,
      startTime: startTime,
      completedTime: completedTime,
      dueDate: dueDate,
      priority: json['priority'] ?? 'medium',
      subtasks: ugcSubtasks,
      assignedBy: assignedBy,
      assignedByImage: assignedByImage,
      groupMembers: groupMembers,
    );
  }

  String _getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return "";
    if (imagePath.startsWith('http')) return imagePath;

    String cleanPath = imagePath;
    if (cleanPath.startsWith('/')) {
      cleanPath = cleanPath.substring(1);
    }
    return '${AppUrl.imageBaseUrl}/$cleanPath';
  }
}