
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/task_service.dart';

class TaskDetailScreen extends StatefulWidget {
  final String taskId;

  const TaskDetailScreen({
    super.key,
    required this.taskId,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final TextEditingController _checklistController =
      TextEditingController();

  bool _isAddingChecklist = false;
  bool _isUpdating = false;

  @override
  void dispose() {
    _checklistController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Detail Tugas'),
        actions: [
          IconButton(
            tooltip: 'Hapus tugas',
            icon: const Icon(Icons.delete_outline),
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: TaskService.watchTask(widget.taskId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Gagal memuat detail tugas.'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text('Tugas tidak ditemukan.'),
            );
          }

          final data = snapshot.data!.data()!;

          final title = (data['title'] ?? '').toString();
          final description =
              (data['description'] ?? '').toString();
          final attachmentPath =
             (data['attachmentPath'] ?? '').toString();
          final attachmentName =
              (data['attachmentName'] ?? '').toString();
          final category =
              (data['category'] ?? 'Pribadi').toString();
          final priority =
              (data['priority'] ?? 'Sedang').toString();
          final time = (data['time'] ?? '').toString();
          final status =
              (data['status'] ?? 'Belum dimulai').toString();
          final isCompleted = data['isCompleted'] == true;

          final dateData = data['date'];
          DateTime? deadline;

          if (dateData is Timestamp) {
            deadline = dateData.toDate();
          }

          final checklist = List<Map<String, dynamic>>.from(
            (data['checklist'] ?? []).map(
              (item) => Map<String, dynamic>.from(item),
            ),
          );

          final activity = List<Map<String, dynamic>>.from(
            (data['activity'] ?? []).map(
              (item) => Map<String, dynamic>.from(item),
            ),
          );

          final completedCount = checklist.where(
            (item) => item['isCompleted'] == true,
          ).length;

          final progress = checklist.isEmpty
              ? 0.0
              : completedCount / checklist.length;

          return LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 900;

              return SingleChildScrollView(
                padding: EdgeInsets.all(isDesktop ? 32 : 20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 900,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(
                          context,
                          title,
                          status,
                          isCompleted,
                        ),

                        const SizedBox(height: 20),

                        _buildDescription(
  context,
  description,
),

const SizedBox(height: 20),

_buildAttachment(
  context,
  attachmentPath,
  attachmentName,
),

const SizedBox(height: 20),

_buildInformation(
                          context,
                          category,
                          priority,
                          deadline,
                          time,
                        ),

                        const SizedBox(height: 24),

                        _buildChecklist(
                          context,
                          checklist,
                          completedCount,
                          progress,
                        ),

                        const SizedBox(height: 24),

                        _buildActivity(
                          context,
                          activity,
                        ),

                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isUpdating
                                ? null
                                : () => _toggleTask(isCompleted),
                            icon: Icon(
                              isCompleted
                                  ? Icons.refresh
                                  : Icons.check_circle_outline,
                            ),
                            label: Text(
                              isCompleted
                                  ? 'Buka Kembali Tugas'
                                  : 'Tandai Tugas Selesai',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    String title,
    String status,
    bool isCompleted,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Chip(
            avatar: Icon(
              isCompleted
                  ? Icons.check_circle
                  : Icons.schedule,
              size: 17,
              color: colors.primary,
            ),
            label: Text(status),
            backgroundColor: colors.surface,
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(
    BuildContext context,
    String description,
  ) {
    final theme = Theme.of(context);

    return _sectionCard(
      context,
      title: 'Deskripsi',
      child: Text(
        description.isEmpty
            ? 'Tidak ada deskripsi.'
            : description,
        style: theme.textTheme.bodyMedium?.copyWith(
          height: 1.6,
        ),
      ),
    );
  }

Widget _buildAttachment(
  BuildContext context,
  String attachmentPath,
  String attachmentName,
) {
  final theme = Theme.of(context);

  // Jika tugas tidak memiliki lampiran
  if (attachmentPath.isEmpty) {
    return const SizedBox.shrink();
  }

  final file = File(attachmentPath);

  // Jika file gambar tidak ditemukan
  if (!file.existsSync()) {
    return _sectionCard(
      context,
      title: 'Lampiran Gambar',
      child: const Text(
        'File gambar tidak ditemukan di penyimpanan perangkat.',
      ),
    );
  }

  return _sectionCard(
    context,
    title: 'Lampiran Gambar',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            file,
            width: double.infinity,
            height: 260,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const SizedBox(
                height: 150,
                child: Center(
                  child: Text('Gagal menampilkan gambar.'),
                ),
              );
            },
          ),
        ),

        if (attachmentName.isNotEmpty) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.image_outlined,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  attachmentName,
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ],
      ],
    ),
  );
}


  Widget _buildInformation(
    BuildContext context,
    String category,
    String priority,
    DateTime? deadline,
    String time,
  ) {
    String dateText = 'Belum ditentukan';

    if (deadline != null) {
      dateText =
          '${deadline.day} ${_monthName(deadline.month)} ${deadline.year}';
    }

    return _sectionCard(
      context,
      title: 'Informasi Tugas',
      child: Column(
        children: [
          _infoRow(
            context,
            Icons.calendar_today_outlined,
            'Deadline',
            dateText,
          ),
          _infoRow(
            context,
            Icons.access_time,
            'Waktu',
            time.isEmpty ? '-' : time,
          ),
          _infoRow(
            context,
            Icons.folder_outlined,
            'Kategori',
            category,
          ),
          _infoRow(
            context,
            Icons.flag_outlined,
            'Prioritas',
            priority,
          ),
        ],
      ),
    );
  }

  Widget _buildChecklist(
    BuildContext context,
    List<Map<String, dynamic>> checklist,
    int completedCount,
    double progress,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return _sectionCard(
      context,
      title: 'Checklist',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$completedCount dari ${checklist.length} selesai',
                style: theme.textTheme.bodySmall,
              ),
              Text(
                '${(progress * 100).round()}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: progress,
            minHeight: 7,
            borderRadius: BorderRadius.circular(10),
          ),
          const SizedBox(height: 12),

          if (checklist.isEmpty)
            Text(
              'Belum ada checklist.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),

          ...List.generate(checklist.length, (index) {
            final item = checklist[index];
            final checked = item['isCompleted'] == true;

            return CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: checked,
              title: Text(
                (item['title'] ?? '').toString(),
                style: TextStyle(
                  decoration: checked
                      ? TextDecoration.lineThrough
                      : null,
                ),
              ),
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (value) {
                _updateChecklist(index, value ?? false);
              },
            );
          }),

          const SizedBox(height: 8),

          if (_isAddingChecklist)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _checklistController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Nama checklist',
                    ),
                    onSubmitted: (_) => _addChecklist(),
                  ),
                ),
                IconButton(
                  onPressed: _addChecklist,
                  icon: const Icon(Icons.check),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isAddingChecklist = false;
                      _checklistController.clear();
                    });
                  },
                  icon: const Icon(Icons.close),
                ),
              ],
            )
          else
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _isAddingChecklist = true;
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('Tambah checklist'),
            ),
        ],
      ),
    );
  }

  Widget _buildActivity(
    BuildContext context,
    List<Map<String, dynamic>> activity,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final sortedActivity = [...activity];

    sortedActivity.sort((a, b) {
      final aDate = a['createdAt'];
      final bDate = b['createdAt'];

      final aTime = aDate is Timestamp
          ? aDate.toDate()
          : DateTime(2000);

      final bTime = bDate is Timestamp
          ? bDate.toDate()
          : DateTime(2000);

      return bTime.compareTo(aTime);
    });

    return _sectionCard(
      context,
      title: 'Riwayat Aktivitas',
      child: sortedActivity.isEmpty
          ? Text(
              'Belum ada aktivitas.',
              style: theme.textTheme.bodySmall,
            )
          : Column(
              children: sortedActivity.map((item) {
                final action =
                    (item['action'] ?? '').toString();

                final timestamp = item['createdAt'];

                String dateText = '';

                if (timestamp is Timestamp) {
                  final date = timestamp.toDate();
                  dateText =
                      '${date.day} ${_monthName(date.month)} '
                      '${date.year} · '
                      '${date.hour.toString().padLeft(2, '0')}:'
                      '${date.minute.toString().padLeft(2, '0')}';
                }

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.history,
                    color: colors.primary,
                  ),
                  title: Text(action),
                  subtitle: Text(dateText),
                );
              }).toList(),
            ),
    );
  }

  Widget _sectionCard(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _infoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Icon(icon, color: colors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const months = [
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

    return months[month - 1];
  }

  Future<void> _updateChecklist(
    int index,
    bool value,
  ) async {
    try {
      await TaskService.updateChecklistItem(
        taskId: widget.taskId,
        index: index,
        isCompleted: value,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memperbarui checklist.'),
        ),
      );
    }
  }

  Future<void> _addChecklist() async {
    final title = _checklistController.text.trim();

    if (title.isEmpty) return;

    try {
      await TaskService.addChecklistItem(
        taskId: widget.taskId,
        title: title,
      );

      if (!mounted) return;

      setState(() {
        _checklistController.clear();
        _isAddingChecklist = false;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menambahkan checklist.'),
        ),
      );
    }
  }

  Future<void> _toggleTask(bool isCompleted) async {
    setState(() {
      _isUpdating = true;
    });

    try {
      await TaskService.setTaskCompleted(
        taskId: widget.taskId,
        isCompleted: !isCompleted,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memperbarui status tugas.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus tugas?'),
          content: const Text(
            'Tugas ini akan dihapus secara permanen.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    try {
      await TaskService.deleteTask(widget.taskId);

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menghapus tugas.'),
        ),
      );
    }
  }
}
