/**

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:intl/intl.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_texts_style.dart';
import '../../../../utils/static_text.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool _showNotifications = false;
  final List<Map<String, dynamic>> _dummyNotifications = [
    {
      'title': 'Task Completed',
      'message': 'Your project meeting task has been completed',
      'time': DateTime.now().subtract(const Duration(minutes: 30)),
      'read': false,
    },
    {
      'title': 'Task Reminder',
      'message': 'Submit weekly report in 2 hours',
      'time': DateTime.now().subtract(const Duration(hours: 2)),
      'read': false,
    },
    {
      'title': 'New Task Assigned',
      'message': 'You have been assigned a new task: Client Presentation',
      'time': DateTime.now().subtract(const Duration(hours: 5)),
      'read': true,
    },
    {
      'title': 'Task Deadline',
      'message': 'Budget planning task deadline is tomorrow',
      'time': DateTime.now().subtract(const Duration(days: 1)),
      'read': true,
    },
    {
      'title': 'Team Update',
      'message': 'John updated the history of team task',
      'time': DateTime.now().subtract(const Duration(days: 2)),
      'read': true,
    },
  ];

  void _toggleNotifications() {
    setState(() {
      _showNotifications = !_showNotifications;
    });
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('dd MMM').format(time);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          "Notifications",
          style: AppTextStyles.smallHeading,
        ),
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(Icons.arrow_back),
        ),
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Dummy Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _toggleNotifications,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                _showNotifications ? 'Hide Notifications' : 'Show Dummy Notifications',
                style: AppTextStyles.defaultTextStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Content
          Expanded(
            child: _showNotifications
                ? _buildNotificationList()
                : _buildEmptyState(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            "assets/images/empty_notificaiton_screen_iconWithText.svg",
            width: double.infinity,
            height: 300,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _dummyNotifications.length,
      itemBuilder: (context, index) {
        final notification = _dummyNotifications[index];
        final isUnread = !notification['read'];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Notification Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getNotificationIcon(notification['title']),
                    color: AppColors.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),

                // Notification Content
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
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          if (isUnread)
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
                        style: AppTextStyles.smallText.copyWith(
                          color: AppColors.grey,
                        ),
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
        );
      },
    );
  }

  IconData _getNotificationIcon(String title) {
    if (title.contains('Completed')) {
      return Icons.check_circle;
    } else if (title.contains('Reminder')) {
      return Icons.access_time;
    } else if (title.contains('Assigned')) {
      return Icons.assignment;
    } else if (title.contains('Deadline')) {
      return Icons.warning;
    } else {
      return Icons.group;
    }
  }
}*/











import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_texts_style.dart';
import '../../../../utils/network/app_url.dart';
import '../../../../utils/network/network_caller_dio.dart';
import '../../../../utils/network/secure_storage_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();

  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

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

      print('📡 Response status code: ${response.statusCode}');
      print('📡 Response success: ${response.isSuccess}');

      if (response.isSuccess && response.jsonResponse != null) {
        final attributes = response.jsonResponse?['data']?['attributes'];
        final results = attributes?['results'] as List?;

        if (results != null) {
          final List<Map<String, dynamic>> formattedNotifications = [];
          for (var notification in results) {
            formattedNotifications.add(_formatNotification(notification));
          }
          setState(() {
            _notifications = formattedNotifications;
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
          _errorMessage = response.errorMessage ?? 'Failed to load notifications';
          _hasError = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching notifications: $e');
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic> _formatNotification(Map<String, dynamic> notification) {
    final title = notification['title'] ?? '';
    String message = notification['subTitle'] ?? '';

    // If no subtitle, create message from data
    if (message.isEmpty && notification['data'] != null) {
      final data = notification['data'];
      final taskTitle = data['taskTitle'] ?? '';
      final eventType = data['eventType'] ?? '';

      if (eventType == 'task_created') {
        message = 'You created a task: "$taskTitle"';
      } else if (eventType == 'task_assigned') {
        message = 'You\'ve been assigned a new task: "$taskTitle"';
      } else {
        message = 'New notification received';
      }
    }

    final createdAt = notification['createdAt'] != null
        ? DateTime.parse(notification['createdAt'])
        : DateTime.now();

    // Determine if notification is read (you can add a read status field if available)
    final isRead = notification['status'] == 'read' || false;

    return {
      'id': notification['_id'] ?? '',
      'title': title,
      'message': message,
      'time': createdAt,
      'read': isRead,
      'type': notification['type'] ?? 'task',
      'linkId': notification['linkId'] ?? '',
      'data': notification['data'] ?? {},
    };
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('dd MMM yyyy').format(time);
    }
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
    } else {
      return Icons.notifications;
    }
  }

  void _onNotificationTap(Map<String, dynamic> notification) {
    // Handle notification tap - navigate to relevant screen
    print('Notification tapped: ${notification['title']}');
    // You can navigate based on linkId or type
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          "Notifications",
          style: AppTextStyles.smallHeading,
        ),
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(Icons.arrow_back),
        ),
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryColor,
        ),
      )
          : _hasError
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
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
                backgroundColor: AppColors.primaryColor,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : _notifications.isEmpty
          ? _buildEmptyState()
          : _buildNotificationList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            "assets/images/empty_notificaiton_screen_iconWithText.svg",
            width: double.infinity,
            height: 300,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        final isUnread = !notification['read'];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          color: Colors.white,
          child: InkWell(
            onTap: () => _onNotificationTap(notification),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Notification Icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getNotificationIcon(notification['title'], notification['type']),
                      color: AppColors.primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Notification Content
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
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            if (isUnread)
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
                          style: AppTextStyles.smallText.copyWith(
                            color: AppColors.grey,
                          ),
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
    );
  }
}