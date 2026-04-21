/**
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
        // Extract error message from API response
        String error = 'Failed to create task';

        // Print the actual response to debug
        print('🔍 Response jsonResponse: ${response.jsonResponse}');

        if (response.jsonResponse != null) {
          final jsonData = response.jsonResponse!;

          // Try to get message from different possible locations
          if (jsonData.containsKey('message')) {
            error = jsonData['message'].toString();
          }
          else if (jsonData.containsKey('error')) {
            final errorData = jsonData['error'];
            if (errorData is List && errorData.isNotEmpty) {
              if (errorData[0].containsKey('message')) {
                error = errorData[0]['message'].toString();
              } else {
                error = errorData.toString();
              }
            } else if (errorData is Map && errorData.containsKey('message')) {
              error = errorData['message'].toString();
            } else {
              error = errorData.toString();
            }
          }
          else if (jsonData.containsKey('data') && jsonData['data'] != null) {
            final data = jsonData['data'];
            if (data is Map) {
              if (data.containsKey('attributes') && data['attributes'] != null) {
                final attributes = data['attributes'];
                if (attributes.containsKey('message')) {
                  error = attributes['message'].toString();
                }
              }
            }
          }
        }

        print('📢 Extracted error message: $error');
        errorMessage.value = error;
        isLoading.value = false;
        return false;
      }
    } on DioException catch (e) {
      print('DioException: ${e.type} - ${e.message}');
      print('Dio response data: ${e.response?.data}');

      String error = 'Network error. Please check your connection.';

      // Try to get error message from Dio response
      if (e.response?.data != null) {
        try {
          final responseData = e.response?.data;
          if (responseData is Map) {
            if (responseData.containsKey('message')) {
              error = responseData['message'].toString();
            }
            else if (responseData.containsKey('error')) {
              final errorData = responseData['error'];
              if (errorData is List && errorData.isNotEmpty) {
                if (errorData[0].containsKey('message')) {
                  error = errorData[0]['message'].toString();
                }
              } else if (errorData is Map && errorData.containsKey('message')) {
                error = errorData['message'].toString();
              }
            }
          }
        } catch (_) {}
      }

      print('📢 Extracted error from Dio: $error');
      errorMessage.value = error;
      isLoading.value = false;
      return false;
    } catch (e) {
      print('Error creating personal task: $e');
      errorMessage.value = 'Failed to create task. Please try again.';
      isLoading.value = false;
      return false;
    }
  }
}*/












///
///
///
/// todo:: updating data pass
///
///
///




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

      // Format dueDate to ISO string (end of the selected day)
      final String formattedDueDate = dueDate.toUtc().toIso8601String();

      // Prepare request body - WITHOUT startTime
      final Map<String, dynamic> requestBody = {
        "title": title.trim(),
        "description": description.trim(),
        "taskType": "personal",
        "priority": "medium",
        "scheduledTime": scheduledTime,
        "dueDate": formattedDueDate,
      };

      // Add subtasks only if there are any
      if (formattedSubtasks.isNotEmpty) {
        requestBody["subtasks"] = formattedSubtasks;
      }

      print('📤 Creating personal task');
      print('📤 Request body: $requestBody');
      print('📤 DueDate: $formattedDueDate');
      print('📤 ScheduledTime: $scheduledTime');

      final response = await _networkCaller.postRequest(
        AppUrl.createPersonalTask,
        body: requestBody,
        headers: {'Authorization': 'Bearer $token'},
      );

      print('📡 Response status code: ${response.statusCode}');
      print('📡 Response success: ${response.isSuccess}');
      print('📡 Response body: ${response.jsonResponse}');

      // Check for success (status code 200, 201, or success flag true)
      if (response.isSuccess || response.statusCode == 200 || response.statusCode == 201) {
        isLoading.value = false;
        return true;
      } else {
        // Extract error message from API response
        String error = 'Failed to create task';

        if (response.jsonResponse != null) {
          final jsonData = response.jsonResponse!;

          if (jsonData.containsKey('message')) {
            error = jsonData['message'].toString();
          }
          else if (jsonData.containsKey('error')) {
            final errorData = jsonData['error'];
            if (errorData is List && errorData.isNotEmpty) {
              if (errorData[0].containsKey('message')) {
                error = errorData[0]['message'].toString();
              } else {
                error = errorData.toString();
              }
            } else if (errorData is Map && errorData.containsKey('message')) {
              error = errorData['message'].toString();
            } else {
              error = errorData.toString();
            }
          }
        }

        errorMessage.value = error;
        isLoading.value = false;
        return false;
      }
    } on DioException catch (e) {
      print('DioException: ${e.type} - ${e.message}');
      print('Dio response data: ${e.response?.data}');

      String error = 'Network error. Please check your connection.';

      if (e.response?.data != null) {
        try {
          final responseData = e.response?.data;
          if (responseData is Map) {
            if (responseData.containsKey('message')) {
              error = responseData['message'].toString();
            }
          } else if (responseData is String) {
            error = responseData;
          }
        } catch (_) {}
      }

      errorMessage.value = error;
      isLoading.value = false;
      return false;
    } catch (e) {
      print('Error creating personal task: $e');
      errorMessage.value = 'Failed to create task. Please try again.';
      isLoading.value = false;
      return false;
    }
  }

  void resetForm() {
    errorMessage.value = '';
  }
}