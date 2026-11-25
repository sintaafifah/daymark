
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ReminderSettingsScreen extends StatefulWidget {
  const ReminderSettingsScreen({super.key});

  @override
  State<ReminderSettingsScreen> createState() =>
      _ReminderSettingsScreenState();
}

class _ReminderSettingsScreenState extends State<ReminderSettingsScreen> {
  bool _deadlineReminder = true;
  bool _newTaskReminder = true;
  bool _commentReminder = true;
  bool _weeklySummary = false;

  int _reminderMinutesBefore = 1440;

  TimeOfDay _quietStart = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _quietEnd = const TimeOfDay(hour: 7, minute: 0);

  bool _isLoading = true;
  bool _isSaving = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> get _userDocument {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('Pengguna belum login.');
    }

    return _firestore.collection('users').doc(user.uid);
  }

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final snapshot = await _userDocument.get();
      final data = snapshot.data();
      final preferences =
          data?['notificationPreferences'] as Map<String, dynamic>?;

      if (preferences != null && mounted) {
        setState(() {
          _deadlineReminder =
              preferences['deadlineReminder'] as bool? ?? true;
          _newTaskReminder =
              preferences['newTaskReminder'] as bool? ?? true;
          _commentReminder =
              preferences['commentReminder'] as bool? ?? true;
          _weeklySummary =
              preferences['weeklySummary'] as bool? ?? false;

          _reminderMinutesBefore =
              preferences['reminderMinutesBefore'] as int? ?? 1440;

          _quietStart = _parseTime(
            preferences['quietStart']?.toString(),
            const TimeOfDay(hour: 22, minute: 0),
          );

          _quietEnd = _parseTime(
            preferences['quietEnd']?.toString(),
            const TimeOfDay(hour: 7, minute: 0),
          );

          _isLoading = false;
        });
      } else if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat pengaturan: $e')),
        );
      }
    }
  }

  TimeOfDay _parseTime(String? value, TimeOfDay fallback) {
    if (value == null) return fallback;

    final parts = value.split(':');
    if (parts.length != 2) return fallback;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null ||
        hour < 0 || hour > 23 ||
        minute < 0 || minute > 59) {
      return fallback;
    }

    return TimeOfDay(hour: hour, minute: minute);
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _selectTime({required bool isStart}) async {
    final selected = await showTimePicker(
      context: context,
      initialTime: isStart ? _quietStart : _quietEnd,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            alwaysUse24HourFormat: true,
          ),
          child: child!,
        );
      },
    );

    if (selected == null || !mounted) return;

    setState(() {
      if (isStart) {
        _quietStart = selected;
      } else {
        _quietEnd = selected;
      }
    });
  }

  Future<void> _savePreferences() async {
    setState(() => _isSaving = true);

    try {
      await _userDocument.set({
        'notificationPreferences': {
          'deadlineReminder': _deadlineReminder,
          'newTaskReminder': _newTaskReminder,
          'commentReminder': _commentReminder,
          'weeklySummary': _weeklySummary,
          'reminderMinutesBefore': _reminderMinutesBefore,
          'quietStart': _formatTime(_quietStart),
          'quietEnd': _formatTime(_quietEnd),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      }, SetOptions(merge: true));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preferensi pengingat berhasil disimpan.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan pengaturan: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back, size: 17),
                          label: const Text('Kembali'),
                        ),
                        const SizedBox(height: 12),

                        Text(
                          'Atur pengingat',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Pilih notifikasi yang ingin kamu terima.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),

                        const SizedBox(height: 24),

                        _buildToggleCard(
                          icon: Icons.alarm,
                          title: 'Deadline tugas',
                          subtitle: 'Ingatkan sebelum tenggat',
                          value: _deadlineReminder,
                          onChanged: (value) {
                            setState(() => _deadlineReminder = value);
                          },
                        ),

                        _buildToggleCard(
                          icon: Icons.assignment_add,
                          title: 'Tugas tim baru',
                          subtitle: 'Saat tugas diberikan kepadamu',
                          value: _newTaskReminder,
                          onChanged: (value) {
                            setState(() => _newTaskReminder = value);
                          },
                        ),

                        _buildToggleCard(
                          icon: Icons.chat_bubble_outline,
                          title: 'Komentar & mention',
                          subtitle: 'Aktivitas pada diskusi tugas',
                          value: _commentReminder,
                          onChanged: (value) {
                            setState(() => _commentReminder = value);
                          },
                        ),

                        _buildToggleCard(
                          icon: Icons.bar_chart,
                          title: 'Ringkasan mingguan',
                          subtitle: 'Rekap progres setiap minggu',
                          value: _weeklySummary,
                          onChanged: (value) {
                            setState(() => _weeklySummary = value);
                          },
                        ),

                        const SizedBox(height: 24),

                        Text(
                          'Waktu pengingat default',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                          ),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: colors.outlineVariant,
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: _reminderMinutesBefore,
                              isExpanded: true,
                              dropdownColor: colors.surface,
                              items: const [
                                DropdownMenuItem(
                                  value: 1440,
                                  child: Text('1 hari sebelum deadline'),
                                ),
                                DropdownMenuItem(
                                  value: 720,
                                  child: Text('12 jam sebelum deadline'),
                                ),
                                DropdownMenuItem(
                                  value: 60,
                                  child: Text('1 jam sebelum deadline'),
                                ),
                                DropdownMenuItem(
                                  value: 30,
                                  child: Text('30 menit sebelum deadline'),
                                ),
                                DropdownMenuItem(
                                  value: 0,
                                  child: Text('Saat deadline'),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _reminderMinutesBefore = value;
                                  });
                                }
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        Text(
                          'Jam tenang',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Atur waktu ketika kamu tidak ingin menerima pengingat.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: _buildTimeButton(
                                label: 'Mulai',
                                time: _quietStart,
                                onTap: () => _selectTime(isStart: true),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTimeButton(
                                label: 'Selesai',
                                time: _quietEnd,
                                onTap: () => _selectTime(isStart: false),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: FilledButton(
                            onPressed:
                                _isSaving ? null : _savePreferences,
                            child: _isSaving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Simpan preferensi',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildToggleCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        activeTrackColor: colors.primary,
        secondary: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 19,
            color: colors.primary,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 11,
            color: colors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildTimeButton({
    required String label,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 7),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: colors.primary,
                ),
                const SizedBox(width: 7),
                Text(
                  _formatTime(time),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
