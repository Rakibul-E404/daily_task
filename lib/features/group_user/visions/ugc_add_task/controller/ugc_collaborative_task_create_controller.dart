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

  var availableMembers = <Map<String, dynamic>>[].obs;
  var isLoadingMembers = false.obs;

  Future<bool> createCollaborativeTask({
    required String title,
    required String description,
    required String scheduledTime,
    required DateTime startDateTime,
    required DateTime dueDate,
    required List<String> assignedUserIds,
    required List<UgcSubTask> subtasks,
    required String taskType,
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

      final String formattedStartTime = startDateTime.toIso8601String();
      final String formattedDueDate = dueDate.toIso8601String();

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

      if (formattedSubtasks.isEmpty) {
        requestBody.remove('subtasks');
      }

      print('📤 Creating $taskType task: $requestBody');

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

      if (response.isSuccess || response.statusCode == 201) {
        isLoading.value = false;
        return true;
      } else {
        String error = 'Failed to create task';
        if (response.jsonResponse != null) {
          final jsonData = response.jsonResponse!;
          if (jsonData.containsKey('message')) {
            error = jsonData['message'].toString();
          }
        }
        errorMessage.value = error;
        isLoading.value = false;
        return false;
      }
    } on DioException catch (e) {
      print('DioException: ${e.type} - ${e.message}');
      errorMessage.value = 'Network error. Please check your connection.';
      isLoading.value = false;
      return false;
    } catch (e) {
      print('Error creating task: $e');
      errorMessage.value = 'An error occurred. Please try again.';
      isLoading.value = false;
      return false;
    }
  }

  // Helper method to get full image URL
  String getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return '';
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

  // Fetch family members from API
  Future<void> fetchFamilyMembers() async {
    isLoadingMembers.value = true;

    try {
      final token = await SecureStorageService.instance.getAccessToken();

      if (token == null) {
        print('No access token found');
        isLoadingMembers.value = false;
        return;
      }

      final response = await _networkCaller.getRequest(
        AppUrl.getMemberList,
        headers: {'Authorization': 'Bearer $token'},
      );

      print('📡 Family members response: ${response.isSuccess}');

      if (response.isSuccess && response.jsonResponse != null) {
        final attributes = response.jsonResponse?['data']?['attributes'];

        if (attributes != null) {
          final List<Map<String, dynamic>> members = [];

          // Add parent if exists - ONLY parent gets Primary badge
          final parent = attributes['parent'];
          if (parent != null) {
            String imageUrl = '';
            if (parent['profileImage'] != null && parent['profileImage']['imageUrl'] != null) {
              imageUrl = getImageUrl(parent['profileImage']['imageUrl']);
            }
            members.add({
              'id': parent['_id'] ?? '',
              'name': parent['name'] ?? '',
              'role': 'parent', // Only parent has role 'parent'
              'profileImage': imageUrl,
            });
          }

          // Add siblings/children - NO badge for them
          final siblings = attributes['siblings'] ?? [];
          for (var sibling in siblings) {
            String imageUrl = '';
            if (sibling['profileImage'] != null && sibling['profileImage']['imageUrl'] != null) {
              imageUrl = getImageUrl(sibling['profileImage']['imageUrl']);
            }
            members.add({
              'id': sibling['childUserId'] ?? sibling['_id'] ?? '',
              'name': sibling['name'] ?? '',
              'role': 'sibling', // Siblings have no badge
              'profileImage': imageUrl,
            });
          }

          availableMembers.value = members;
          print('✅ Fetched ${members.length} family members');
        }
      } else {
        print('❌ Failed to fetch family members: ${response.errorMessage}');
      }
    } catch (e) {
      print('Error fetching family members: $e');
    } finally {
      isLoadingMembers.value = false;
    }
  }
}