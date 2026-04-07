// ugc_task_status_controller.dart
import 'package:get/get.dart';
import '../../../../utils/network/app_url.dart';
import '../../../../utils/network/network_caller_dio.dart';
import '../../../../utils/network/network_response_dio.dart';
import '../../../../utils/network/secure_storage_service.dart';

class UgcTaskStatusController extends GetxController {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();

  var isLoading = false.obs;
  var errorMessage = RxString('');

  var pendingTasks = <Map<String, dynamic>>[].obs;
  var inProgressTasks = <Map<String, dynamic>>[].obs;
  var completedTasks = <Map<String, dynamic>>[].obs;

  var selectedTab = 0.obs;
  final List<String> tabTitles = ['Pending', 'In Progress', 'Completed'];

  @override
  void onInit() {
    super.onInit();
    fetchAllTasks();
  }

  Future<void> fetchAllTasks() async {
    await Future.wait([
      fetchTasksByStatus('pending'),
      fetchTasksByStatus('inProgress'),
      fetchTasksByStatus('completed'),
    ]);
  }

  Future<void> fetchTasksByStatus(String status) async {
    try {
      final token = await SecureStorageService.instance.getAccessToken();

      if (token == null) {
        print('No access token found');
        return;
      }

      final response = await _networkCaller.getRequest(
        AppUrl.getTaskStatusList(status),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.isSuccess && response.jsonResponse != null) {
        final attributes = response.jsonResponse?['data']?['attributes'];

        if (attributes != null && attributes is List) {
          final List<Map<String, dynamic>> tasks = [];

          for (var taskJson in attributes) {
            final mappedTask = _mapApiResponseToTaskData(taskJson);
            tasks.add(mappedTask);
          }

          // Assign to appropriate list based on status
          switch (status.toLowerCase()) {
            case 'pending':
              pendingTasks.value = tasks;
              break;
            case 'inprogress':
              inProgressTasks.value = tasks;
              break;
            case 'completed':
              completedTasks.value = tasks;
              break;
          }
        }
      }
    } catch (e) {
      print('Error fetching $status tasks: $e');
      errorMessage.value = e.toString();
    }
  }

  Map<String, dynamic> _mapApiResponseToTaskData(Map<String, dynamic> json) {
    // Parse status
    final status = json['status']?.toString().toLowerCase() ?? 'pending';

    // Parse progress
    final subtaskProgress = json['subtaskProgress'] ?? {};
    final totalSubtasks = subtaskProgress['total'] ?? json['totalSubtasks'] ?? 0;
    final completedSubtasks = subtaskProgress['completed'] ?? json['completedSubtasks'] ?? 0;
    final progressPercentage = totalSubtasks > 0
        ? (completedSubtasks / totalSubtasks * 100).toInt()
        : 0;

    // Determine task type display
    String? taskTypeDisplay;
    final taskType = json['taskType']?.toString() ?? 'personal';
    final assignedUserIds = json['assignedUserIds'] as List?;
    final isGroupTask = taskType == 'collaborative' && assignedUserIds != null && assignedUserIds.length > 1;

    if (taskType == 'personal') {
      taskTypeDisplay = 'Self Task';
    } else if (isGroupTask) {
      taskTypeDisplay = 'Group Tasks';
    }

    // Get assignee name
    String? assigneeName;
    final createdBy = json['createdById'];
    if (createdBy != null && createdBy['name'] != null) {
      assigneeName = 'Assigned by ${createdBy['name']}';
    }

    // Get group member images for group tasks
    List<String> groupMemberImages = [];
    if (isGroupTask && assignedUserIds != null) {
      for (var user in assignedUserIds) {
        final profileImage = user['profileImage'];
        if (profileImage != null && profileImage['imageUrl'] != null) {
          String imageUrl = profileImage['imageUrl'];
          if (!imageUrl.startsWith('http')) {
            String cleanPath = imageUrl;
            if (cleanPath.startsWith('/')) {
              cleanPath = cleanPath.substring(1);
            }
            imageUrl = '${AppUrl.imageBaseUrl}/$cleanPath';
          }
          groupMemberImages.add(imageUrl);
        } else {
          groupMemberImages.add("assets/images/dummy_child_user_image.png");
        }
      }
    }

    return {
      'id': json['_id'] ?? '',
      'title': json['title'] ?? '',
      'time': json['scheduledTime'] ?? '',
      'subtasks': totalSubtasks,
      'progress': progressPercentage,
      'assignee': assigneeName,
      'taskType': taskTypeDisplay,
      'isGroupTask': isGroupTask,
      'status': status,
      'groupMemberImages': groupMemberImages,
      'description': json['description'] ?? '',
      'priority': json['priority'] ?? 'medium',
      'dueDate': json['dueDate'],
      'createdAt': json['createdAt'],
      'startTime': json['startTime'],
    };
  }

  List<Map<String, dynamic>> getCurrentTasks() {
    switch (selectedTab.value) {
      case 0:
        return pendingTasks;
      case 1:
        return inProgressTasks;
      case 2:
        return completedTasks;
      default:
        return [];
    }
  }

  int getCurrentTaskCount() {
    return getCurrentTasks().length;
  }

  void changeTab(int index) {
    selectedTab.value = index;
  }

  Future<void> refreshData() async {
    await fetchAllTasks();
  }
}