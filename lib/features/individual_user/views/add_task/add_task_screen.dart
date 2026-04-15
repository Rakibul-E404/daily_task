import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_texts_style.dart';
import '../../../../utils/network/app_url.dart';
import '../../../../utils/network/network_caller_dio.dart';
import '../../../../utils/network/secure_storage_service.dart';
import '../home/task_details/model/sub_task_model.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateTimeController = TextEditingController();

  final List<SubTask> _subTasks = [];
  final List<TextEditingController> _subtaskControllers = [];
  final List<FocusNode> _subtaskFocusNodes = [];

  DateTime? _selectedDateTime;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Add initial empty subtask
    _addNewSubTask();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dateTimeController.dispose();
    for (final controller in _subtaskControllers) {
      controller.dispose();
    }
    for (final node in _subtaskFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: AppColors.black,
              onSurface: AppColors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: AppColors.primaryColor,
                onPrimary: AppColors.black,
                onSurface: AppColors.black,
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryColor,
                ),
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null && mounted) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          _dateTimeController.text =
              '${pickedDate.day}/${pickedDate.month}/${pickedDate.year} ${pickedTime.format(context)}';
        });
      }
    }
  }

  void _addNewSubTask() {
    setState(() {
      _subTasks.add(SubTask(title: ''));
      final controller = TextEditingController();
      final focusNode = FocusNode();

      // Add listener to auto-save when focus changes
      focusNode.addListener(() {
        if (!focusNode.hasFocus) {
          // Auto-save when focus is lost
          _autoSaveSubTask(_subTasks.length - 1, controller.text);
        }
      });

      _subtaskControllers.add(controller);
      _subtaskFocusNodes.add(focusNode);
    });
  }

  void _autoSaveSubTask(int index, String text) {
    final trimmedText = text.trim();
    if (trimmedText.isNotEmpty) {
      setState(() {
        _subTasks[index] = _subTasks[index].copyWith(title: trimmedText);
      });
    }
  }

  void _removeSubTask(int index) {
    setState(() {
      _subtaskControllers[index].dispose();
      _subtaskFocusNodes[index].dispose();
      _subTasks.removeAt(index);
      _subtaskControllers.removeAt(index);
      _subtaskFocusNodes.removeAt(index);
    });

    // Show snackbar for feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Subtask removed'),
        duration: Duration(seconds: 1),
        backgroundColor: Colors.black,
      ),
    );
  }

  // Save all subtasks before creating main task
  void _saveAllSubtasks() {
    for (int i = 0; i < _subtaskControllers.length; i++) {
      final text = _subtaskControllers[i].text.trim();
      if (text.isNotEmpty) {
        _subTasks[i] = _subTasks[i].copyWith(title: text);
      }
    }
  }

  // Helper method to clear all fields
  void _clearAllFields() {
    _titleController.clear();
    _descriptionController.clear();
    _dateTimeController.clear();
    _selectedDateTime = null;

    // Clear all subtasks
    for (final controller in _subtaskControllers) {
      controller.dispose();
    }
    for (final node in _subtaskFocusNodes) {
      node.dispose();
    }
    _subTasks.clear();
    _subtaskControllers.clear();
    _subtaskFocusNodes.clear();

    // Add a new empty subtask
    _addNewSubTask();
  }

  // Format DateTime to API format (ISO 8601)
  String _formatDateTimeForApi(DateTime dateTime) {
    return dateTime.toUtc().toIso8601String();
  }

  // Format time to 12-hour format
  String _formatTo12HourFormat(DateTime dateTime) {
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

  // Create task API call
  Future<void> _createTask() async {
    // Save all subtasks first
    _saveAllSubtasks();

    // Filter out empty subtasks
    final validSubtasks = _subTasks
        .where((s) => s.title.trim().isNotEmpty)
        .toList();

    // Validate required fields
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter task title'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select date and time'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final token = await SecureStorageService.instance.getAccessToken();

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No access token found. Please login again.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Prepare subtasks list
      final List<Map<String, dynamic>> subtasksList = [];
      for (int i = 0; i < validSubtasks.length; i++) {
        final subtask = validSubtasks[i];
        subtasksList.add({"title": subtask.title.trim(), "order": i + 1});
      }

      // Prepare request body
      final Map<String, dynamic> requestBody = {
        "title": _titleController.text.trim(),
        "description": _descriptionController.text.trim(),
        "taskType": "personal",
        "startTime": _formatDateTimeForApi(_selectedDateTime!),
        "scheduledTime": _formatTo12HourFormat(_selectedDateTime!),
        "dueDate": _formatDateTimeForApi(
          DateTime(
            _selectedDateTime!.year,
            _selectedDateTime!.month,
            _selectedDateTime!.day,
            23,
            59,
            59,
          ),
        ),
      };

      if (subtasksList.isNotEmpty) {
        requestBody["subtasks"] = subtasksList;
      }

      print('🌐 Making POST request to: ${AppUrl.createPersonalTask}');
      print('📦 Request body: $requestBody');

      final response = await _networkCaller.postRequest(
        AppUrl.createPersonalTask,
        body: requestBody,
        headers: {'Authorization': 'Bearer $token'},
      );

      print('📡 Response status code: ${response.statusCode}');
      print('📡 Response success: ${response.isSuccess}');

      if (response.isSuccess) {
        // Clear all fields after successful creation
        _clearAllFields();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task created successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.errorMessage ?? 'Failed to create task'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error creating task: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          toolbarHeight: 70,
          backgroundColor: AppColors.backgroundColor,
          surfaceTintColor: AppColors.transparent,
          title: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add New Task',
                    style: AppTextStyles.largeHeading.copyWith(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'You can add 3 to 5 more tasks today!',
                    style: AppTextStyles.smallText.copyWith(fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Task Title
                    Text(
                      'Task Title',
                      style: AppTextStyles.smallHeading.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: 'Type now',
                        hintStyle: AppTextStyles.defaultTextStyle,
                        filled: true,
                        fillColor: AppColors.backgroundColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.grey,
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.grey,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.grey,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      cursorColor: AppColors.primaryColor,
                      style: const TextStyle(color: Colors.black),
                    ),
                    const SizedBox(height: 24),

                    // Task Description
                    Text(
                      'Task Description',
                      style: AppTextStyles.smallHeading.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _descriptionController,
                      maxLength: 5000,
                      maxLines: 6,
                      cursorColor: AppColors.primaryColor,
                      decoration: InputDecoration(
                        hintText: 'What needs your attention?',
                        hintStyle: AppTextStyles.defaultTextStyle,
                        filled: true,
                        fillColor: AppColors.backgroundColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.grey,
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.grey,
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Task Date & Time
                    Text(
                      'Task Date & Time',
                      style: AppTextStyles.smallHeading.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _dateTimeController,
                      readOnly: true,
                      onTap: _selectDateTime,
                      decoration: InputDecoration(
                        hintText: '-- : -- --',
                        hintStyle: const TextStyle(
                          color: AppColors.grey,
                          fontSize: 15,
                        ),
                        filled: true,
                        fillColor: AppColors.backgroundColor,
                        suffixIcon: const Icon(
                          Icons.access_time,
                          color: Color(0xFF6B7280),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.grey,
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.grey,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.grey,
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Subtasks list - Auto-save on focus lost
                    ...List.generate(_subTasks.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.grey),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColor.withOpacity(
                                        0.5,
                                      ),
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
                                  // Trash icon for deleting subtask
                                  IconButton(
                                    onPressed: () => _removeSubTask(index),
                                    icon: Icon(
                                      CupertinoIcons.trash,
                                      size: 18,
                                      color: AppColors.iconColor,
                                    ),
                                    constraints: const BoxConstraints(),
                                    padding: EdgeInsets.zero,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _subtaskControllers[index],
                                focusNode: _subtaskFocusNodes[index],
                                maxLength: 30,
                                maxLines: null,
                                minLines: 1,
                                decoration: const InputDecoration(
                                  hintText: 'Enter Sub Task Details',
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(color: AppColors.grey),
                                ),
                                onSubmitted: (value) {
                                  // Auto-save when user presses enter
                                  if (value.trim().isNotEmpty) {
                                    _autoSaveSubTask(index, value);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 20),

                    // Add Sub Task Button
                    GestureDetector(
                      onTap: _addNewSubTask,
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
                            const Icon(Icons.add, color: AppColors.black),
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
                    const SizedBox(height: 20),

                    // Create Task Button
                    SizedBox(
                      height: 60,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _createTask,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            // ? const CircularProgressIndicator(color: Colors.white)
                            ? Text(
                                'Creating Task...',
                                style: AppTextStyles.defaultTextStyle.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              )
                            : Text(
                                'Create Task',
                                style: AppTextStyles.defaultTextStyle.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
