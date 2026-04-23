import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../../utils/app_colors.dart';
import '../../../../../utils/app_texts_style.dart';
import '../../features/group_user/visions/ugc_home/ugc_task_details/ugc_task_model/ugc_sub_task_model.dart';
import '../../features/group_user/visions/ugc_home/ugc_task_details/ugc_task_model/ugc_task_model.dart';
import 'ugc_edit_task_screen_controller.dart';

class UgcEditTaskScreen extends StatefulWidget {
  final UgcTask originalTask;

  const UgcEditTaskScreen({super.key, required this.originalTask});

  @override
  State<UgcEditTaskScreen> createState() => _UgcEditTaskScreenState();
}

class _UgcEditTaskScreenState extends State<UgcEditTaskScreen> {
  late final UgcEditTaskController _editController;

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  /// Working copy — existing subtasks keep their server id; new ones have empty id.
  late List<UgcSubTask> _editableSubTasks;
  late List<TextEditingController> _subtaskControllers;
  late List<FocusNode> _subtaskFocusNodes;

  /// Server ids of subtasks the user explicitly deleted.
  final List<String> _deletedSubtaskIds = [];

  late DateTime _selectedDateTime;
  late TaskStatus _selectedStatus;
  late String _selectedPriority;

  @override
  void initState() {
    super.initState();
    _editController = Get.put(UgcEditTaskController());

    _titleController =
        TextEditingController(text: widget.originalTask.title);
    _descriptionController =
        TextEditingController(text: widget.originalTask.description);

    _selectedDateTime = widget.originalTask.startTime;

    _selectedStatus = widget.originalTask.status;

    // Normalize priority — guard against null / wrong casing from API
    const validPriorities = {'low', 'medium', 'high'};
    final rawPriority = widget.originalTask.priority.trim().toLowerCase();
    _selectedPriority =
        validPriorities.contains(rawPriority) ? rawPriority : 'medium';

    // Preserve server ids so diff logic works correctly
    _editableSubTasks = widget.originalTask.subtasks
        .map((sub) => UgcSubTask(
              id: sub.id,
              title: sub.title,
              isCompleted: sub.isCompleted,
              duration: sub.duration,
            ))
        .toList();

    _subtaskControllers =
        _editableSubTasks.map((s) => TextEditingController(text: s.title)).toList();

    _subtaskFocusNodes = _editableSubTasks.map((_) {
      final node = FocusNode();
      node.addListener(() => setState(() {}));
      return node;
    }).toList();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    for (final c in _subtaskControllers) c.dispose();
    for (final n in _subtaskFocusNodes)  n.dispose();
    super.dispose();
  }

  // ── Date / time picker ─────────────────────────────────────────────
  Future<void> _selectDateTime(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.primaryColor,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: AppColors.black,
          ),
          dialogBackgroundColor: Colors.white,
        ),
        child: child!,
      ),
    );

    if (selectedDate != null) {
      final selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
        builder: (ctx, child) => Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        ),
      );

      if (selectedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            selectedTime.hour,
            selectedTime.minute,
          );
        });
      }
    }
  }

  // ── Subtask helpers ────────────────────────────────────────────────
  void _confirmDeleteSubtask(int index) {
    // Capture by value — safe even if list mutates later
    final subtaskToDelete = _editableSubTasks[index];
    final subtaskIndex    = index;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppColors.lightGrey,
              ),
              height: 8,
              width: 50,
            ),
            const SizedBox(height: 32),
            Icon(CupertinoIcons.trash, size: 80, color: AppColors.primaryColor),
            const SizedBox(height: 16),
            Text('Delete subtask?', style: AppTextStyles.smallHeading),
            const SizedBox(height: 8),
            Text(
              'Are you sure you want to delete this subtask?',
              textAlign: TextAlign.center,
              style: AppTextStyles.defaultTextStyle
                  .copyWith(color: AppColors.grey),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppColors.backgroundColor,
                      side: BorderSide(color: AppColors.primaryColor),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text('No',
                        style: AppTextStyles.defaultTextStyle
                            .copyWith(color: AppColors.primaryColor)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      _removeSubtask(subtaskIndex, subtaskToDelete);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text('Yes',
                        style: AppTextStyles.defaultTextStyle
                            .copyWith(color: AppColors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addNewSubtask() {
    final node = FocusNode();
    node.addListener(() => setState(() {}));

    setState(() {
      _editableSubTasks.add(UgcSubTask(id: '', title: '', isCompleted: false));
      _subtaskControllers.add(TextEditingController());
      _subtaskFocusNodes.add(node);
    });
  }

  void _removeSubtask(int index, UgcSubTask subtask) {
    if (subtask.id.isNotEmpty) {
      _deletedSubtaskIds.add(subtask.id);
      debugPrint(
          '🗑️ Queued for deletion: ${subtask.id}  (total: ${_deletedSubtaskIds.length})');
    }
    setState(() {
      _subtaskFocusNodes[index].dispose();
      _subtaskFocusNodes.removeAt(index);
      _editableSubTasks.removeAt(index);
      _subtaskControllers.removeAt(index).dispose();
    });
  }

  void _saveSubtask(int index) {
    _editableSubTasks[index] = UgcSubTask(
      id: _editableSubTasks[index].id,
      title: _subtaskControllers[index].text.trim(),
      isCompleted: _editableSubTasks[index].isCompleted,
      duration: _editableSubTasks[index].duration,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Subtask saved'),
        duration: const Duration(seconds: 1),
        backgroundColor: AppColors.black,
      ),
    );
    _subtaskFocusNodes[index].unfocus();
  }

  // ── Save ───────────────────────────────────────────────────────────
  Future<void> _saveTask() async {
    if (_titleController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter task title',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    // Sync latest text into _editableSubTasks before diffing
    for (int i = 0; i < _editableSubTasks.length; i++) {
      _editableSubTasks[i] = UgcSubTask(
        id: _editableSubTasks[i].id,
        title: _subtaskControllers[i].text.trim(),
        isCompleted: _editableSubTasks[i].isCompleted,
        duration: _editableSubTasks[i].duration,
      );
    }

    // Drop new (no-id) subtasks that were left blank
    final currentSubtasks = _editableSubTasks.where((sub) {
      final isNew = sub.id.isEmpty;
      return !isNew || sub.title.isNotEmpty;
    }).toList();

    debugPrint('📤 UGC deletedSubtaskIds at save: $_deletedSubtaskIds');

    final success = await _editController.updateTask(
      taskId: widget.originalTask.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      status: _statusToString(_selectedStatus),
      originalSubtasks: widget.originalTask.subtasks,
      currentSubtasks: currentSubtasks,
      deletedSubtaskIds: _deletedSubtaskIds,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task updated successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      // Pop with true — caller will re-fetch from server
      Get.back(result: true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_editController.errorMessage.value),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────
  String _statusToString(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:    return 'pending';
      case TaskStatus.inProgress: return 'inProgress';
      case TaskStatus.completed:  return 'completed';
    }
  }

  String _formatDateTime(DateTime dt) =>
      DateFormat('dd/MM/yyyy - hh:mm a').format(dt);

  String _getStatusText(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:    return 'Pending';
      case TaskStatus.inProgress: return 'In Progress';
      case TaskStatus.completed:  return 'Completed';
    }
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:    return AppColors.pendingStatusColor;
      case TaskStatus.inProgress: return AppColors.inProgressStatusColor;
      case TaskStatus.completed:  return AppColors.completedStatusColor;
    }
  }

  // ── Build ──────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text('Edit Task', style: AppTextStyles.smallHeading),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_outlined),
          onPressed: () => Get.back(),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Task Title ─────────────────────────────────────────
              Text('Task Title', style: AppTextStyles.smallHeading),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Enter Title',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.lightGrey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.primaryColor),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                ),
                style: AppTextStyles.defaultTextStyle,
              ),

              const SizedBox(height: 20),

              // ── Task Description ───────────────────────────────────
              Text('Task Description', style: AppTextStyles.smallHeading),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                minLines: 4,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Enter Description',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: AppColors.lightGrey.withValues(alpha: 0.7)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.primaryColor),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 16),
                ),
                style: AppTextStyles.defaultTextStyle,
              ),

              const SizedBox(height: 20),

              // ── Task Status ────────────────────────────────────────
              Text('Task Status', style: AppTextStyles.smallHeading),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.grey),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<TaskStatus>(
                    value: _selectedStatus,
                    isExpanded: true,
                    items: TaskStatus.values.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _getStatusColor(status),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(_getStatusText(status),
                                style: AppTextStyles.defaultTextStyle),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedStatus = value);
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Task Priority ──────────────────────────────────────
              Text('Task Priority', style: AppTextStyles.smallHeading),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.grey),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedPriority,
                    isExpanded: true,
                    items: ['low', 'medium', 'high'].map((priority) {
                      return DropdownMenuItem(
                        value: priority,
                        child: Row(
                          children: [
                            Icon(
                              priority == 'high'
                                  ? Icons.flag
                                  : Icons.flag_outlined,
                              color: priority == 'high'
                                  ? Colors.red
                                  : priority == 'medium'
                                      ? Colors.orange
                                      : Colors.green,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              priority.toUpperCase(),
                              style: AppTextStyles.defaultTextStyle.copyWith(
                                color: priority == 'high'
                                    ? Colors.red
                                    : priority == 'medium'
                                        ? Colors.orange
                                        : Colors.green,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedPriority = value);
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Task Date & Time ───────────────────────────────────
              Text('Task Date & Time', style: AppTextStyles.smallHeading),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _selectDateTime(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.grey),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDateTime(_selectedDateTime),
                        style: AppTextStyles.defaultTextStyle
                            .copyWith(color: AppColors.black),
                      ),
                      Icon(Icons.access_time_outlined,
                          color: AppColors.iconColor),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Subtasks ───────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Sub Tasks', style: AppTextStyles.smallHeading),
                  if (_editableSubTasks.isNotEmpty)
                    Text(
                      '${_editableSubTasks.where((s) => s.title.isNotEmpty).length} tasks',
                      style: AppTextStyles.smallText,
                    ),
                ],
              ),
              const SizedBox(height: 12),

              ...List.generate(_editableSubTasks.length, (index) {
                final hasFocus = _subtaskFocusNodes[index].hasFocus;
                final hasText  = _subtaskControllers[index].text.isNotEmpty;
                final showSave = hasFocus && hasText;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.grey),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor
                                    .withOpacity(0.5),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Sub Task ${index + 1}',
                                style: AppTextStyles.smallText.copyWith(
                                  color: AppColors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _subtaskControllers[index],
                                focusNode: _subtaskFocusNodes[index],
                                decoration: const InputDecoration(
                                  hintText: 'Enter Sub Task Details',
                                  border: InputBorder.none,
                                  hintStyle:
                                      TextStyle(color: AppColors.grey),
                                ),
                              ),
                            ),
                            // Trash / Save icon — reads focus from state,
                            // always current (no ValueListenableBuilder bug)
                            IconButton(
                              onPressed: () {
                                if (showSave) {
                                  _saveSubtask(index);
                                } else {
                                  _confirmDeleteSubtask(index);
                                }
                              },
                              icon: Icon(
                                showSave
                                    ? Icons.check
                                    : CupertinoIcons.trash,
                                color: showSave
                                    ? AppColors.primaryColor
                                    : AppColors.iconColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),

              // ── Add Sub Task ───────────────────────────────────────
              GestureDetector(
                onTap: _addNewSubtask,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.mainBottomNavColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.lightGrey),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, color: AppColors.black),
                      const SizedBox(width: 6),
                      Text(
                        'Add Sub Task',
                        style: AppTextStyles.defaultTextStyle.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // ── Update Button ──────────────────────────────────────
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _editController.isUpdating.value
                        ? null
                        : _saveTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _editController.isUpdating.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Text(
                            'Update Task',
                            style: AppTextStyles.defaultTextStyle.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
