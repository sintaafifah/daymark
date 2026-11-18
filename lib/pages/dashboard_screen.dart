
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/task_service.dart';
import '../widgets/app_shell.dart';
import 'profile_screen.dart';
import 'add_task_screen.dart';
import 'tasks_screen.dart';
import 'task_detail_screen.dart';

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

  String get currentDate {
    const months = [
      'Januari', 'Februari', 'Maret', 'April',
      'Mei', 'Juni', 'Juli', 'Agustus',
      'September', 'Oktober', 'November', 'Desember'
    ];

    final now = DateTime.now();
    return '${now.day} ${months[now.month - 1]} ${now.year}';
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
      MaterialPageRoute(
        builder: (context) => const TasksScreen(),
      ),
    );
    return;
  }


  if (index == 2) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddTaskScreen(),
      ),
    );
    return;
  }

    if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
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
                child: Text(
                  'Gagal memuat tugas. Periksa koneksi internet.',
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
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
                  padding: EdgeInsets.all(
                    isDesktop ? 32 : 20,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 1200,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(context),

                          const SizedBox(height: 16),

                          Text(
                            'Hai, $userName!',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colors.onSurface,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            '$currentDate · Waktunya melangkah maju.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),

                          const SizedBox(height: 24),

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
          'assets/images/logo.png',
          width: 125,
          height: 42,
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
                ? Icon(
                    Icons.person,
                    color: colors.primary,
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
          const SizedBox(height: 24),
          _buildGettingStarted(context),
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
          child: _buildMainContent(
            context,
            tasks,
            completed,
            total,
            progress,
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 3,
          child: _buildSidePanel(context, tasks),
        ),
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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Image.asset(
            'assets/images/maskot.png',
            height: 150,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 12),
          Text(
            'Hari baru, peluang baru.',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Belum ada tugas. Yuk, tulis satu hal kecil '
            'yang ingin kamu selesaikan hari ini.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const AddTaskScreen(),
    ),
  );
},
              child: const Text('+ Buat tugas pertamamu'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGettingStarted(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mulai dengan yang sederhana',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Row(
            children: [
              Icon(
                Icons.check_box_outline_blank,
                color: colors.primary,
                size: 21,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tulis rencana hari ini',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Langkah kecil untuk awal yang baik.',
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
      ],
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
              valueColor: AlwaysStoppedAnimation<Color>(
                colors.onPrimary,
              ),
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
        builder: (context) => TaskDetailScreen(
          taskId: taskId,
        ),
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
                const SnackBar(
                  content: Text('Gagal memperbarui tugas.'),
                ),
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
            'assets/images/maskot.png',
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
