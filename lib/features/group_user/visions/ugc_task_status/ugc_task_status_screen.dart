import 'package:flutter/material.dart';

class UgcTaskStatusScreen extends StatefulWidget {
  const UgcTaskStatusScreen({super.key});

  @override
  State<UgcTaskStatusScreen> createState() => _UgcTaskStatusScreenState();
}

class _UgcTaskStatusScreenState extends State<UgcTaskStatusScreen> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'All Status',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            // Status tabs (scrollable)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildStatusTab('Pending (4)', 0),
                    const SizedBox(width: 8),
                    _buildStatusTab('In Progress (3)', 1),
                    const SizedBox(width: 8),
                    _buildStatusTab('Completed (5)', 2),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Task list
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildTaskCard(
                    title: 'Complete Math Home work',
                    time: '10.30 AM',
                    subtasks: null,
                    progress: null,
                    assignee: null,
                    taskType: 'Self Task',
                    isGroupTask: false,
                  ),
                  const SizedBox(height: 12),
                  _buildTaskCard(
                    title: 'UI/UX design',
                    time: '10.30 AM',
                    subtasks: 5,
                    progress: 0,
                    assignee: 'Assigned by Mr Tom Alex',
                    taskType: null,
                    isGroupTask: false,
                  ),
                  const SizedBox(height: 12),
                  _buildTaskCard(
                    title: 'Math Home work',
                    time: '10.30 AM',
                    subtasks: 5,
                    progress: 0,
                    assignee: null,
                    taskType: 'Self Task',
                    isGroupTask: false,
                  ),
                  const SizedBox(height: 12),
                  _buildTaskCard(
                    title: 'Landing page design',
                    time: '10.30 AM',
                    subtasks: 5,
                    progress: 0,
                    assignee: 'Assigned by Mr Tom Alex',
                    taskType: 'Group Tasks',
                    isGroupTask: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTab(String text, int index) {
    final isSelected = selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4A90E2) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF4A90E2) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade600,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildTaskCard({
    required String title,
    required String time,
    int? subtasks,
    int? progress,
    String? assignee,
    String? taskType,
    required bool isGroupTask,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status badge
            Align(
              alignment: Alignment.topRight,
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Pending',
                  style: TextStyle(fontSize: 12, color: Colors.black87),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Title
            Text(
              title,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black),
            ),
            const SizedBox(height: 12),
            // Time and subtasks row
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  time,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                if (subtasks != null) ...[
                  const SizedBox(width: 16),
                  Icon(Icons.list_alt, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      '$subtasks subtasks',
                      style:
                      TextStyle(fontSize: 14, color: Colors.grey.shade600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (progress != null)
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: FractionallySizedBox(
                                widthFactor: progress / 100,
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4A90E2),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$progress% Completed',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: Colors.grey.shade200),
            const SizedBox(height: 12),
            // Bottom section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildBottomSection(
                      taskType: taskType, assignee: assignee, isGroupTask: isGroupTask),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A90E2),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Start',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection({
    String? taskType,
    String? assignee,
    required bool isGroupTask,
  }) {
    if (taskType != null && !isGroupTask) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFE3F2FD),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          taskType,
          style: const TextStyle(fontSize: 12, color: Color(0xFF4A90E2)),
        ),
      );
    } else if (assignee != null && !isGroupTask) {
      return Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.grey.shade300,
            child: Icon(Icons.person, size: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              assignee,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    } else if (isGroupTask) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildAvatar(Colors.orange),
              Transform.translate(
                offset: const Offset(-8, 0),
                child: _buildAvatar(Colors.purple),
              ),
              Transform.translate(
                offset: const Offset(-16, 0),
                child: _buildAvatar(Colors.blue),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  taskType ?? '',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey.shade300,
                child: Icon(Icons.person, size: 16, color: Colors.grey.shade600),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  assignee ?? '',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      );
    }
    return const SizedBox();
  }

  Widget _buildAvatar(Color color) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
    );
  }
}
