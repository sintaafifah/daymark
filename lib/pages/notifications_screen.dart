
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/app_shell.dart';
import 'add_task_screen.dart';
import 'calendar_screen.dart';
import 'dashboard_screen.dart';
import 'profile_screen.dart';
import 'task_detail_screen.dart';
import 'tasks_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedTab = 'Semua';

  CollectionReference<Map<String, dynamic>> get _notificationsRef {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('Pengguna belum login.');
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('notifications');
  }

  void _handleNavigation(int index) {
    Widget? page;

    switch (index) {
      case 0:
        page = const DashboardScreen();
        break;
      case 1:
        page = const TasksScreen();
        break;
      case 2:
        page = const AddTaskScreen();
        break;
      case 3:
        page = const CalendarScreen();
        break;
      case 4:
        page = const ProfileScreen();
        break;
      case 7:
        return;
    }

    if (page != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => page!),
      );
    }
  }

  DateTime? _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  bool _isToday(dynamic value) {
    final date = _parseDate(value);
    if (date == null) return false;

    final now = DateTime.now();

    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  Future<void> _openNotification(
    String notificationId,
    Map<String, dynamic> data,
  ) async {
    try {
      if (data['isRead'] != true) {
        await _notificationsRef.doc(notificationId).update({
          'isRead': true,
        });
      }

      if (!mounted) return;

      final taskId = data['taskId']?.toString();

      if (taskId != null && taskId.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TaskDetailScreen(taskId: taskId),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuka notifikasi: $e')),
      );
    }
  }

  Future<void> _markAllAsRead(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> documents,
  ) async {
    final unread = documents.where(
      (doc) => doc.data()['isRead'] != true,
    );

    if (unread.isEmpty) return;

    try {
      final batch = FirebaseFirestore.instance.batch();

      for (final doc in unread) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua notifikasi sudah dibaca.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui notifikasi: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AppShell(
      selectedIndex: 7,
      onDestinationSelected: _handleNavigation,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _notificationsRef
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text('Gagal memuat notifikasi.'),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final documents = snapshot.data?.docs ?? [];

              final unreadCount = documents.where(
                (doc) => doc.data()['isRead'] != true,
              ).length;

              final filtered = documents.where((doc) {
                final data = doc.data();

                if (_selectedTab == 'Belum dibaca') {
                  return data['isRead'] != true;
                }

                if (_selectedTab == 'Tugas') {
                  return data['type'] == 'task';
                }

                return true;
              }).toList();

              final todayNotifications = filtered.where(
                (doc) => _isToday(doc.data()['createdAt']),
              ).toList();

              final previousNotifications = filtered.where(
                (doc) => !_isToday(doc.data()['createdAt']),
              ).toList();

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 850),
                  child: CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                        sliver: SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TETAP TERHUBUNG',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.7,
                                  color: colors.primary,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Notifikasi',
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: colors.onSurface,
                                      ),
                                    ),
                                  ),
                                  if (unreadCount > 0)
                                    TextButton(
                                      onPressed: () =>
                                          _markAllAsRead(documents),
                                      child: const Text('Tandai dibaca'),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              _buildTabs(unreadCount),
                            ],
                          ),
                        ),
                      ),

                      if (todayNotifications.isNotEmpty) ...[
                        _sectionHeader('Hari ini'),
                        _notificationList(todayNotifications),
                      ],

                      if (previousNotifications.isNotEmpty) ...[
                        _sectionHeader('Sebelumnya'),
                        _notificationList(previousNotifications),
                      ],

                      if (filtered.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: _buildEmptyState(),
                        ),

                      const SliverToBoxAdapter(
                        child: SizedBox(height: 30),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTabs(int unreadCount) {
    final colors = Theme.of(context).colorScheme;

    final tabs = [
      'Semua',
      'Belum dibaca',
      'Tugas',
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: tabs.map((tab) {
          final selected = _selectedTab == tab;

          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(9),
              onTap: () {
                setState(() => _selectedTab = tab);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 11,
                  horizontal: 4,
                ),
                decoration: BoxDecoration(
                  color: selected ? colors.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        tab,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: selected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: selected
                              ? colors.primary
                              : colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    if (tab == 'Belum dibaca' && unreadCount > 0) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$unreadCount',
                          style: TextStyle(
                            color: colors.onPrimary,
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
      sliver: SliverToBoxAdapter(
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _notificationList(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> documents,
  ) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final doc = documents[index];

            return _buildNotificationCard(
              doc.id,
              doc.data(),
            );
          },
          childCount: documents.length,
        ),
      ),
    );
  }

  Widget _buildNotificationCard(
    String id,
    Map<String, dynamic> data,
  ) {
    final colors = Theme.of(context).colorScheme;

    final title = data['title']?.toString() ?? 'Notifikasi';
    final message = data['message']?.toString() ?? '';
    final type = data['type']?.toString() ?? 'general';
    final isRead = data['isRead'] == true;
    final createdAt = _parseDate(data['createdAt']);

    final iconData = type == 'task'
        ? Icons.assignment_outlined
        : type == 'comment'
            ? Icons.chat_bubble_outline
            : type == 'deadline'
                ? Icons.access_time
                : Icons.notifications_none;

    final iconColor = type == 'deadline'
        ? Colors.orange
        : type == 'comment'
            ? Colors.teal
            : colors.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () => _openNotification(id, data),
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  iconData,
                  color: iconColor,
                  size: 19,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            isRead ? FontWeight.w500 : FontWeight.bold,
                        color: colors.onSurface,
                      ),
                    ),
                    if (message.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        message,
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      createdAt == null
                          ? ''
                          : _formatRelativeTime(createdAt),
                      style: TextStyle(
                        fontSize: 10,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isRead)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 5, left: 8),
                  decoration: BoxDecoration(
                    color: colors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatRelativeTime(DateTime date) {
    final difference = DateTime.now().difference(date);

    if (difference.isNegative || difference.inMinutes < 1) {
      return 'Baru saja';
    }

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit yang lalu';
    }

    if (difference.inHours < 24) {
      return '${difference.inHours} jam yang lalu';
    }

    if (difference.inDays == 1) {
      return 'Kemarin';
    }

    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildEmptyState() {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 52,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(height: 14),
            Text(
              'Belum ada notifikasi',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Notifikasi aktivitasmu akan muncul di sini.',
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
}
