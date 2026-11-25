
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/task_service.dart';
import '../widgets/app_shell.dart';
import 'add_task_screen.dart';
import 'profile_screen.dart';
import 'task_detail_screen.dart';
import 'tasks_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _displayedMonth =
      DateTime(DateTime.now().year, DateTime.now().month);

  String _selectedFilter = 'Semua';

  static const List<String> _months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  static const List<String> _weekdays = [
    'Sen',
    'Sel',
    'Rab',
    'Kam',
    'Jum',
    'Sab',
    'Min',
  ];

  DateTime? _parseTaskDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  bool _isCompleted(Map<String, dynamic> data) {
    return data['isCompleted'] == true ||
        data['status'] == 'Selesai';
  }

  bool _isOverdue(Map<String, dynamic> data) {
    final date = _parseTaskDate(data['date']);
    if (date == null || _isCompleted(data)) return false;

    return _dateOnly(date).isBefore(_dateOnly(DateTime.now()));
  }

  void _changeMonth(int amount) {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month + amount,
      );
    });
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
      _displayedMonth = DateTime(date.year, date.month);
    });
  }

  void _handleNavigation(int index) {
    if (index == 0 || index == 3) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      return;
    }

    Widget? page;

    switch (index) {
      case 1:
        page = const TasksScreen();
        break;
      case 2:
        page = const AddTaskScreen();
        break;
      case 4:
        page = const ProfileScreen();
        break;
    }

    if (page != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => page!),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Halaman ini akan segera tersedia.'),
        ),
      );
    }
  }

  @override
Widget build(BuildContext context) {
  return AppShell(
      selectedIndex: 3,
      onDestinationSelected: _handleNavigation,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: TaskService.getTasks(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text('Gagal memuat kalender. Silakan coba lagi.'),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final documents = snapshot.data?.docs ?? [];

              final tasks = documents.map((doc) {
                return {
                  'id': doc.id,
                  ...doc.data(),
                };
              }).toList();

              return LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 950;

                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1250),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(context),
                            const SizedBox(height: 24),

                            if (isWide)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 5,
                                    child: _buildCalendarCard(
                                      context,
                                      tasks,
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    flex: 4,
                                    child: _buildAgenda(
                                      context,
                                      tasks,
                                    ),
                                  ),
                                ],
                              )
                            else ...[
                              _buildCalendarCard(context, tasks),
                              const SizedBox(height: 20),
                              _buildAgenda(context, tasks),
                            ],

                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kalender',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Atur dan pantau jadwal kegiatanmu.',
          style: TextStyle(
            fontSize: 14,
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarCard(
    BuildContext context,
    List<Map<String, dynamic>> tasks,
  ) {
    final colors = Theme.of(context).colorScheme;

    final firstDay = DateTime(
      _displayedMonth.year,
      _displayedMonth.month,
      1,
    );

    final daysInMonth = DateTime(
      _displayedMonth.year,
      _displayedMonth.month + 1,
      0,
    ).day;

    final startingOffset = firstDay.weekday - 1;
    final totalCells = ((startingOffset + daysInMonth + 6) ~/ 7) * 7;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                '${_months[_displayedMonth.month - 1]} ${_displayedMonth.year}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                ),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Bulan sebelumnya',
                onPressed: () => _changeMonth(-1),
                icon: const Icon(Icons.chevron_left),
              ),
              IconButton(
                tooltip: 'Bulan berikutnya',
                onPressed: () => _changeMonth(1),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: _weekdays.map((day) {
              return Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 12),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: totalCells,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 4,
              childAspectRatio: 0.85,
            ),
            itemBuilder: (context, index) {
              final dayNumber = index - startingOffset + 1;

              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return const SizedBox.shrink();
              }

              final date = DateTime(
                _displayedMonth.year,
                _displayedMonth.month,
                dayNumber,
              );

              final isSelected = _isSameDay(date, _selectedDate);
              final isToday = _isSameDay(date, DateTime.now());

              final hasTask = tasks.any((task) {
                final taskDate = _parseTaskDate(task['date']);
                return taskDate != null && _isSameDay(taskDate, date);
              });

              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _selectDate(date),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colors.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: isToday && !isSelected
                        ? Border.all(color: colors.primary, width: 1.5)
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$dayNumber',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected || isToday
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected
                              ? colors.onPrimary
                              : colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: hasTask
                              ? (isSelected
                                  ? colors.onPrimary
                                  : colors.primary)
                              : Colors.transparent,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: colors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 7),
              Text(
                'Ada tugas',
                style: TextStyle(
                  fontSize: 12,
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 18),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  border: Border.all(color: colors.primary, width: 1.5),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 7),
              Text(
                'Hari ini',
                style: TextStyle(
                  fontSize: 12,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAgenda(
    BuildContext context,
    List<Map<String, dynamic>> tasks,
  ) {
    final colors = Theme.of(context).colorScheme;

    final dayTasks = tasks.where((task) {
      final date = _parseTaskDate(task['date']);
      return date != null && _isSameDay(date, _selectedDate);
    }).toList();

    dayTasks.sort((a, b) {
      final timeA = a['time']?.toString() ?? '';
      final timeB = b['time']?.toString() ?? '';
      return timeA.compareTo(timeB);
    });

    final filteredTasks = dayTasks.where((task) {
      final completed = _isCompleted(task);

      switch (_selectedFilter) {
        case 'Belum selesai':
          return !completed;
        case 'Selesai':
          return completed;
        case 'Riwayat':
          final date = _parseTaskDate(task['date']);
          return date != null &&
              _dateOnly(date).isBefore(_dateOnly(DateTime.now()));
        default:
          return true;
      }
    }).toList();

    final dateLabel =
        '${_selectedDate.day} ${_months[_selectedDate.month - 1]} ${_selectedDate.year}';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Agenda Tugas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),
              ),
              Text(
                '${dayTasks.length} tugas',
                style: TextStyle(
                  fontSize: 12,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            dateLabel,
            style: TextStyle(
              fontSize: 13,
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 18),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['Semua', 'Belum selesai', 'Selesai', 'Riwayat']
                  .map((filter) {
                final selected = _selectedFilter == filter;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: selected,
                    onSelected: (_) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          if (filteredTasks.isEmpty)
            _buildEmptyAgenda(context)
          else
            ...filteredTasks.map(
              (task) => _buildTaskCard(context, task),
            ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddTaskScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Tambah Tugas'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyAgenda(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.event_note_outlined,
              size: 42,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'Belum ada tugas',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Tidak ada tugas pada tanggal ini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(
    BuildContext context,
    Map<String, dynamic> task,
  ) {
    final colors = Theme.of(context).colorScheme;

    final title = task['title']?.toString() ?? 'Tanpa judul';
    final time = task['time']?.toString() ?? '';
    final category = task['category']?.toString() ?? 'Pribadi';
    final completed = _isCompleted(task);
    final overdue = _isOverdue(task);

    final status = completed
        ? 'Selesai'
        : overdue
            ? 'Terlambat'
            : task['status']?.toString() ?? 'Belum dimulai';

    final statusColor = completed
        ? Colors.green
        : overdue
            ? colors.error
            : colors.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(14),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TaskDetailScreen(
                taskId: task['id'].toString(),
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 52,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: colors.onSurface,
                        decoration: completed
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Wrap(
                      spacing: 10,
                      runSpacing: 5,
                      children: [
                        if (time.isNotEmpty)
                          _taskInfo(
                            context,
                            Icons.access_time,
                            time,
                          ),
                        _taskInfo(
                          context,
                          Icons.folder_outlined,
                          category,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: colors.onSurfaceVariant,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _taskInfo(
    BuildContext context,
    IconData icon,
    String text,
  ) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 12,
          color: colors.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
