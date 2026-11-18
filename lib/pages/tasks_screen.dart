
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/task_service.dart';
import '../widgets/app_shell.dart';
import 'task_detail_screen.dart';
import 'profile_screen.dart';


class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  String _selectedFilter = 'Semua';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      selectedIndex: 1,
      onDestinationSelected: _handleNavigation,
      child: _buildContent(),
    );
  }

 void _handleNavigation(int index) {
  if (index == 1) return;

  if (index == 0) {
    Navigator.pop(context);
    return;
  }

  if (index == 4) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfileScreen(),
      ),
    );
    return;
  }

  if (index == 2) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigasi tambah tugas akan disambungkan berikutnya.'),
      ),
    );
    return;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Halaman ini akan segera tersedia.'),
    ),
  );
}
 

  Widget _buildContent() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: TaskService.getTasks(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text('Gagal memuat tugas.'),
              );
            }

            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final tasks = snapshot.data?.docs ?? [];

            final filteredTasks = tasks.where((task) {
              final data = task.data();
              final title =
                  (data['title'] ?? '').toString().toLowerCase();

              final query =
                  _searchController.text.trim().toLowerCase();

              final matchesSearch = title.contains(query);

              final isCompleted = data['isCompleted'] == true;

              final matchesFilter =
                  _selectedFilter == 'Semua' ||
                  (_selectedFilter == 'Belum selesai' &&
                      !isCompleted) ||
                  (_selectedFilter == 'Selesai' &&
                      isCompleted);

              return matchesSearch && matchesFilter;
            }).toList();

            return LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth >= 900;

                return SingleChildScrollView(
                  padding: EdgeInsets.all(
                    isDesktop ? 32 : 20,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 1100,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Daftar Tugas',
                            style: theme.textTheme.headlineSmall
                                ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Kelola semua rencana dan deadline-mu.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 24),

                          TextField(
                            controller: _searchController,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              hintText: 'Cari tugas...',
                              prefixIcon:
                                  const Icon(Icons.search),
                              suffixIcon:
                                  _searchController.text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.close),
                                          onPressed: () {
                                            _searchController.clear();
                                            setState(() {});
                                          },
                                        )
                                      : null,
                              filled: true,
                              fillColor: colors.surface,
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: theme.dividerColor,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: theme.dividerColor,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              'Semua',
                              'Belum selesai',
                              'Selesai',
                            ].map((filter) {
                              final selected =
                                  _selectedFilter == filter;

                              return ChoiceChip(
                                label: Text(filter),
                                selected: selected,
                                onSelected: (_) {
                                  setState(() {
                                    _selectedFilter = filter;
                                  });
                                },
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 24),

                          Text(
                            '${filteredTasks.length} tugas',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 12),

                          if (filteredTasks.isEmpty)
                            _buildEmptyState(context)
                          else
                           ...filteredTasks.map((task) {
  return _buildTaskCard(
    context,
    task.id,
    task.data(),
  );
}),
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
    );
  }

  Widget _buildTaskCard(
  BuildContext context,
  String taskId,
  Map<String, dynamic> data,
) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final title = (data['title'] ?? 'Tanpa judul').toString();
    final description =
        (data['description'] ?? '').toString();
    final category =
        (data['category'] ?? 'Pribadi').toString();
    final priority =
        (data['priority'] ?? 'Sedang').toString();
    final time = (data['time'] ?? '').toString();
    final isCompleted = data['isCompleted'] == true;

    DateTime? deadline;

    final dateData = data['date'];

    if (dateData is Timestamp) {
      deadline = dateData.toDate();

      final parts = time.split(':');

      if (parts.length == 2) {
        deadline = DateTime(
          deadline.year,
          deadline.month,
          deadline.day,
          int.tryParse(parts[0]) ?? 0,
          int.tryParse(parts[1]) ?? 0,
        );
      }
    }

    final now = DateTime.now();

    final isOverdue =
        !isCompleted &&
        deadline != null &&
        deadline.isBefore(now);

    final isNearDeadline =
        !isCompleted &&
        deadline != null &&
        !isOverdue &&
        deadline.difference(now).inHours < 24;

    final deadlineColor = isOverdue
        ? colors.error
        : isNearDeadline
            ? Colors.orange
            : colors.onSurfaceVariant;

    String deadlineText = 'Deadline belum diatur';

    if (deadline != null) {
      deadlineText =
          '${deadline.day.toString().padLeft(2, '0')}/'
          '${deadline.month.toString().padLeft(2, '0')}/'
          '${deadline.year}';

      if (time.isNotEmpty) {
        deadlineText += ' · $time';
      }
    }

    final statusLabel = isCompleted
        ? 'Selesai'
        : isOverdue
            ? 'Terlambat'
            : isNearDeadline
                ? 'Mendekati deadline'
                : 'Belum selesai';

        return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskDetailScreen(
              taskId: taskId,
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.dividerColor,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  isCompleted
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: isCompleted
                      ? Colors.green
                      : colors.onSurfaceVariant,
                ),
              ],
            ),
            if (description.isNotEmpty) ...[
              const SizedBox(height: 7),
              Text(
                description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: deadlineColor,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    deadlineText,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: deadlineColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildTag(context, category),
                _buildTag(context, 'Prioritas $priority'),
                _buildTag(context, statusLabel),
              ],
            ),
          ],
        ),
      ),
    );
     
  }

  Widget _buildTag(BuildContext context, String label) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: colors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 54,
            color: colors.primary,
          ),
          const SizedBox(height: 12),
          Text(
            'Tugas tidak ditemukan',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Coba ubah pencarian atau filter tugas.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
