// ugc_personal_task_controller.dart
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
}