// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import '../../../../utils/app_colors.dart';
// import '../../../../utils/app_texts_style.dart';
// import '../ugc_home/ugc_task_details/ugc_task_model/ugc_sub_task_model.dart';
//
// class UgcAddTaskScreen extends StatefulWidget {
//   const UgcAddTaskScreen({super.key});
//
//   @override
//   State<UgcAddTaskScreen> createState() => _UgcAddTaskScreenState();
// }
//
// class _UgcAddTaskScreenState extends State<UgcAddTaskScreen> {
//   final TextEditingController _titleController = TextEditingController();
//   final TextEditingController _descriptionController = TextEditingController();
//   final TextEditingController _dateTimeController = TextEditingController();
//
//   final List<UgcSubTask> _subTasks = [];
//   final List<TextEditingController> _subtaskControllers = [];
//   final List<FocusNode> _subtaskFocusNodes = [];
//
//   @override
//   void dispose() {
//     _titleController.dispose();
//     _descriptionController.dispose();
//     _dateTimeController.dispose();
//     for (final controller in _subtaskControllers) {
//       controller.dispose();
//     }
//     for (final node in _subtaskFocusNodes) {
//       node.dispose();
//     }
//     super.dispose();
//   }
//
//   Future<void> _selectDateTime() async {
//     final DateTime? pickedDate = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime.now(),
//       lastDate: DateTime(2100),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: ColorScheme.light(
//               primary: AppColors.primaryColor,
//               onPrimary: AppColors.black,
//               onSurface: AppColors.black,
//             ),
//             textButtonTheme: TextButtonThemeData(
//               style: TextButton.styleFrom(foregroundColor: AppColors.primaryColor),
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//
//     if (pickedDate != null && mounted) {
//       final TimeOfDay? pickedTime = await showTimePicker(
//         context: context,
//         initialTime: TimeOfDay.now(),
//         builder: (context, child) {
//           return Theme(
//             data: Theme.of(context).copyWith(
//               colorScheme: ColorScheme.light(
//                 primary: AppColors.primaryColor,
//                 onPrimary: AppColors.black,
//                 onSurface: AppColors.black,
//               ),
//               textButtonTheme: TextButtonThemeData(
//                 style: TextButton.styleFrom(foregroundColor: AppColors.primaryColor),
//               ),
//             ),
//             child: child!,
//           );
//         },
//       );
//
//       if (pickedTime != null && mounted) {
//         setState(() {
//           _dateTimeController.text =
//           '${pickedDate.day}/${pickedDate.month}/${pickedDate.year} ${pickedTime.format(context)}';
//         });
//       }
//     }
//   }
//
//   void _addNewSubTask() {
//     setState(() {
//       _subTasks.add(UgcSubTask(title: ''));
//       _subtaskControllers.add(TextEditingController());
//       _subtaskFocusNodes.add(FocusNode());
//     });
//   }
//
//   void _removeSubTask(int index) {
//     setState(() {
//       _subtaskControllers[index].dispose();
//       _subtaskFocusNodes[index].dispose();
//       _subTasks.removeAt(index);
//       _subtaskControllers.removeAt(index);
//       _subtaskFocusNodes.removeAt(index);
//     });
//   }
//
//   void _saveSubTask(int index) {
//     setState(() {
//       _subTasks[index] = _subTasks[index].copyWith(
//         title: _subtaskControllers[index].text.trim(),
//       );
//       _subtaskFocusNodes[index].unfocus();
//     });
//
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Subtask saved'),
//         duration: Duration(seconds: 1),
//         backgroundColor: Colors.black,
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: AppColors.backgroundColor,
//         appBar: AppBar(
//           toolbarHeight: 70,
//           backgroundColor: AppColors.backgroundColor,
//           surfaceTintColor: AppColors.transparent,
//           title: Row(
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Add New Task',
//                     style: AppTextStyles.largeHeading.copyWith(
//                       fontSize: 30,
//                       fontWeight: FontWeight.normal,
//                     ),
//                   ),
//                   const SizedBox(height: 6),
//                   Text(
//                     'You can add 3 to 5 more tasks today!',
//                     style: AppTextStyles.smallText.copyWith(fontSize: 16),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//         body: SingleChildScrollView(
//           physics: const AlwaysScrollableScrollPhysics(
//             parent: BouncingScrollPhysics(),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(20.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 /// Task Title
//                 Text('Task Title', style: AppTextStyles.smallHeading),
//                 const SizedBox(height: 12),
//                 TextField(
//                   controller: _titleController,
//                   decoration: InputDecoration(
//                     hintText: 'Type now',
//                     hintStyle: AppTextStyles.defaultTextStyle,
//                     filled: true,
//                     fillColor: AppColors.backgroundColor,
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: const BorderSide(color: AppColors.grey, width: 1),
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: const BorderSide(color: AppColors.grey, width: 1),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: const BorderSide(color: AppColors.grey, width: 2),
//                     ),
//                     contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//                   ),
//                   cursorColor: AppColors.primaryColor,
//                   style: const TextStyle(color: Colors.black),
//                 ),
//                 const SizedBox(height: 24),
//
//                 // Task Description
//                 Text('Task Description', style: AppTextStyles.smallHeading),
//                 const SizedBox(height: 12),
//                 TextField(
//                   controller: _descriptionController,
//                   maxLines: 4,
//                   cursorColor: AppColors.primaryColor,
//                   decoration: InputDecoration(
//                     hintText: 'What needs your attention?',
//                     hintStyle: AppTextStyles.defaultTextStyle,
//                     filled: true,
//                     fillColor: AppColors.backgroundColor,
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide.none,
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: const BorderSide(color: AppColors.grey, width: 2),
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: const BorderSide(color: AppColors.grey, width: 1),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//
//                 // Task Date & Time
//                 Text('Task Date & Time', style: AppTextStyles.smallHeading),
//                 const SizedBox(height: 12),
//                 TextField(
//                   controller: _dateTimeController,
//                   readOnly: true,
//                   onTap: _selectDateTime,
//                   decoration: InputDecoration(
//                     hintText: '-- : -- --',
//                     hintStyle: const TextStyle(color: AppColors.grey, fontSize: 15),
//                     filled: true,
//                     fillColor: AppColors.backgroundColor,
//                     suffixIcon: const Icon(Icons.access_time, color: Color(0xFF6B7280)),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: const BorderSide(color: AppColors.grey, width: 1),
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: const BorderSide(color: AppColors.grey, width: 1),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: const BorderSide(color: AppColors.grey, width: 1),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//
//                 // Subtasks list - UPDATED TO MATCH EditTaskScreen
//                 ...List.generate(_subTasks.length, (index) {
//                   return Padding(
//                     padding: const EdgeInsets.only(bottom: 12),
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 14,
//                         vertical: 10,
//                       ),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(color: AppColors.grey),
//                       ),
//                       child: Column(
//                         children: [
//                           Row(
//                             children: [
//                               Container(
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 6,
//                                   vertical: 3,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   color: AppColors.primaryColor.withOpacity(0.5),
//                                   borderRadius: BorderRadius.circular(6),
//                                 ),
//                                 child: Text(
//                                   'Sub Task',
//                                   style: AppTextStyles.smallText.copyWith(
//                                     color: AppColors.black,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 8),
//                           Row(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Expanded(
//                                 child: TextField(
//                                   controller: _subtaskControllers[index],
//                                   focusNode: _subtaskFocusNodes[index],
//                                   maxLines: null,
//                                   minLines: 1,
//                                   decoration: const InputDecoration(
//                                     hintText: 'Enter Sub Task Details',
//                                     border: InputBorder.none,
//                                     hintStyle: TextStyle(color: AppColors.grey),
//                                   ),
//                                 ),
//                               ),
//                               ValueListenableBuilder<TextEditingValue>(
//                                 valueListenable: _subtaskControllers[index],
//                                 builder: (context, value, child) {
//                                   final hasFocus = _subtaskFocusNodes[index].hasFocus;
//                                   final hasText = value.text.isNotEmpty;
//
//                                   return IconButton(
//                                     onPressed: () {
//                                       if (hasFocus && hasText) {
//                                         _saveSubTask(index);
//                                       } else {
//                                         _removeSubTask(index);
//                                       }
//                                     },
//                                     icon: Icon(
//                                       (hasFocus && hasText) ? Icons.check : CupertinoIcons.trash,
//                                       color: (hasFocus && hasText)
//                                           ? AppColors.primaryColor
//                                           : AppColors.iconColor,
//                                     ),
//                                   );
//                                 },
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 }),
//
//                 // Add Sub Task Button
//                 GestureDetector(
//                   onTap: _addNewSubTask,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                     decoration: BoxDecoration(
//                       color: AppColors.mainBottomNavColor,
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(color: AppColors.lightGrey),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Icon(Icons.add, color: AppColors.black),
//                         const SizedBox(width: 6),
//                         Text(
//                           'Add Sub Task',
//                           style: AppTextStyles.defaultTextStyle.copyWith(
//                             fontWeight: FontWeight.bold,
//                             color: AppColors.black,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 40),
//
//                 // Create Task Button
//                 SizedBox(
//                   height: 50,
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       if (_titleController.text.isNotEmpty) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text('Task created successfully!'),
//                             backgroundColor: Colors.green,
//                           ),
//                         );
//                       }
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.primaryColor,
//                       foregroundColor: AppColors.white,
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       elevation: 0,
//                     ),
//                     child: Text(
//                       'Create Task',
//                       style: AppTextStyles.defaultTextStyle.copyWith(
//                         color: AppColors.white,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
//



///
///
/// todo:: upper is important
///
///
///



import 'package:askfemi/utils/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class UgcAddTaskScreen extends StatelessWidget {
  const UgcAddTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.transparent,
        elevation: 0,
        title: Text(
          'Create Task',
          style: TextStyle(
            color: AppColors.primaryColor,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Track and analyze task performance across your team',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 24),
              // Single Assignment - Filled Button
              CreateTaskCard(
                title: 'Single Assignment',
                subtitle: 'Assign task to one family member',
                buttonText: 'Create Task',
                svgIcon: SvgPicture.asset('assets/icons/single_assignment_icon.svg',),
                iconBackgroundColor: Colors.blue.shade50,
                isOutlined: false,
              ),
              SizedBox(height: 16),
              // Collaborative Task - Outlined Button
              CreateTaskCard(
                title: 'Collaborative Task',
                subtitle: 'Assign to multiple members',
                buttonText: 'Create Task',
                svgIcon: SvgPicture.asset('assets/icons/collaborative_task_icon.svg',),
                iconBackgroundColor: Colors.blue.shade50,
                isOutlined: true,
              ),
              SizedBox(height: 16),
              // Personal Task - Outlined Button
              CreateTaskCard(
                title: 'Personal Task',
                subtitle: 'Create task for yourself',
                buttonText: 'Create Task',
                iconBackgroundColor: Colors.blue.shade50,
                svgIcon: SvgPicture.asset('assets/icons/personal_task.svg',),
                isOutlined: true,
              ),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}


class CreateTaskCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonText;
  final Color iconBackgroundColor;
  final bool isOutlined;

  // Icon-related properties
  final IconData? iconData;
  final SvgPicture? svgIcon;
  final String? svgAssetPath;
  final double iconSize;
  final Color? iconColor;

  const CreateTaskCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.iconBackgroundColor,
    this.isOutlined = false,
    this.iconData,
    this.svgIcon,
    this.svgAssetPath,
    this.iconSize = 35,
    this.iconColor,
  }) : assert(
  (iconData != null && svgIcon == null && svgAssetPath == null) ||
      (iconData == null && svgIcon != null && svgAssetPath == null) ||
      (iconData == null && svgIcon == null && svgAssetPath != null),
  'Provide either iconData, svgIcon, or svgAssetPath, but not multiple',
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon container
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                // child: _buildIcon(),
                child: svgIcon,
              ),
            ),
            const SizedBox(height: 16),

            // Title and subtitle
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
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

            const SizedBox(height: 20),

            // Button
            SizedBox(
              width: double.infinity,
              child: isOutlined
                  ? OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  side: BorderSide(color: Colors.blue),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
                  : ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
