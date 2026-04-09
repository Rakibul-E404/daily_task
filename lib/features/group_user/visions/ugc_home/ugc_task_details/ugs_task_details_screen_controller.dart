import 'package:askfemi/features/group_user/visions/ugc_home/ugc_task_details/ugc_task_model/ugc_sub_task_model.dart';
import 'package:askfemi/features/group_user/visions/ugc_home/ugc_task_details/ugc_task_model/ugc_task_model.dart';
import 'package:get/get.dart';
import '../../../../../utils/network/app_url.dart';
import '../../../../../utils/network/network_caller_dio.dart';
import '../../../../../utils/network/secure_storage_service.dart';

class UgcTaskDetailsController extends GetxController {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();

  var task = Rx<UgcTask?>(null);
  var isLoading = false.obs;
  var isUpdatingStatus = false.obs;
  var isDeleting = false.obs;
  var errorMessage = RxString('');

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

  Future<bool> updateTaskStatus(String taskId, String status) async {
    isUpdatingStatus.value = true;
    errorMessage.value = '';

    try {
      final token = await SecureStorageService.instance.getAccessToken();

      if (token == null) {
        errorMessage.value = 'No access token found';
        print('No access token found');
        isUpdatingStatus.value = false;
        return false;
      }

      final Map<String, dynamic> requestBody = {
        "status": status,
      };

      print('📤 Updating task status to: $status');
      print('📤 Request body: $requestBody');

      final response = await _networkCaller.putRequest(
        AppUrl.ugcTaskStatusUpdate(taskId, status),
        body: requestBody,
        headers: {'Authorization': 'Bearer $token'},
      );

      print('📡 Response status code: ${response.statusCode}');
      print('📡 Response success: ${response.isSuccess}');
      print('📡 Response body: ${response.jsonResponse}');

      if (response.isSuccess || response.statusCode == 200) {
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
        final myCompletion = subtaskJson['myCompletion'] ?? {};
        ugcSubtasks.add(
          UgcSubTask(
            id: subtaskJson['_id'] ?? '',
            title: subtaskJson['title'] ?? '',
            isCompleted: myCompletion['isCompleted'] ?? false,
            duration: subtaskJson['duration']?.toString(),
            completedAt: myCompletion['completedAt'] != null
                ? DateTime.tryParse(myCompletion['completedAt'])
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
    final myProgress = json['myProgress'];
    if (myProgress != null && myProgress['completedAt'] != null) {
      completedTime = DateTime.tryParse(myProgress['completedAt']);
    }

    DateTime dueDate = DateTime.now();
    if (json['dueDate'] != null) {
      dueDate = DateTime.tryParse(json['dueDate']) ?? DateTime.now();
    }

    final subtaskProgress = json['subtaskProgress'] ?? {};
    final totalSubtasks = subtaskProgress['total'] ?? json['totalSubtasks'] ?? 0;
    final completedSubtasks = subtaskProgress['completed'] ?? json['completedSubtasks'] ?? 0;

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
    if (imagePath == null || imagePath.isEmpty) {
      return "";
    }
    if (imagePath.startsWith('http')) {
      return imagePath;
    }
    String cleanPath = imagePath;
    if (cleanPath.startsWith('/')) {
      cleanPath = cleanPath.substring(1);
    }
    return '${AppUrl.imageBaseUrl}/$cleanPath';
  }
}
