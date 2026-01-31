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
  DateTime? _selectedFromDate;
  DateTime? _selectedToDate;
  bool _showCalendar = false;
  bool _isSelectingFromDate = true;
  late DateTime _currentDisplayMonth; // Change this line

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.filterStatus;

    // Set default dates to current month
    final now = DateTime.now();
    _currentDisplayMonth = DateTime(now.year, now.month); // Initialize here
    _selectedFromDate = DateTime(now.year, now.month, 1);
    _selectedToDate = DateTime(now.year, now.month + 1, 0);
  }

  void _goToPreviousMonth() {
    setState(() {
      _currentDisplayMonth = DateTime(
        _currentDisplayMonth.year,
        _currentDisplayMonth.month - 1,
      );
    });
  }

  void _goToNextMonth() {
    setState(() {
      _currentDisplayMonth = DateTime(
        _currentDisplayMonth.year,
        _currentDisplayMonth.month + 1,
      );
    });
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
                // Reset to current month when opening calendar
                if (_showCalendar) {
                  _currentDisplayMonth = DateTime(
                    DateTime.now().year,
                    DateTime.now().month,
                  );
                }
              });
            },
            icon: const Icon(CupertinoIcons.calendar_today),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Show selected date range
            if (_selectedFromDate != null && _selectedToDate != null && !_showCalendar)
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
          '${format.format(_selectedFromDate!)} - ${format.format(_selectedToDate!)}',
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
              // Header with close button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
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

              // Date selection fields
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // From Date
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isSelectingFromDate = true;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _isSelectingFromDate
                                  ? AppColors.primaryColor
                                  : Colors.grey[300]!,
                              width: _isSelectingFromDate ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Date',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _selectedFromDate != null
                                    ? DateFormat('dd/MM/yyyy').format(_selectedFromDate!)
                                    : '--/--/----',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // To Date
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isSelectingFromDate = false;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: !_isSelectingFromDate
                                  ? AppColors.primaryColor
                                  : Colors.grey[300]!,
                              width: !_isSelectingFromDate ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'To',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _selectedToDate != null
                                    ? DateFormat('dd/MM/yyyy').format(_selectedToDate!)
                                    : '--/--/----',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Month header with navigation
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: _goToPreviousMonth,
                      icon: const Icon(Icons.chevron_left, size: 24),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),

                    Text(
                      DateFormat('MMMM yyyy').format(_currentDisplayMonth),
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),

                    IconButton(
                      onPressed: _goToNextMonth,
                      icon: const Icon(Icons.chevron_right, size: 24),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Calendar grid
              _buildCalendarGrid(_currentDisplayMonth),
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

  Widget _buildCalendarGrid(DateTime currentMonth) {
    final daysInMonth = DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
    final firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
    final startingWeekday = firstDayOfMonth.weekday; // 1=Monday, 7=Sunday

    // Adjust for Sunday as first day
    final adjustedWeekday = startingWeekday % 7;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Day headers
          Row(
            children: [
              _buildDayHeader('Sun'),
              _buildDayHeader('Mon'),
              _buildDayHeader('Tue'),
              _buildDayHeader('Wed'),
              _buildDayHeader('Thu'),
              _buildDayHeader('Fri'),
              _buildDayHeader('Sat'),
            ],
          ),

          // Calendar rows (5 rows)
          const SizedBox(height: 8),
          _buildCalendarRow(1, 7, currentMonth, adjustedWeekday),
          const SizedBox(height: 4),
          _buildCalendarRow(8, 14, currentMonth, adjustedWeekday),
          const SizedBox(height: 4),
          _buildCalendarRow(15, 21, currentMonth, adjustedWeekday),
          const SizedBox(height: 4),
          _buildCalendarRow(22, 28, currentMonth, adjustedWeekday),
          const SizedBox(height: 4),
          _buildCalendarRow(29, daysInMonth, currentMonth, adjustedWeekday, nextMonthDays: 4),
        ],
      ),
    );
  }

  Widget _buildDayHeader(String day) {
    return Expanded(
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
    );
  }

  Widget _buildCalendarRow(int startDay, int endDay, DateTime currentMonth, int firstDayOffset, {int nextMonthDays = 0}) {
    final List<int?> dayNumbers = [];

    // Add days from current month
    for (int day = startDay; day <= endDay && day <= DateTime(currentMonth.year, currentMonth.month + 1, 0).day; day++) {
      dayNumbers.add(day);
    }

    // Add next month days if needed
    if (dayNumbers.length < 7) {
      int nextDay = 1;
      for (int i = dayNumbers.length; i < 7; i++) {
        dayNumbers.add(nextDay);
        nextDay++;
      }
    }

    return Row(
      children: dayNumbers.map((day) => Expanded(
        child: _buildDayCell(day, currentMonth),
      )).toList(),
    );
  }

  Widget _buildDayCell(int? dayNumber, DateTime currentMonth) {
    final bool isCurrentMonth = dayNumber != null && dayNumber <= DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
    final bool isSelectedFrom = isCurrentMonth &&
        _selectedFromDate != null &&
        dayNumber == _selectedFromDate!.day &&
        currentMonth.year == _selectedFromDate!.year &&
        currentMonth.month == _selectedFromDate!.month;

    final bool isSelectedTo = isCurrentMonth &&
        _selectedToDate != null &&
        dayNumber == _selectedToDate!.day &&
        currentMonth.year == _selectedToDate!.year &&
        currentMonth.month == _selectedToDate!.month;

    final bool isInRange = isCurrentMonth &&
        _selectedFromDate != null &&
        _selectedToDate != null &&
        dayNumber != null &&
        DateTime(currentMonth.year, currentMonth.month, dayNumber).isAfter(_selectedFromDate!.subtract(const Duration(days: 1))) &&
        DateTime(currentMonth.year, currentMonth.month, dayNumber).isBefore(_selectedToDate!.add(const Duration(days: 1)));

    final bool isToday = isCurrentMonth &&
        dayNumber == DateTime.now().day &&
        currentMonth.month == DateTime.now().month &&
        currentMonth.year == DateTime.now().year;

    return GestureDetector(
      onTap: () {
        if (isCurrentMonth && dayNumber != null) {
          final selectedDate = DateTime(currentMonth.year, currentMonth.month, dayNumber);

          setState(() {
            if (_isSelectingFromDate) {
              _selectedFromDate = selectedDate;
              // If To date is before From date, adjust To date
              if (_selectedToDate != null && _selectedToDate!.isBefore(selectedDate)) {
                _selectedToDate = selectedDate;
              }
            } else {
              _selectedToDate = selectedDate;
              // If From date is after To date, adjust From date
              if (_selectedFromDate != null && _selectedFromDate!.isAfter(selectedDate)) {
                _selectedFromDate = selectedDate;
              }
            }
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelectedFrom || isSelectedTo
              ? AppColors.primaryColor
              : isInRange
              ? AppColors.primaryColor.withOpacity(0.1)
              : isToday
              ? AppColors.primaryColor.withOpacity(0.05)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelectedFrom || isSelectedTo
                ? AppColors.primaryColor
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            // Day number
            Text(
              dayNumber != null ? dayNumber.toString() : '',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: isSelectedFrom || isSelectedTo ? FontWeight.bold : FontWeight.normal,
                color: isCurrentMonth
                    ? (isSelectedFrom || isSelectedTo ? Colors.white : Colors.black87)
                    : Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
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