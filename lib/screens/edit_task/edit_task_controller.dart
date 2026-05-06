import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/network/app_url.dart';
import '../../../../utils/network/network_caller_dio.dart';
import '../../../../utils/network/secure_storage_service.dart';
import '../../features/individual_user/views/home/task_details/model/sub_task_model.dart';

class EditTaskController extends GetxController {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();

  var isUpdating = false.obs;
  var errorMessage = RxString('');

  /// PUT /tasks/:id/v2
  ///
  /// Postman-spec body shape:
  /// {
  ///   "title": "...",
  ///   "description": "...",
  ///   "status": "pending",
  ///   "updatedSubTasks": [ { "_id": "", "title": "", "isCompleted": true,  "order": 1 } ],
  ///   "addSubtasks":     [ { "title": "",             "isCompleted": false, "order": 3 } ],
  ///   "deletedSubtaskIds": ["id1", "id2"]
  /// }
  ///
  /// Rules strictly followed:
  ///  1. updatedSubTasks / addSubtasks / deletedSubtaskIds are OMITTED when empty.
  ///  2. Only subtasks whose title OR isCompleted changed go into updatedSubTasks.
  ///  3. priority / scheduledTime / dueDate are NOT in the spec — excluded to
  ///     avoid unintended server-side overwrites.
  Future<bool> updateTask({
    required String taskId,
    required String title,
    required String description,
    required String status,
    required List<SubTask> originalSubtasks, // server state before edits
    required List<SubTask> currentSubtasks,  // state after user edits
    required List<String> deletedSubtaskIds, // ids explicitly removed by user
  }) async {
    isUpdating.value = true;
    errorMessage.value = '';

    try {
      final token = await SecureStorageService.instance.getAccessToken();
      if (token == null) {
        errorMessage.value = 'No access token found';
        isUpdating.value = false;
        return false;
      }

      // ── Scalar fields (always sent) ─────────────────────────────────
      final Map<String, dynamic> body = {
        'title': title,
        'description': description,
        'status': status,
      };

      // ── Build a quick lookup of originals by id ─────────────────────
      // SubTask.id is populated from '_subTaskId' in the API response
      // (see the fix in TaskDetailsScreenController._mapApiResponseToTask).
      final Map<String, SubTask> originalById = {
        for (final sub in originalSubtasks)
          if (sub.id != null && sub.id!.isNotEmpty) sub.id!: sub,
      };

      // ── Diff current vs original ────────────────────────────────────
      final List<Map<String, dynamic>> updatedSubTasks = [];
      final List<Map<String, dynamic>> addSubtasks = [];

      for (int i = 0; i < currentSubtasks.length; i++) {
        final sub = currentSubtasks[i];
        final hasRealId = sub.id != null && sub.id!.isNotEmpty;

        if (hasRealId) {
          // Existing subtask — only include when something changed
          final original = originalById[sub.id];
          final titleChanged     = original == null || original.title       != sub.title;
          final completedChanged = original == null || original.isCompleted != sub.isCompleted;

          if (titleChanged || completedChanged) {
            updatedSubTasks.add({
              '_id':         sub.id,          // spec uses '_id' as the key
              'title':       sub.title,
              'isCompleted': sub.isCompleted,
              'order':       i + 1,
            });
          }
        } else {
          // New subtask (no server id yet) — skip blank entries
          if (sub.title.isNotEmpty) {
            addSubtasks.add({
              'title':       sub.title,
              'isCompleted': sub.isCompleted,
              'order':       i + 1,
            });
          }
        }
      }

      // Only attach arrays when they have content (never send empty [])
      if (updatedSubTasks.isNotEmpty)   body['updatedSubTasks']   = updatedSubTasks;
      if (addSubtasks.isNotEmpty)       body['addSubtasks']       = addSubtasks;
      if (deletedSubtaskIds.isNotEmpty) body['deletedSubtaskIds'] = deletedSubtaskIds;

      debugPrint('📤 EditTask URL : ${AppUrl.editTask(taskId)}');
      debugPrint('📤 EditTask body: $body');

      final response = await _networkCaller.putRequest(
        AppUrl.editTask(taskId),
        body: body,
        headers: {'Authorization': 'Bearer $token'},
      );

      debugPrint('📡 EditTask status : ${response.statusCode}');
      debugPrint('📡 EditTask success: ${response.isSuccess}');

      if (response.isSuccess || response.statusCode == 200) {
        isUpdating.value = false;
        return true;
      } else {
        String error = response.errorMessage ?? 'Failed to update task';
        if (response.jsonResponse != null) {
          error = response.jsonResponse?['message'] ?? error;
        }
        errorMessage.value = error;
        isUpdating.value = false;
        return false;
      }
    } catch (e) {
      debugPrint('Error updating task: $e');
      errorMessage.value = 'An error occurred. Please try again.';
      isUpdating.value = false;
      return false;
    }
  }
}