import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_texts_style.dart';
import '../../../../utils/network/app_url.dart';
import '../../../../utils/network/network_caller_dio.dart';
import '../../../../utils/network/secure_storage_service.dart';
import '../../features/group_user/visions/ugc_home/controller/ugc_home_screen_controller.dart';
import '../../features/group_user/visions/ugc_home/ugc_task_details/ugc_task_details_screen.dart';
import '../../features/individual_user/views/home/task_details/task_details_screen.dart';
import '../../features/individual_user/views/home/task_details/model/sub_task_model.dart';
import '../../features/individual_user/views/home/task_details/model/task_model.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();

  // A bare Dio instance for the mark-as-read call
  final Dio _dio = Dio();

  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  /// Notification IDs currently being marked as read (shows spinner)
  final Set<String> _markingInProgress = {};

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  // ─────────────────────────────────────────────
  // FETCH NOTIFICATIONS
  // ─────────────────────────────────────────────
  Future<void> _fetchNotifications() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      final token = await SecureStorageService.instance.getAccessToken();

      if (token == null) {
        setState(() {
          _errorMessage = 'No access token found';
          _hasError = true;
          _isLoading = false;
        });
        return;
      }

      final response = await _networkCaller.getRequest(
        AppUrl.getNotification,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.isSuccess && response.jsonResponse != null) {
        final attributes = response.jsonResponse?['data']?['attributes'];
        final results = attributes?['results'] as List?;

        if (results != null) {
          final List<Map<String, dynamic>> formatted = [];
          for (var n in results) {
            formatted.add(_formatNotification(n));
          }
          setState(() {
            _notifications = formatted;
            _isLoading = false;
          });
        } else {
          setState(() {
            _notifications = [];
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage =
              response.errorMessage ?? 'Failed to load notifications';
          _hasError = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  // ─────────────────────────────────────────────
  // FORMAT RAW NOTIFICATION → local map
  // ─────────────────────────────────────────────
  Map<String, dynamic> _formatNotification(Map<String, dynamic> raw) {
    final title = raw['title'] ?? '';
    String message = raw['subTitle'] ?? '';

    if (message.isEmpty && raw['data'] != null) {
      final data = raw['data'] as Map<String, dynamic>;
      final taskTitle = data['taskTitle'] ?? '';
      final activityType = data['activityType'] ?? data['eventType'] ?? '';

      if (activityType == 'task_created') {
        message = 'Task created: "$taskTitle"';
      } else if (activityType == 'task_assigned' ||
          raw['type'] == 'assignment') {
        message = 'You\'ve been assigned a new task: "$taskTitle"';
      } else {
        message = 'New notification received';
      }
    }

    final createdAt = raw['createdAt'] != null
        ? DateTime.tryParse(raw['createdAt']) ?? DateTime.now()
        : DateTime.now();

    final isRead = raw['status'] == 'read';

    final data = raw['data'] as Map<String, dynamic>? ?? {};
    final taskId = data['taskId'] ?? raw['linkId'] ?? '';
    final taskType = data['taskType'] ?? 'personal';

    return {
      'notificationId': raw['_id'] ?? '',
      'taskId': taskId,
      'title': title,
      'message': message,
      'time': createdAt,
      'read': isRead,
      'type': raw['type'] ?? 'task',
      'taskType': taskType,
      'data': data,
    };
  }

  // ─────────────────────────────────────────────
  // MARK SINGLE NOTIFICATION AS READ
  // ─────────────────────────────────────────────
  Future<void> _markAsRead(String notificationId) async {
    if (_markingInProgress.contains(notificationId)) return;

    final idx = _notifications
        .indexWhere((n) => n['notificationId'] == notificationId);
    if (idx == -1) return;
    if (_notifications[idx]['read'] == true) return;

    setState(() => _markingInProgress.add(notificationId));

    try {
      final token = await SecureStorageService.instance.getAccessToken();
      if (token == null) return;

      final url = AppUrl.markSingleNotification(notificationId);
      debugPrint('🔔 Marking notification as read | URL: $url');

      final response = await _dio.post(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      debugPrint('✅ Mark-as-read status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          setState(() {
            _notifications[idx] = {
              ..._notifications[idx],
              'read': true,
            };
          });
        }
      } else {
        debugPrint(
          '⚠️ Mark-as-read failed | status: ${response.statusCode} | body: ${response.data}',
        );
      }
    } on DioException catch (e) {
      debugPrint('❌ DioException marking notification: ${e.message}');
    } catch (e) {
      debugPrint('❌ Error marking notification as read: $e');
    } finally {
      if (mounted) setState(() => _markingInProgress.remove(notificationId));
    }
  }

// ─────────────────────────────────────────────
// FETCH TASK DETAILS FROM API
// ─────────────────────────────────────────────
  Future<Task?> _fetchTaskDetails(String taskId) async {
    try {
      final token = await SecureStorageService.instance.getAccessToken();
      if (token == null) return null;

      final url = AppUrl.getIndividualTaskDetails(taskId);
      debugPrint('📡 Fetching task details from: $url');

      final response = await _networkCaller.getRequest(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.isSuccess && response.jsonResponse != null) {
        final taskJson = response.jsonResponse?['data']?['attributes'];
        if (taskJson != null) {
          return _createTaskFromJson(taskJson, taskId);
        }
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error fetching task details: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────
  // CREATE TASK OBJECT FROM JSON
  // ─────────────────────────────────────────────
  Task _createTaskFromJson(Map<String, dynamic> json, String taskId) {
    // Parse status
    TaskStatus status = _parseTaskStatus(json['status'] ?? 'pending');

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

    // Format time
    String formattedTime = _formatTimeOfDay(startTime);

    return Task(
      id: taskId,
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
      createdBy: null,
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

  // ─────────────────────────────────────────────
  // NAVIGATE ON TAP
  // ─────────────────────────────────────────────
  Future<void> _onNotificationTap(Map<String, dynamic> notification) async {
    final notificationId = notification['notificationId'] as String;
    final taskId = notification['taskId'] as String;
    final taskType = notification['taskType'] as String;

    if (taskId.isEmpty) {
      debugPrint('⚠️ No taskId — skipping navigation');
      return;
    }

    // Fire-and-forget: mark as read in the background
    _markAsRead(notificationId);

    final bool isGroupUserFlow = Get.isRegistered<UgcHomeController>();

    debugPrint(
      '🔔 Notification tapped | notificationId: $notificationId '
          '| taskId: $taskId | taskType: $taskType | isGroupUserFlow: $isGroupUserFlow',
    );

    if (isGroupUserFlow) {
      // Group User → UgcTaskDetailsScreen
      Get.to(
            () => const UgcTaskDetailsScreen(),
        arguments: {'taskId': taskId},
        transition: Transition.fadeIn,
      );
    } else {
      // Individual User → TaskDetailsScreen
      // Fetch full task details first
      final task = await _fetchTaskDetails(taskId);

      if (task != null) {
        Get.to(
              () => TaskDetailsScreen(task: task),
          transition: Transition.fadeIn,
        );
      } else {
        // Show error if task not found
        Get.snackbar(
          'Error',
          'Failed to load task details',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  // ─────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes} min ago';
    if (difference.inHours < 24) return '${difference.inHours} hours ago';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    return DateFormat('dd MMM yyyy').format(time);
  }

  IconData _getNotificationIcon(String title, String type) {
    if (title.contains('Task Created') || type == 'task') {
      return Icons.check_circle;
    } else if (title.contains('Reminder')) {
      return Icons.access_time;
    } else if (title.contains('Assigned') || type == 'assignment') {
      return Icons.assignment;
    } else if (title.contains('Deadline')) {
      return Icons.warning;
    }
    return Icons.notifications;
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text('Notifications', style: AppTextStyles.smallHeading),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back),
        ),
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(color: AppColors.primaryColor),
      )
          : _hasError
          ? _buildErrorState()
          : _notifications.isEmpty
          ? _buildEmptyState()
          : _buildNotificationList(),
    );
  }

  // ─────────────────────────────────────────────
  // WIDGETS
  // ─────────────────────────────────────────────
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(
            _errorMessage,
            style: TextStyle(color: Colors.red.shade400),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchNotifications,
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SvgPicture.asset(
        "assets/images/empty_notificaiton_screen_iconWithText.svg",
        width: double.infinity,
        height: 300,
      ),
    );
  }

  Widget _buildNotificationList() {
    return RefreshIndicator(
      color: AppColors.primaryColor,
      onRefresh: _fetchNotifications,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          final isUnread = notification['read'] == false;
          final notificationId = notification['notificationId'] as String;
          final isMarkingThisOne = _markingInProgress.contains(notificationId);

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
            color: isUnread
                ? AppColors.primaryColor.withOpacity(0.04)
                : Colors.white,
            child: InkWell(
              onTap: isMarkingThisOne
                  ? null
                  : () => _onNotificationTap(notification),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getNotificationIcon(
                          notification['title'],
                          notification['type'],
                        ),
                        color: AppColors.primaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  notification['title'],
                                  style: AppTextStyles.defaultTextStyle.copyWith(
                                    fontWeight: isUnread
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              // NEW / READ badge
                              if (!isMarkingThisOne)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isUnread
                                        ? AppColors.primaryColor.withOpacity(0.1)
                                        : Colors.grey.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    isUnread ? 'NEW' : 'READ',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: isUnread
                                          ? AppColors.primaryColor
                                          : Colors.grey,
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 8),
                              // Spinner while marking OR blue dot if unread
                              if (isMarkingThisOne)
                                SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.5,
                                    color: AppColors.primaryColor,
                                  ),
                                )
                              else if (isUnread)
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            notification['message'],
                            style: AppTextStyles.smallText
                                .copyWith(color: AppColors.grey),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _formatTime(notification['time']),
                            style: AppTextStyles.smallText.copyWith(
                              color: AppColors.lightGrey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}