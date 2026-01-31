// import 'package:askfemi/individual_user/features/home/task_details/model/sub_task_model.dart';
// import 'package:askfemi/individual_user/features/home/task_details/model/task_model.dart';
// import 'package:askfemi/utils/app_colors.dart';
// import 'package:askfemi/widget/build_task_card.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
// class StatusScreen extends StatefulWidget {
//   final TaskStatus? filterStatus; // null means show all
//
//   const StatusScreen({super.key, this.filterStatus});
//
//   @override
//   State<StatusScreen> createState() => _StatusScreenState();
// }
//
// class _StatusScreenState extends State<StatusScreen> {
//   late TaskStatus? selectedStatus;
//
//   @override
//   void initState() {
//     super.initState();
//     selectedStatus = widget.filterStatus;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundColor,
//       appBar: AppBar(
//         backgroundColor: AppColors.backgroundColor,
//         elevation: 0,
//         surfaceTintColor: Colors.white,
//         automaticallyImplyLeading: false,
//         title: const Text(
//           'Task History',
//           style: TextStyle(
//             fontSize: 30,
//             fontWeight: FontWeight.bold,
//             fontFamily: 'Plus Jakarta Sans',
//             color: Colors.black87,
//           ),
//         ),
//         actions: [
//           IconButton(
//             onPressed: () {},
//             icon: Icon(CupertinoIcons.calendar_today),
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.only(top: 16,left: 16, right: 16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Task list
//             Expanded(child: _buildTaskList()),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTaskList() {
//     final tasks = _getFilteredTasks();
//
//     if (tasks.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.task_alt, size: 64, color: Colors.grey[300]),
//             const SizedBox(height: 16),
//             Text(
//               'No tasks found',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontFamily: 'Plus Jakarta Sans',
//                 color: Colors.grey[600],
//               ),
//             ),
//           ],
//         ),
//       );
//     }
//
//     return ListView.separated(
//       physics: const BouncingScrollPhysics(),
//       itemCount: tasks.length,
//       separatorBuilder: (context, index) => const SizedBox(height: 16),
//       itemBuilder: (context, index) {
//         return buildTaskCard(context: context, task: tasks[index]);
//       },
//     );
//   }
//
//   List<Task> _getFilteredTasks() {
//     final allTasks = _getAllTasks();
//
//     if (selectedStatus == null) {
//       return allTasks;
//     }
//
//     return allTasks.where((task) => task.status == selectedStatus).toList();
//   }
//
//   // Mock data - Replace with your actual data source
//   List<Task> _getAllTasks() {
//     return [
//       Task(
//         title: 'Complete Math Homework',
//         description: 'Solve algebra, geometry and calculus problems.',
//         time: '10:30 AM',
//         status: TaskStatus.completed,
//         createdAt: DateTime(2026, 1, 30, 9, 50),
//         startTime: DateTime(2026, 1, 30, 10, 30),
//         completedTime: DateTime(2026, 1, 30, 12, 45),
//         totalSubtasks: 5,
//         completedSubtasks: 5,
//         subtasks: [
//           SubTask(
//             title: 'Solve algebra problems',
//             isCompleted: true,
//             duration: null,
//           ),
//           SubTask(
//             title: 'Complete geometry worksheet',
//             isCompleted: true,
//             duration: '30 min',
//           ),
//           SubTask(
//             title: 'Study calculus',
//             isCompleted: true,
//             duration: '45 min',
//           ),
//           SubTask(
//             title: 'Review all solutions',
//             isCompleted: true,
//             duration: '20 min',
//           ),
//           SubTask(title: 'Submit homework', isCompleted: true, duration: null),
//         ],
//       ),
//       Task(
//         title: 'Prepare Presentation',
//         description: 'Create slides for tomorrow\'s meeting.',
//         time: '2:00 PM',
//         status: TaskStatus.completed,
//         createdAt: DateTime(2026, 1, 30, 8, 0),
//         startTime: DateTime(2026, 1, 30, 14, 0),
//         totalSubtasks: 6,
//         completedSubtasks: 3,
//       ),
//       Task(
//         title: 'Team Meeting',
//         description: 'Discuss project updates and next steps.',
//         time: '3:30 PM',
//         status: TaskStatus.completed,
//         createdAt: DateTime(2026, 1, 30, 7, 30),
//         startTime: DateTime(2026, 1, 30, 15, 30),
//       ),
//       Task(
//         title: 'Code Review',
//         description: 'Review pull requests from team members.',
//         time: '11:00 AM',
//         status: TaskStatus.completed,
//         createdAt: DateTime(2026, 1, 29, 10, 0),
//         startTime: DateTime(2026, 1, 29, 11, 0),
//         completedTime: DateTime(2026, 1, 29, 12, 30),
//         totalSubtasks: 3,
//         completedSubtasks: 3,
//       ),
//       Task(
//         title: 'Write Documentation',
//         description: 'Update API documentation for new features.',
//         time: '4:00 PM',
//         status: TaskStatus.completed,
//         createdAt: DateTime(2026, 1, 30, 9, 0),
//         startTime: DateTime(2026, 1, 30, 16, 0),
//         totalSubtasks: 4,
//         completedSubtasks: 1,
//       ),
//       Task(
//         title: 'Client Call',
//         description: 'Discuss requirements for new project.',
//         time: '1:00 PM',
//         status: TaskStatus.completed,
//         createdAt: DateTime(2026, 1, 30, 8, 30),
//         startTime: DateTime(2026, 1, 30, 13, 0),
//       ),
//     ];
//   }
// }





import 'package:askfemi/individual_user/features/home/task_details/model/sub_task_model.dart';
import 'package:askfemi/individual_user/features/home/task_details/model/task_model.dart';
import 'package:askfemi/utils/app_colors.dart';
import 'package:askfemi/widget/build_task_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StatusScreen extends StatefulWidget {
  final TaskStatus? filterStatus;

  const StatusScreen({super.key, this.filterStatus});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  late TaskStatus? selectedStatus;
  DateTimeRange? _selectedDateRange;
  bool _showCalendar = false;

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.filterStatus;

    // Set default date range to current month
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    _selectedDateRange = DateTimeRange(start: firstDayOfMonth, end: lastDayOfMonth);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.white,
        automaticallyImplyLeading: false,
        title: const Text(
          'Task History',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            fontFamily: 'Plus Jakarta Sans',
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _showCalendar = !_showCalendar;
              });
            },
            icon: Icon(CupertinoIcons.calendar_today),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Show selected date range
            if (_selectedDateRange != null && !_showCalendar)
              _buildDateRangeIndicator(),

            const SizedBox(height: 16),

            // Show calendar if toggled
            if (_showCalendar)
              _buildCalendar(),

            // Task list (hidden when calendar is shown)
            if (!_showCalendar)
              Expanded(child: _buildTaskList()),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeIndicator() {
    final format = DateFormat('dd MMM');
    return Row(
      children: [
        Text(
          '${format.format(_selectedDateRange!.start)} - ${format.format(_selectedDateRange!.end)}',
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'Plus Jakarta Sans',
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCalendar() {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Month and Year
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Task date',
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _showCalendar = false;
                        });
                      },
                      icon: const Icon(Icons.close, size: 20),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Date From/To labels
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDateLabel('Date', Colors.black87),
                    _buildDateLabel('To', Colors.black87),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Month header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('MMMM yyyy').format(currentMonth),
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Calendar grid
              _buildCalendarGrid(currentMonth),
            ],
          ),
        ),

        // Submit button
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _showCalendar = false;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Submit',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateLabel(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontFamily: 'Plus Jakarta Sans',
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildCalendarGrid(DateTime currentMonth) {
    final daysInMonth = DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
    final firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
    final startingWeekday = firstDayOfMonth.weekday; // 1=Monday, 7=Sunday

    // Adjust for Sunday as first day (if needed)
    final adjustedWeekday = startingWeekday % 7;

    // Generate day numbers
    final List<List<int?>> weeks = [];
    List<int?> currentWeek = List.filled(7, null);

    // Fill first week with nulls for days before the 1st
    for (int i = 0; i < adjustedWeekday; i++) {
      currentWeek[i] = null;
    }

    // Fill the month days
    int day = 1;
    for (int i = adjustedWeekday; i < 7; i++) {
      currentWeek[i] = day;
      day++;
    }
    weeks.add(List.from(currentWeek));

    // Fill remaining weeks
    while (day <= daysInMonth) {
      currentWeek = [];
      for (int i = 0; i < 7 && day <= daysInMonth; i++) {
        currentWeek.add(day);
        day++;
      }
      // Fill remaining days with nulls
      while (currentWeek.length < 7) {
        currentWeek.add(null);
      }
      weeks.add(currentWeek);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Day headers
          Row(
            children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                .map((day) => Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  day,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ))
                .toList(),
          ),

          // Calendar days
          ...weeks.map((week) => Row(
            children: week.map((dayNumber) => Expanded(
              child: _buildDayCell(dayNumber),
            )).toList(),
          )),
        ],
      ),
    );
  }

  Widget _buildDayCell(int? dayNumber) {
    final isToday = dayNumber != null &&
        dayNumber == DateTime.now().day &&
        DateTime.now().month == DateTime.now().month;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: isToday ? AppColors.primaryColor.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          // Day number
          Text(
            dayNumber != null ? dayNumber.toString() : '',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              color: isToday ? AppColors.primaryColor : Colors.black87,
            ),
          ),

          // Optional: Add indicators for tasks
          if (dayNumber != null && _hasTasksOnDate(dayNumber))
            Container(
              margin: const EdgeInsets.only(top: 2),
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: AppColors.primaryColor,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  bool _hasTasksOnDate(int day) {
    // Mock: Show dots on specific days
    final taskDays = [1, 5, 10, 15, 20, 25, 30];
    return taskDays.contains(day);
  }

  Widget _buildTaskList() {
    final tasks = _getFilteredTasks();

    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task_alt, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No tasks found',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Plus Jakarta Sans',
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: tasks.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return buildTaskCard(context: context, task: tasks[index]);
      },
    );
  }

  List<Task> _getFilteredTasks() {
    final allTasks = _getAllTasks();

    if (selectedStatus == null) {
      return allTasks;
    }

    return allTasks.where((task) => task.status == selectedStatus).toList();
  }

  // Mock data - Replace with your actual data source
  List<Task> _getAllTasks() {
    return [
      Task(
        title: 'Complete Math Homework',
        description: 'Solve algebra, geometry and calculus problems.',
        time: '10:30 AM',
        status: TaskStatus.completed,
        createdAt: DateTime(2026, 1, 30, 9, 50),
        startTime: DateTime(2026, 1, 30, 10, 30),
        completedTime: DateTime(2026, 1, 30, 12, 45),
        totalSubtasks: 5,
        completedSubtasks: 5,
        subtasks: [
          SubTask(
            title: 'Solve algebra problems',
            isCompleted: true,
            duration: null,
          ),
          SubTask(
            title: 'Complete geometry worksheet',
            isCompleted: true,
            duration: '30 min',
          ),
          SubTask(
            title: 'Study calculus',
            isCompleted: true,
            duration: '45 min',
          ),
          SubTask(
            title: 'Review all solutions',
            isCompleted: true,
            duration: '20 min',
          ),
          SubTask(title: 'Submit homework', isCompleted: true, duration: null),
        ],
      ),
      Task(
        title: 'Prepare Presentation',
        description: 'Create slides for tomorrow\'s meeting.',
        time: '2:00 PM',
        status: TaskStatus.completed,
        createdAt: DateTime(2026, 1, 30, 8, 0),
        startTime: DateTime(2026, 1, 30, 14, 0),
        totalSubtasks: 6,
        completedSubtasks: 3,
      ),
      Task(
        title: 'Team Meeting',
        description: 'Discuss project updates and next steps.',
        time: '3:30 PM',
        status: TaskStatus.completed,
        createdAt: DateTime(2026, 1, 30, 7, 30),
        startTime: DateTime(2026, 1, 30, 15, 30),
      ),
      Task(
        title: 'Code Review',
        description: 'Review pull requests from team members.',
        time: '11:00 AM',
        status: TaskStatus.completed,
        createdAt: DateTime(2026, 1, 29, 10, 0),
        startTime: DateTime(2026, 1, 29, 11, 0),
        completedTime: DateTime(2026, 1, 29, 12, 30),
        totalSubtasks: 3,
        completedSubtasks: 3,
      ),
      Task(
        title: 'Write Documentation',
        description: 'Update API documentation for new features.',
        time: '4:00 PM',
        status: TaskStatus.completed,
        createdAt: DateTime(2026, 1, 30, 9, 0),
        startTime: DateTime(2026, 1, 30, 16, 0),
        totalSubtasks: 4,
        completedSubtasks: 1,
      ),
      Task(
        title: 'Client Call',
        description: 'Discuss requirements for new project.',
        time: '1:00 PM',
        status: TaskStatus.completed,
        createdAt: DateTime(2026, 1, 30, 8, 30),
        startTime: DateTime(2026, 1, 30, 13, 0),
      ),
    ];
  }
}