/**
import 'package:get/get.dart';
import '../../../../../utils/network/app_url.dart';
import '../../../../../utils/network/network_caller_dio.dart';
import '../../../../../utils/network/secure_storage_service.dart';
import '../../../widget/ugc_home_widget/ugc_daily_progress_widget.dart';
import '../ugc_task_details/ugc_task_model/ugc_sub_task_model.dart';
import '../ugc_task_details/ugc_task_model/ugc_task_model.dart';

class UgcHomeController extends GetxController {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();

  // Observable variables
  var dailyProgress = Rx<DailyProgressData?>(null);
  var tasks = <UgcTask>[].obs;
  var isLoadingProgress = false.obs;
  var isLoadingTasks = false.obs;
  var hasMoreTasks = true.obs;
  var errorMessage = RxString('');

  // Pagination
  int _currentPage = 1;
  final int _limit = 10;

  @override
  void onInit() {
    super.onInit();
    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    await Future.wait([
      fetchDailyProgress(),
      fetchTasks(),
    ]);
  }

  Future<void> fetchDailyProgress() async {
    isLoadingProgress.value = true;
    errorMessage.value = '';

    try {
      final token = await SecureStorageService.instance.getAccessToken();

      if (token == null) {
        print('No access token found');
        return;
      }

      final response = await _networkCaller.getRequest(
        AppUrl.getUgcDailyProgress,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.isSuccess && response.jsonResponse != null) {
        final data = response.jsonResponse?['data']?['attributes'];
        if (data != null) {
          dailyProgress.value = DailyProgressData.fromJson(data);
        }
      }
    } catch (e) {
      errorMessage.value = e.toString();
      print('Error fetching daily progress: $e');
    } finally {
      isLoadingProgress.value = false;
    }
  }

  Future<void> fetchTasks({bool isLoadMore = false}) async {
    if (isLoadMore && !hasMoreTasks.value) return;

    if (isLoadMore) {
      _currentPage++;
    } else {
      isLoadingTasks.value = true;
    }

    try {
      final token = await SecureStorageService.instance.getAccessToken();

      if (token == null) {
        print('No access token found');
        return;
      }

      final response = await _networkCaller.getRequest(
        '${AppUrl.getUgcHomeScreenTask}?page=$_currentPage&limit=$_limit',
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.isSuccess && response.jsonResponse != null) {
        final attributes = response.jsonResponse?['data']?['attributes'];

        if (attributes != null && attributes is List) {
          final newTasks = <UgcTask>[];
          for (var taskJson in attributes) {
            final task = _mapApiResponseToUgcTask(taskJson);
            newTasks.add(task);
          }

          if (isLoadMore) {
            tasks.addAll(newTasks);
          } else {
            tasks.value = newTasks;
          }

          hasMoreTasks.value = newTasks.length == _limit;
        }
      }
    } catch (e) {
      errorMessage.value = e.toString();
      print('Error fetching tasks: $e');
    } finally {
      isLoadingTasks.value = false;
    }
  }

  // Map API response to your existing UgcTask model
  UgcTask _mapApiResponseToUgcTask(Map<String, dynamic> json) {
    // Parse status
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

    // Parse subtasks
    final List<UgcSubTask> ugcSubtasks = [];
    final subtasksList = json['subtasks'] as List?;
    if (subtasksList != null) {
      for (var subtaskJson in subtasksList) {
        ugcSubtasks.add(
          UgcSubTask(
            title: subtaskJson['title'] ?? '',
            isCompleted: subtaskJson['isCompleted'] ?? false,
          ),
        );
      }
    }

    // Determine assigned by
    String? assignedBy;
    final taskType = json['taskType']?.toString() ?? 'personal';
    final createdBy = json['createdById'];

    if (taskType == 'personal') {
      assignedBy = null; // Self task
    } else if (createdBy != null && createdBy['name'] != null) {
      assignedBy = createdBy['name'];
    }

    // Get group members for collaborative tasks
    List<String>? groupMembers;
    if (taskType == 'collaborative') {
      final assignedUsers = json['assignedUserIds'] as List?;
      if (assignedUsers != null && assignedUsers.isNotEmpty) {
        groupMembers = [];
        for (var user in assignedUsers) {
          final profileImage = user['profileImage'];
          final imageUrl = profileImage?['imageUrl'] ?? "assets/images/dummy_user_image.png";
          groupMembers.add(imageUrl);
        }
      }
    }

    // Parse times
    DateTime startTime = DateTime.now();
    if (json['startTime'] != null) {
      startTime = DateTime.tryParse(json['startTime']) ?? DateTime.now();
    }

    DateTime? completedTime;
    if (json['completedTime'] != null) {
      completedTime = DateTime.tryParse(json['completedTime']);
    }

    // Get subtask progress
    final subtaskProgress = json['subtaskProgress'] ?? {};
    final totalSubtasks = subtaskProgress['total'] ?? json['totalSubtasks'] ?? 0;
    final completedSubtasks = subtaskProgress['completed'] ?? json['completedSubtasks'] ?? 0;

    return UgcTask(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      time: json['scheduledTime'] ?? '',
      totalSubtasks: totalSubtasks,
      completedSubtasks: completedSubtasks,
      status: taskStatus,
      createdAt: DateTime.now(),
      startTime: startTime,
      completedTime: completedTime,
      subtasks: ugcSubtasks,
      assignedBy: assignedBy,
      groupMembers: groupMembers,
    );
  }

  // Refresh method for pull-to-refresh
  Future<void> refreshData() async {
    _currentPage = 1;
    hasMoreTasks.value = true;
    await Future.wait([
      fetchDailyProgress(),
      fetchTasks(isLoadMore: false),
    ]);
  }

  // Load more tasks for pagination
  void loadMoreTasks() {
    if (!isLoadingTasks.value && hasMoreTasks.value) {
      fetchTasks(isLoadMore: true);
    }
  }
}





*/






import 'package:get/get.dart';
import '../../../../../utils/network/app_url.dart';
import '../../../../../utils/network/network_caller_dio.dart';
import '../../../../../utils/network/secure_storage_service.dart';
import '../../../widget/ugc_home_widget/ugc_daily_progress_widget.dart';
import '../ugc_task_details/ugc_task_model/ugc_sub_task_model.dart';
import '../ugc_task_details/ugc_task_model/ugc_task_model.dart';

class UgcHomeController extends GetxController {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();

  // Observable variables
  var dailyProgress = Rx<DailyProgressData?>(null);
  var tasks = <UgcTask>[].obs;
  var isLoadingProgress = false.obs;
  var isLoadingTasks = false.obs;
  var hasMoreTasks = true.obs;
  var errorMessage = RxString('');

  // Pagination
  int _currentPage = 1;
  final int _limit = 10;

  @override
  void onInit() {
    super.onInit();
    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    await Future.wait([
      fetchDailyProgress(),
      fetchTasks(),
    ]);
  }

  Future<void> fetchDailyProgress() async {
    isLoadingProgress.value = true;
    errorMessage.value = '';

    try {
      final token = await SecureStorageService.instance.getAccessToken();

      if (token == null) {
        print('No access token found');
        return;
      }

      final response = await _networkCaller.getRequest(
        AppUrl.getUgcDailyProgress,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.isSuccess && response.jsonResponse != null) {
        final data = response.jsonResponse?['data']?['attributes'];
        if (data != null) {
          dailyProgress.value = DailyProgressData.fromJson(data);
        }
      }
    } catch (e) {
      errorMessage.value = e.toString();
      print('Error fetching daily progress: $e');
    } finally {
      isLoadingProgress.value = false;
    }
  }

  Future<void> fetchTasks({bool isLoadMore = false}) async {
    if (isLoadMore && !hasMoreTasks.value) return;

    if (isLoadMore) {
      _currentPage++;
    } else {
      isLoadingTasks.value = true;
    }

    try {
      final token = await SecureStorageService.instance.getAccessToken();

      if (token == null) {
        print('No access token found');
        return;
      }

      final response = await _networkCaller.getRequest(
        '${AppUrl.getUgcHomeScreenTask}?page=$_currentPage&limit=$_limit',
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.isSuccess && response.jsonResponse != null) {
        final attributes = response.jsonResponse?['data']?['attributes'];

        if (attributes != null && attributes is List) {
          final newTasks = <UgcTask>[];
          for (var taskJson in attributes) {
            final task = _mapApiResponseToUgcTask(taskJson);
            newTasks.add(task);
          }

          if (isLoadMore) {
            tasks.addAll(newTasks);
          } else {
            tasks.value = newTasks;
          }

          hasMoreTasks.value = newTasks.length == _limit;
        }
      }
    } catch (e) {
      errorMessage.value = e.toString();
      print('Error fetching tasks: $e');
    } finally {
      isLoadingTasks.value = false;
    }
  }

  // Helper method to get full image URL
  String getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return "assets/images/dummy_user_image.png";
    }

    // If it's already a full URL, return as is
    if (imagePath.startsWith('http')) {
      return imagePath;
    }

    // Remove leading slash if present to avoid double slashes
    String cleanPath = imagePath;
    if (cleanPath.startsWith('/')) {
      cleanPath = cleanPath.substring(1);
    }

    return '${AppUrl.imageBaseUrl}/$cleanPath';
  }

  // Map API response to your existing UgcTask model
  UgcTask _mapApiResponseToUgcTask(Map<String, dynamic> json) {
    // Parse status
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

    // Parse subtasks
    final List<UgcSubTask> ugcSubtasks = [];
    final subtasksList = json['subtasks'] as List?;
    if (subtasksList != null) {
      for (var subtaskJson in subtasksList) {
        ugcSubtasks.add(
          UgcSubTask(
            title: subtaskJson['title'] ?? '',
            isCompleted: subtaskJson['isCompleted'] ?? false,
          ),
        );
      }
    }

    // Determine assigned by and their image
    String? assignedBy;
    String? assignedByImage;
    final taskType = json['taskType']?.toString() ?? 'personal';
    final createdBy = json['createdById'];

    if (taskType == 'personal') {
      assignedBy = null; // Self task
      assignedByImage = null;
    } else if (createdBy != null && createdBy['name'] != null) {
      assignedBy = createdBy['name'];
      // Get the profile image of the person who assigned
      final profileImage = createdBy['profileImage'];
      if (profileImage != null && profileImage['imageUrl'] != null) {
        assignedByImage = getImageUrl(profileImage['imageUrl']);
      }
    }

    // Get group members for collaborative tasks
    List<String>? groupMembers;
    if (taskType == 'collaborative') {
      final assignedUsers = json['assignedUserIds'] as List?;
      if (assignedUsers != null && assignedUsers.isNotEmpty) {
        groupMembers = [];
        for (var user in assignedUsers) {
          final profileImage = user['profileImage'];
          String imageUrl = "assets/images/dummy_user_image.png";
          if (profileImage != null && profileImage['imageUrl'] != null) {
            imageUrl = getImageUrl(profileImage['imageUrl']);
          }
          groupMembers.add(imageUrl);
        }
      }
    }

    // Parse times
    DateTime startTime = DateTime.now();
    if (json['startTime'] != null) {
      startTime = DateTime.tryParse(json['startTime']) ?? DateTime.now();
    }

    DateTime? completedTime;
    if (json['completedTime'] != null) {
      completedTime = DateTime.tryParse(json['completedTime']);
    }

    // Get subtask progress
    final subtaskProgress = json['subtaskProgress'] ?? {};
    final totalSubtasks = subtaskProgress['total'] ?? json['totalSubtasks'] ?? 0;
    final completedSubtasks = subtaskProgress['completed'] ?? json['completedSubtasks'] ?? 0;

    return UgcTask(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      time: json['scheduledTime'] ?? '',
      totalSubtasks: totalSubtasks,
      completedSubtasks: completedSubtasks,
      status: taskStatus,
      createdAt: DateTime.now(),
      startTime: startTime,
      completedTime: completedTime,
      subtasks: ugcSubtasks,
      assignedBy: assignedBy,
      assignedByImage: assignedByImage,
      groupMembers: groupMembers,
    );
  }

  // Refresh method for pull-to-refresh
  Future<void> refreshData() async {
    _currentPage = 1;
    hasMoreTasks.value = true;
    await Future.wait([
      fetchDailyProgress(),
      fetchTasks(isLoadMore: false),
    ]);
  }

  // Load more tasks for pagination
  void loadMoreTasks() {
    if (!isLoadingTasks.value && hasMoreTasks.value) {
      fetchTasks(isLoadMore: true);
    }
  }
}