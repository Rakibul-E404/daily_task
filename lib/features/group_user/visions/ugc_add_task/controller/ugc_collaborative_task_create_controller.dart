// ugc_collaborative_task_controller.dart
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../../../../utils/network/app_url.dart';
import '../../../../../utils/network/network_caller_dio.dart';
import '../../../../../utils/network/secure_storage_service.dart';
import '../../ugc_home/ugc_task_details/ugc_task_model/ugc_sub_task_model.dart';

class UgcSingleCollaborativeTaskController extends GetxController {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();

  var isLoading = false.obs;
  var errorMessage = RxString('');

  Future<bool> createCollaborativeTask({
    required String title,
    required String description,
    required String scheduledTime,
    required DateTime startDateTime,
    required DateTime dueDate,
    required List<String> assignedUserIds,
    required List<UgcSubTask> subtasks,
    required String taskType, // 'collaborative' or 'singleAssignment'
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final token = await SecureStorageService.instance.getAccessToken();

      if (token == null) {
        errorMessage.value = 'No access token found. Please login again.';
        print('No access token found');
        isLoading.value = false;
        return false;
      }

      // Format subtasks with order - only include non-empty subtasks
      final List<Map<String, dynamic>> formattedSubtasks = [];
      for (int i = 0; i < subtasks.length; i++) {
        final titleText = subtasks[i].title.trim();
        if (titleText.isNotEmpty) {
          formattedSubtasks.add({
            "title": titleText,
            "order": i + 1,
          });
        }
      }

      // Format dates to ISO string
      final String formattedStartTime = startDateTime.toIso8601String();
      final String formattedDueDate = dueDate.toIso8601String();

      // Prepare request body
      final Map<String, dynamic> requestBody = {
        "title": title.trim(),
        "description": description.trim(),
        "taskType": taskType,
        "priority": "medium",
        "startTime": formattedStartTime,
        "scheduledTime": scheduledTime,
        "assignedUserIds": assignedUserIds,
        "dueDate": formattedDueDate,
        "subtasks": formattedSubtasks,
      };

      // Remove subtasks if empty to avoid sending empty array
      if (formattedSubtasks.isEmpty) {
        requestBody.remove('subtasks');
      }

      print('📤 Creating $taskType task: $requestBody');

      // Choose the appropriate API endpoint based on task type
      final String apiUrl = taskType == 'collaborative'
          ? AppUrl.createCollaborativeTask
          : AppUrl.createSingleAssignmentTask;

      final response = await _networkCaller.postRequest(
        apiUrl,
        body: requestBody,
        headers: {'Authorization': 'Bearer $token'},
      );

      print('📡 Response status code: ${response.statusCode}');
      print('📡 Response success: ${response.isSuccess}');
      print('📡 Response body: ${response.jsonResponse}');

      // Check for success (status code 200, 201, or success flag true)
      if (response.isSuccess || response.statusCode == 201) {
        isLoading.value = false;
        return true;
      } else {
        // Extract error message from API response
        String error = 'Failed to create task';

        if (response.jsonResponse != null) {
          final jsonData = response.jsonResponse!;

          if (jsonData.containsKey('message')) {
            error = jsonData['message'].toString();
          } else if (jsonData.containsKey('error')) {
            final errorData = jsonData['error'];
            if (errorData is List && errorData.isNotEmpty) {
              if (errorData[0].containsKey('message')) {
                error = errorData[0]['message'].toString();
              }
            } else if (errorData is Map && errorData.containsKey('message')) {
              error = errorData['message'].toString();
            }
          }
        }

        errorMessage.value = error;
        isLoading.value = false;
        return false;
      }
    } on DioException catch (e) {
      print('DioException: ${e.type} - ${e.message}');

      String error = 'Network error. Please check your connection.';

      if (e.response?.data != null) {
        try {
          final responseData = e.response?.data;
          if (responseData is Map) {
            if (responseData.containsKey('message')) {
              error = responseData['message'].toString();
            } else if (responseData.containsKey('error')) {
              final errorData = responseData['error'];
              if (errorData is List && errorData.isNotEmpty) {
                if (errorData[0].containsKey('message')) {
                  error = errorData[0]['message'].toString();
                }
              }
            }
          }
        } catch (_) {}
      }

      errorMessage.value = error;
      isLoading.value = false;
      return false;
    } catch (e) {
      print('Error creating task: $e');
      errorMessage.value = 'An error occurred. Please try again.';
      isLoading.value = false;
      return false;
    }
  }
}