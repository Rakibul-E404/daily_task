/**
import 'package:get/get.dart';
import '../../../../../utils/network/app_url.dart';
import '../../../../../utils/network/network_caller_dio.dart';
import '../../../../../utils/network/secure_storage_service.dart';
import '../../ugc_home/ugc_task_details/ugc_task_model/ugc_sub_task_model.dart';

class UgcPersonalTaskCreateController extends GetxController {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();

  var isLoading = false.obs;
  var errorMessage = RxString('');

  Future<bool> createPersonalTask({
    required String title,
    required String description,
    required String scheduledTime,
    required DateTime startDateTime,
    required DateTime dueDate,
    required List<UgcSubTask> subtasks,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final token = await SecureStorageService.instance.getAccessToken();

      if (token == null) {
        errorMessage.value = 'No access token found';
        print('No access token found');
        return false;
      }

      // Format subtasks with order
      final List<Map<String, dynamic>> formattedSubtasks = [];
      for (int i = 0; i < subtasks.length; i++) {
        if (subtasks[i].title.trim().isNotEmpty) {
          formattedSubtasks.add({
            "title": subtasks[i].title.trim(),
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
        "taskType": "personal",
        "priority": "medium",
        "startTime": formattedStartTime,
        "scheduledTime": scheduledTime,
        "dueDate": formattedDueDate,
        "subtasks": formattedSubtasks,
      };

      print('📤 Creating personal task: $requestBody');

      final response = await _networkCaller.postRequest(
        AppUrl.createPersonalTask,
        body: requestBody,
        headers: {'Authorization': 'Bearer $token'},
      );

      print('📡 Response status code: ${response.statusCode}');
      print('📡 Response success: ${response.isSuccess}');
      print('📡 Response body: ${response.jsonResponse}');

      if (response.isSuccess) {
        isLoading.value = false;
        return true;
      } else {
        errorMessage.value = response.errorMessage ?? 'Failed to create task';
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      print('Error creating personal task: $e');
      errorMessage.value = 'An error occurred. Please try again.';
      isLoading.value = false;
      return false;
    }
  }
}*/















import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../../../../utils/network/app_url.dart';
import '../../../../../utils/network/network_caller_dio.dart';
import '../../../../../utils/network/secure_storage_service.dart';
import '../../ugc_home/ugc_task_details/ugc_task_model/ugc_sub_task_model.dart';

class UgcPersonalTaskCreateController extends GetxController {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();

  var isLoading = false.obs;
  var errorMessage = RxString('');

  Future<bool> createPersonalTask({
    required String title,
    required String description,
    required String scheduledTime,
    required DateTime startDateTime,
    required DateTime dueDate,
    required List<UgcSubTask> subtasks,
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
        "taskType": "personal",
        "priority": "medium",
        "startTime": formattedStartTime,
        "scheduledTime": scheduledTime,
        "dueDate": formattedDueDate,
        "subtasks": formattedSubtasks,
      };

      // Remove subtasks if empty to avoid sending empty array
      if (formattedSubtasks.isEmpty) {
        requestBody.remove('subtasks');
      }

      print('📤 Creating personal task: $requestBody');

      final response = await _networkCaller.postRequest(
        AppUrl.createPersonalTask,
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
        // Get the exact message from API response
        String error = 'Failed to create task';

        if (response.jsonResponse != null) {
          // Try to get message from response
          error = response.jsonResponse?['message'] ?? error;

          // If message is inside data.attributes
          if (response.jsonResponse?['data']?['attributes']?['message'] != null) {
            error = response.jsonResponse?['data']?['attributes']?['message'];
          }

          // If there's an error object
          if (response.jsonResponse?['error'] != null) {
            error = response.jsonResponse?['error'];
          }
        }

        errorMessage.value = error;
        isLoading.value = false;
        return false;
      }
    } on DioException catch (e) {
      print('DioException: ${e.type} - ${e.message}');

      String error = 'Network error. Please check your connection.';

      // Try to get error message from response body
      if (e.response?.data != null) {
        try {
          final responseData = e.response?.data;
          if (responseData is Map) {
            error = responseData['message'] ??
                responseData['error'] ??
                error;
          }
        } catch (_) {}
      }

      errorMessage.value = error;
      isLoading.value = false;
      return false;
    } catch (e) {
      print('Error creating personal task: $e');
      errorMessage.value = 'An error occurred. Please try again.';
      isLoading.value = false;
      return false;
    }
  }
}