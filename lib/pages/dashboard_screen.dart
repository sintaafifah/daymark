import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/task_service.dart';
import '../widgets/app_shell.dart';
import 'profile_screen.dart';
import 'add_task_screen.dart';
import 'tasks_screen.dart';
import 'task_detail_screen.dart';
import 'calendar_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String get userName {
    final user = FirebaseAuth.instance.currentUser;

    if (user?.displayName?.trim().isNotEmpty == true) {
      return user!.displayName!.trim();
    }

    return user?.email?.split('@').first ?? 'Pengguna';
  }

  String get firstName {
    final parts = userName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'Pengguna';

    final name = parts.first;
    return name.length == 1
        ? name.toUpperCase()
        : '${name[0].toUpperCase()}${name.substring(1)}';
  }

  String get userInitials {
    final parts = userName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'P';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  String get currentDate {
    const weekdays = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
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

    final now = DateTime.now();
    return '${weekdays[now.weekday - 1]}, ${now.day} '
        '${months[now.month - 1]} ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      selectedIndex: 0,
      onDestinationSelected: _handleNavigation,
      child: _buildDashboardContent(),
    );
  }

  void _handleNavigation(int index) {
    if (index == 0) return;

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TasksScreen()),
      );
      return;
    }

    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AddTaskScreen()),
      );
      return;
    }

    if (index == 3) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const CalendarScreen(),
    ),
  );
  return;
}

    if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Halaman ini akan segera tersedia.')),
    );
  }

  Widget _buildDashboardContent() {
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
                child: Text('Gagal memuat tugas. Periksa koneksi internet.'),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final tasks = snapshot.data?.docs ?? [];

            final completedTasks = tasks.where((task) {
              return task.data()['isCompleted'] == true;
            }).length;

            final totalTasks = tasks.length;

            final progress = totalTasks == 0
                ? 0.0
                : completedTasks / totalTasks;

            return LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth >= 1100;

                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 32 : 16,
                    vertical: isDesktop
                        ? 32
                        : (constraints.maxHeight < 680 ? 10 : 14),
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(context),

                          const SizedBox(height: 8),

                          Text(
                            'Hai, $firstName!',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontSize: 20,
                              height: 1.2,
                              fontWeight: FontWeight.w700,
                              color: colors.onSurface,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            '$currentDate · Waktunya melangkah maju.',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              height: 1.3,
                              color: colors.onSurfaceVariant,
                            ),
                          ),

                          const SizedBox(height: 15),

                          if (isDesktop)
                            _buildDesktopContent(
                              context,
                              tasks,
                              completedTasks,
                              totalTasks,
                              progress,
                            )
                          else
                            _buildMainContent(
                              context,
                              tasks,
                              completedTasks,
                              totalTasks,
                              progress,
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
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final colors = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Image.asset(
          'assets/images/dashboard_logo_slim.png',
          width: 124,
          height: 39,
          alignment: Alignment.centerLeft,
          fit: BoxFit.contain,
        ),
        InkWell(
          onTap: () => _handleNavigation(4),
          borderRadius: BorderRadius.circular(30),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: colors.primary.withValues(alpha: 0.15),
            backgroundImage: user?.photoURL != null
                ? NetworkImage(user!.photoURL!)
                : null,
            child: user?.photoURL == null
                ? Text(
                    userInitials,
                    style: TextStyle(
                      color: colors.primary,
                      fontSize: 13,
                      letterSpacing: 0.3,
                      fontWeight: FontWeight.w800,
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent(
    BuildContext context,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> tasks,
    int completed,
    int total,
    double progress,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (tasks.isEmpty) ...[
          _buildEmptyState(context),
        ] else ...[
          _buildProgressCard(context, completed, total, progress),
          const SizedBox(height: 24),
          _buildTaskSection(context, tasks),
        ],
      ],
    );
  }

  Widget _buildDesktopContent(
    BuildContext context,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> tasks,
    int completed,
    int total,
    double progress,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 7,
          child: _buildMainContent(context, tasks, completed, total, progress),
        ),
        const SizedBox(width: 24),
        Expanded(flex: 3, child: _buildSidePanel(context, tasks)),
      ],
    );
  }

  Widget _buildSidePanel(
    BuildContext context,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> tasks,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hari ini',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${tasks.length} tugas terdaftar',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildMascotCard(context),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final mascotHeight = (screenHeight * 0.225).clamp(150.0, 205.0).toDouble();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 17, 18, 20),
      decoration: BoxDecoration(
        color: const Color(0xFFEEEAFE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: mascotHeight,
            child: Image.asset(
              'assets/images/dashboard_mascot.png',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Hari baru, peluang baru.',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 17,
              height: 1.25,
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Text(
              'Belum ada tugas. Yuk, tulis satu hal kecil '
              'yang ingin kamu selesaikan hari ini.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 11,
                height: 1.45,
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 19),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddTaskScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 44),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                textStyle: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
              child: const Text('+ Buat tugas pertamamu'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(
    BuildContext context,
    int completed,
    int total,
    double progress,
  ) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PROGRES MINGGU INI',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colors.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '$completed dari $total tugas selesai',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: colors.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: colors.onPrimary.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(colors.onPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskSection(
    BuildContext context,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> tasks,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fokus hari ini',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...tasks.map((task) {
          return _buildTaskCard(context, task.id, task.data());
        }),
      ],
    );
  }

  Widget _buildTaskCard(
    BuildContext context,
    String taskId,
    Map<String, dynamic> data,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final isCompleted = data['isCompleted'] == true;
    final title = data['title'] ?? 'Tanpa judul';
    final time = data['time'] ?? '';
    final category = data['category'] ?? 'Pribadi';
    final priority = data['priority'] ?? 'Sedang';

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskDetailScreen(taskId: taskId),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          children: [
            Checkbox(
              value: isCompleted,
              activeColor: colors.primary,
              onChanged: (value) async {
                try {
                  await TaskService.setTaskCompleted(
                    taskId: taskId,
                    isCompleted: value ?? false,
                  );
                } catch (e) {
                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Gagal memperbarui tugas.')),
                  );
                }
              },
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '$time · $category · Prioritas $priority',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMascotCard(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Image.asset(
            'assets/images/dashboard_mascot.png',
            height: 140,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 12),
          Text(
            'Daymark selalu menemani.',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Satu langkah kecil hari ini adalah awal yang baik.',
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
