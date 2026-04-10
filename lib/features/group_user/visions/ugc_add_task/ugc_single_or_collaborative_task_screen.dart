import 'package:askfemi/utils/app_colors.dart';
import 'package:askfemi/utils/app_texts_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'controller/ugc_collaborative_task_create_controller.dart';
import '../ugc_home/ugc_task_details/ugc_task_model/ugc_sub_task_model.dart';

class UgcSingleOrCollaborativeTaskScreen extends StatefulWidget {
  const UgcSingleOrCollaborativeTaskScreen({super.key});

  @override
  State<UgcSingleOrCollaborativeTaskScreen> createState() =>
      _UgcSingleOrCollaborativeTaskScreenState();
}

class _UgcSingleOrCollaborativeTaskScreenState
    extends State<UgcSingleOrCollaborativeTaskScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController dateTimeController = TextEditingController();

  // List of selected members
  List<Map<String, dynamic>> members = [];

  // Subtask related variables
  final List<UgcSubTask> _subTasks = [];
  final List<TextEditingController> _subtaskControllers = [];
  final List<FocusNode> _subtaskFocusNodes = [];

  bool _isCollaborativeTask = true;
  bool _showMembers = true;

  DateTime? _selectedStartDateTime;
  DateTime? _selectedDueDate;
  String? _formattedScheduledTime;

  final UgcSingleCollaborativeTaskController _controller = Get.put(UgcSingleCollaborativeTaskController());

  @override
  void initState() {
    super.initState();
    _addNewSubTask();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    dateTimeController.dispose();
    for (final controller in _subtaskControllers) {
      controller.dispose();
    }
    for (final node in _subtaskFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _toggleTaskType() {
    setState(() {
      _isCollaborativeTask = !_isCollaborativeTask;
    });
  }

  // Show Add Member Dialog - Fetches members from API when opened
  void _showAddMemberDialog() async {
    // Show loading indicator while fetching members
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    // Fetch family members from API
    await _controller.fetchFamilyMembers();

    // Close loading dialog
    Navigator.of(context).pop();

    // Show member selection dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddMemberDialog(
          availableMembers: _controller.availableMembers.toList(),
          isCollaborativeTask: _isCollaborativeTask,
          onMembersAdded: (selectedMembers) {
            _handleMembersAdded(selectedMembers);
          },
        );
      },
    );
  }

  void _handleMembersAdded(List<Map<String, dynamic>> selectedMembers) {
    setState(() {
      for (var member in selectedMembers) {
        if (!members.any((m) => m['id'] == member['id'])) {
          members.add(member);
        }
      }
      _showMembers = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${selectedMembers.length} member(s) added successfully'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
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
              style: TextButton.styleFrom(foregroundColor: AppColors.primaryColor),
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
                style: TextButton.styleFrom(foregroundColor: AppColors.primaryColor),
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null && mounted) {
        setState(() {
          _selectedStartDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          _selectedDueDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            23,
            59,
            59,
          );
          _formattedScheduledTime = '${pickedTime.format(context)}';
          dateTimeController.text =
          '${pickedDate.day}/${pickedDate.month}/${pickedDate.year} ${pickedTime.format(context)}';
        });
      }
    }
  }

  void _addNewSubTask() {
    setState(() {
      _subTasks.add(UgcSubTask(title: ''));
      _subtaskControllers.add(TextEditingController());
      _subtaskFocusNodes.add(FocusNode());
    });
  }

  void _removeSubTask(int index) {
    setState(() {
      _subtaskControllers[index].dispose();
      _subtaskFocusNodes[index].dispose();
      _subTasks.removeAt(index);
      _subtaskControllers.removeAt(index);
      _subtaskFocusNodes.removeAt(index);
    });
  }

  void _saveSubTask(int index) {
    setState(() {
      _subTasks[index] = _subTasks[index].copyWith(
        title: _subtaskControllers[index].text.trim(),
      );
      _subtaskFocusNodes[index].unfocus();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Subtask saved'),
        duration: Duration(seconds: 1),
        backgroundColor: Colors.black,
      ),
    );
  }

  void _handleRemove(String memberId) {
    setState(() {
      members.removeWhere((member) => member['id'] == memberId);
    });
  }

  Future<void> _createTask() async {
    for (int i = 0; i < _subTasks.length; i++) {
      final currentText = _subtaskControllers[i].text.trim();
      if (currentText.isNotEmpty && _subTasks[i].title != currentText) {
        _subTasks[i] = _subTasks[i].copyWith(title: currentText);
      }
    }

    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a task title'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedStartDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select date and time'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (members.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one member'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    for (int i = 0; i < _subtaskFocusNodes.length; i++) {
      if (_subtaskFocusNodes[i].hasFocus) {
        final currentText = _subtaskControllers[i].text.trim();
        if (currentText.isNotEmpty) {
          _subTasks[i] = _subTasks[i].copyWith(title: currentText);
        }
        _subtaskFocusNodes[i].unfocus();
      }
    }

    final List<UgcSubTask> validSubtasks = _subTasks
        .where((task) => task.title.trim().isNotEmpty)
        .toList();

    final List<String> assignedUserIds = members.map((member) => member['id'].toString()).toList();

    final success = await _controller.createCollaborativeTask(
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      scheduledTime: _formattedScheduledTime ?? '',
      startDateTime: _selectedStartDateTime!,
      dueDate: _selectedDueDate!,
      assignedUserIds: assignedUserIds,
      subtasks: validSubtasks,
      taskType: _isCollaborativeTask ? 'collaborative' : 'singleAssignment',
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Get.back();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_controller.errorMessage.value),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        surfaceTintColor: AppColors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Create Task',
          style: AppTextStyles.smallHeading.copyWith(fontSize: 22),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add New Task',
              style: AppTextStyles.largeHeading,
            ),
            const SizedBox(height: 6),
            Text(
              'You can add 3 to 5 more tasks today!',
              style: AppTextStyles.defaultTextStyle,
            ),
            const SizedBox(height: 24),

            _label('Task Title'),
            _inputField(controller: titleController),

            const SizedBox(height: 20),

            _label('Task Description'),
            _inputField(
              controller: descriptionController,
              maxLines: 4,
            ),

            const SizedBox(height: 20),

            _label('Task Date & Time'),
            const SizedBox(height: 12),
            TextField(
              controller: dateTimeController,
              readOnly: true,
              onTap: _selectDateTime,
              cursorColor: AppColors.primaryColor,
              decoration: InputDecoration(
                hintText: 'Select Date & Time',
                hintStyle: AppTextStyles.defaultTextStyle.copyWith(color: AppColors.grey),
                filled: true,
                fillColor: AppColors.backgroundColor,
                suffixIcon: Icon(Icons.access_time, color: AppColors.iconColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.grey, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.grey, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.grey, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),

            const SizedBox(height: 24),

            /// Collaborative/Single Task Section
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blueAccent,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _isCollaborativeTask ? 'Collaborative Task' : 'Single Assignment',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: _toggleTaskType,
                        child: Icon(
                          Icons.swap_vert_outlined,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  if (_showMembers && members.isNotEmpty)
                    Wrap(
                      alignment: WrapAlignment.start,
                      spacing: 8,
                      runSpacing: 8,
                      children: members.map((member) {
                        return Container(
                          constraints: const BoxConstraints(maxWidth: 140),
                          child: _memberChip(
                            key: ValueKey(member['id']),
                            memberId: member['id'],
                            name: member['name'],
                            role: member['role'],
                            onRemove: _handleRemove,
                            imagePath: member['profileImage'],
                          ),
                        );
                      }).toList(),
                    ),

                  if (_showMembers && members.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'No members added yet',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: _showAddMemberDialog,
                      icon: const Icon(Icons.add, color: AppColors.white),
                      label: Text(
                        'Add Member',
                        style: AppTextStyles.defaultTextStyle
                            .copyWith(color: AppColors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// Subtasks list
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
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Sub Task',
                              style: AppTextStyles.smallText.copyWith(
                                color: AppColors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _subtaskControllers[index],
                              focusNode: _subtaskFocusNodes[index],
                              maxLines: null,
                              minLines: 1,
                              decoration: const InputDecoration(
                                hintText: 'Enter Sub Task Details',
                                border: InputBorder.none,
                                hintStyle: TextStyle(color: AppColors.grey),
                              ),
                            ),
                          ),
                          ValueListenableBuilder<TextEditingValue>(
                            valueListenable: _subtaskControllers[index],
                            builder: (context, value, child) {
                              final hasFocus = _subtaskFocusNodes[index].hasFocus;
                              final hasText = value.text.isNotEmpty;

                              return IconButton(
                                onPressed: () {
                                  if (hasFocus && hasText) {
                                    _saveSubTask(index);
                                  } else {
                                    _removeSubTask(index);
                                  }
                                },
                                icon: Icon(
                                  (hasFocus && hasText) ? Icons.check : CupertinoIcons.trash,
                                  color: (hasFocus && hasText)
                                      ? AppColors.primaryColor
                                      : AppColors.iconColor,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),

            /// Add Sub Task Button
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

            const SizedBox(height: 24),

            /// Create Task Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _controller.isLoading.value ? null : _createTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF60A5FA),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _controller.isLoading.value
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : Text(
                  'Create Task',
                  style: AppTextStyles.defaultTextStyle.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: AppTextStyles.smallHeading.copyWith(fontSize: 14),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.backgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.grey, width: 2),
        ),
      ),
    );
  }

  Widget _memberChip({
    Key? key,
    required String memberId,
    required String name,
    required String role,
    required Function(String) onRemove,
    String? imagePath,
  }) {
    return _MemberChipInternal(
      key: key,
      memberId: memberId,
      name: name,
      role: role,
      imagePath: imagePath,
      onRemove: onRemove,
    );
  }
}

// Internal stateful widget for handling removal animation with crown icon
class _MemberChipInternal extends StatefulWidget {
  final String memberId;
  final String name;
  final String role;
  final String? imagePath;
  final Function(String) onRemove;

  const _MemberChipInternal({
    Key? key,
    required this.memberId,
    required this.name,
    required this.role,
    required this.onRemove,
    this.imagePath,
  }) : super(key: key);

  @override
  State<_MemberChipInternal> createState() => __MemberChipInternalState();
}

class __MemberChipInternalState extends State<_MemberChipInternal> {
  bool _isRemoving = false;

  void _handleRemove() {
    if (_isRemoving) return;

    setState(() {
      _isRemoving = true;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      widget.onRemove(widget.memberId);
    });
  }

  @override
  Widget build(BuildContext context) {
    // ONLY show Primary badge if role is 'parent'
    final bool showPrimary = widget.role == 'parent';

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: _isRemoving ? 0 : 1,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 12,
              backgroundImage: widget.imagePath != null && widget.imagePath!.isNotEmpty
                  ? (widget.imagePath!.startsWith('http')
                  ? NetworkImage(widget.imagePath!)
                  : AssetImage(widget.imagePath!) as ImageProvider)
                  : const AssetImage("assets/images/dummy_child_user_image.png") as ImageProvider,
              onBackgroundImageError: (_, __) {},
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.name,
                    style: const TextStyle(fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  if (showPrimary)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 2),
                          child: SvgPicture.asset(
                            'assets/icons/crown.svg',
                            width: 10,
                            height: 10,
                          ),
                        ),
                        Text(
                          'Primary',
                          style: const TextStyle(fontSize: 9, color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: _handleRemove,
              child: const Icon(Icons.close, size: 14, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}

// Add Member Dialog
// Add Member Dialog
class AddMemberDialog extends StatefulWidget {
  final List<Map<String, dynamic>> availableMembers;
  final Function(List<Map<String, dynamic>>) onMembersAdded;
  final bool isCollaborativeTask;

  const AddMemberDialog({
    super.key,
    required this.availableMembers,
    required this.onMembersAdded,
    required this.isCollaborativeTask,
  });

  @override
  State<AddMemberDialog> createState() => _AddMemberDialogState();
}

class _AddMemberDialogState extends State<AddMemberDialog> {
  List<Map<String, dynamic>> selectedMembers = [];
  String searchQuery = '';

  List<Map<String, dynamic>> get filteredMembers {
    if (searchQuery.isEmpty) return widget.availableMembers;
    return widget.availableMembers
        .where((member) => member['name'].toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final String dialogTitle = widget.isCollaborativeTask
        ? 'Collaborative Task'
        : 'Single Assignment';

    final String subtitle = widget.isCollaborativeTask
        ? 'Add team members to collaborate'
        : 'Assign task to a member';

    return AlertDialog(
      actionsPadding: EdgeInsets.zero,
      backgroundColor: AppColors.backgroundColor,
      titlePadding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      contentPadding: EdgeInsets.zero,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            dialogTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Team Members (${widget.availableMembers.length})',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 400, // Fixed height for better scrollability
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.grey),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, size: 20, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search Member',
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.grey[500]),
                        ),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Divider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Divider(color: Colors.grey[300], height: 1),
            ),

            // Available Members List with Scrollbar
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Scrollbar(
                  thumbVisibility: true,
                  thickness: 4,
                  radius: const Radius.circular(8),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: filteredMembers.length,
                    itemBuilder: (context, index) {
                      final member = filteredMembers[index];
                      final isSelected = selectedMembers.any((m) => m['id'] == member['id']);
                      final bool showPrimary = member['role'] == 'parent';

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            visualDensity: const VisualDensity(vertical: -2),
                            leading: CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.blue[100],
                              backgroundImage: member['profileImage'] != null && member['profileImage'].toString().isNotEmpty
                                  ? (member['profileImage'].toString().startsWith('http')
                                  ? NetworkImage(member['profileImage'])
                                  : AssetImage(member['profileImage']) as ImageProvider)
                                  : const AssetImage("assets/images/dummy_child_user_image.png") as ImageProvider,
                              onBackgroundImageError: (_, __) {},
                            ),
                            title: Text(
                              member['name'],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: showPrimary
                                ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 4),
                                  child: SvgPicture.asset(
                                    'assets/icons/crown.svg',
                                    width: 12,
                                    height: 12,
                                  ),
                                ),
                                Text(
                                  'Primary',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            )
                                : null,
                            trailing: Checkbox(
                              value: isSelected,
                              onChanged: (value) {
                                setState(() {
                                  if (value == true) {
                                    selectedMembers.add(member);
                                  } else {
                                    selectedMembers.removeWhere((m) => m['id'] == member['id']);
                                  }
                                });
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              activeColor: Colors.blueAccent,
                            ),
                          ),
                          if (index < filteredMembers.length - 1)
                            Divider(color: Colors.grey[200], height: 1),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0,bottom: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'CANCEL',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (selectedMembers.isNotEmpty) {
                    Navigator.of(context).pop();
                    widget.onMembersAdded(selectedMembers);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          widget.isCollaborativeTask
                              ? 'Please select at least one member'
                              : 'Please select a member to assign',
                        ),
                        backgroundColor: Colors.orange,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'ADD',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}


