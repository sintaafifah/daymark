import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../widgets/app_shell.dart';

/// Statistik progres yang ditampilkan pada tab Beranda saat pengguna
/// sudah mempunyai setidaknya satu tugas.
///
/// Angka ringkasan dihitung dari seluruh tugas pengguna. Grafik ritme dan
/// kategori mengikuti minggu yang dipilih.
class StatisticsProgressScreen extends StatefulWidget {
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> tasks;
  final ValueChanged<int> onDestinationSelected;

  const StatisticsProgressScreen({
    super.key,
    required this.tasks,
    required this.onDestinationSelected,
  });

  @override
  State<StatisticsProgressScreen> createState() =>
      _StatisticsProgressScreenState();
}

class _StatisticsProgressScreenState extends State<StatisticsProgressScreen> {
  late DateTime _weekStart;

  static const List<String> _monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  static const List<String> _dayLabels = [
    'Sen',
    'Sel',
    'Rab',
    'Kam',
    'Jum',
    'Sab',
    'Min',
  ];

  @override
  void initState() {
    super.initState();
    _weekStart = _mondayOf(DateTime.now());
  }

  DateTime _mondayOf(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    return day.subtract(Duration(days: day.weekday - DateTime.monday));
  }

  DateTime? _readDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return null;
  }

  DateTime? _taskDate(Map<String, dynamic> data) {
    // Tanggal tugas adalah tanggal yang dipilih pengguna pada form tugas.
    return _readDate(data['date']) ?? _readDate(data['createdAt']);
  }

  DateTime? _completionDate(Map<String, dynamic> data) {
    // completedAt adalah sumber utama untuk tugas yang diselesaikan setelah
    // pembaruan ini. updatedAt menjadi fallback untuk data lama.
    return _readDate(data['completedAt']) ??
        _readDate(data['updatedAt']) ??
        _taskDate(data);
  }

  bool _isWithinSelectedWeek(DateTime? date) {
    if (date == null) return false;
    final day = DateTime(date.year, date.month, date.day);
    final end = _weekStart.add(const Duration(days: 7));
    return !day.isBefore(_weekStart) && day.isBefore(end);
  }

  String _weekLabel() {
    final end = _weekStart.add(const Duration(days: 6));
    final startDay = _weekStart.day;
    final endDay = end.day;
    final startMonth = _monthNames[_weekStart.month - 1];
    final endMonth = _monthNames[end.month - 1];

    if (_weekStart.month == end.month && _weekStart.year == end.year) {
      return '$startDay–$endDay $startMonth ${_weekStart.year}';
    }

    if (_weekStart.year == end.year) {
      return '$startDay $startMonth–$endDay $endMonth ${_weekStart.year}';
    }

    return '$startDay $startMonth ${_weekStart.year}–'
        '$endDay $endMonth ${end.year}';
  }

  Future<void> _chooseWeek() async {
    final chosenDate = await showDatePicker(
      context: context,
      initialDate: _weekStart,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035, 12, 31),
      helpText: 'Pilih tanggal dalam minggu yang ingin dilihat',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    );

    if (chosenDate == null || !mounted) return;
    setState(() {
      _weekStart = _mondayOf(chosenDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final allTasks = widget.tasks;
    final completedTasks = allTasks.where((task) {
      return task.data()['isCompleted'] == true;
    }).toList();
    final totalCount = allTasks.length;
    final completedCount = completedTasks.length;
    final remainingCount = totalCount - completedCount;
    final progress = totalCount == 0
        ? 0.0
        : (completedCount / totalCount).clamp(0.0, 1.0);

    final weeklyCompleted = completedTasks.where((task) {
      return _isWithinSelectedWeek(_completionDate(task.data()));
    }).toList();

    final dailyCounts = List<int>.filled(7, 0);
    final categoryCounts = <String, int>{};

    for (final task in weeklyCompleted) {
      final data = task.data();
      final completedDate = _completionDate(data);
      if (completedDate != null) {
        final weekdayIndex = completedDate.weekday - DateTime.monday;
        if (weekdayIndex >= 0 && weekdayIndex < 7) {
          dailyCounts[weekdayIndex]++;
        }
      }

      final rawCategory = (data['category'] ?? 'Pribadi').toString().trim();
      final category = rawCategory.isEmpty ? 'Pribadi' : rawCategory;
      categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
    }

    final sortedCategories = categoryCounts.entries.toList()
      ..sort((a, b) {
        final byCount = b.value.compareTo(a.value);
        return byCount != 0 ? byCount : a.key.compareTo(b.key);
      });
    final maxCategoryCount = sortedCategories.isEmpty
        ? 1
        : sortedCategories.first.value;

    return AppShell(
      selectedIndex: 0,
      onDestinationSelected: widget.onDestinationSelected,
      child: SafeArea(
        child: Container(
          color: theme.scaffoldBackgroundColor,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          tooltip: 'Kembali ke beranda',
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints.tightFor(
                            width: 36,
                            height: 36,
                          ),
                          icon: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 18,
                            color: colors.onSurface,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            'Statistik Progres',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontSize: 26,
                              height: 1.15,
                              letterSpacing: -0.45,
                              fontWeight: FontWeight.w800,
                              color: colors.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(
                      'Lihat seberapa jauh kamu sudah melangkah.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 13,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 34),
                    _buildWeekSelector(context),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            context,
                            value: '$completedCount',
                            label: 'Tugas selesai',
                          ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: _buildMetricCard(
                            context,
                            value: '${(progress * 100).round()}%',
                            label: 'Target mingguan',
                          ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: _buildMetricCard(
                            context,
                            value: '$remainingCount',
                            label: 'Menuju target',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 17),
                    _buildWeeklyRhythmCard(
                      context,
                      dailyCounts,
                      weeklyCompleted.length,
                    ),
                    const SizedBox(height: 15),
                    _buildCategoryCard(
                      context,
                      sortedCategories,
                      maxCategoryCount,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeekSelector(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: colors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(9),
        child: InkWell(
          onTap: _chooseWeek,
          borderRadius: BorderRadius.circular(9),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _weekLabel(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 5),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 16,
                  color: colors.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String value,
    required String label,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      constraints: const BoxConstraints(minHeight: 94),
      padding: const EdgeInsets.fromLTRB(11, 13, 8, 11),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colors.primary,
                fontSize: 27,
                height: 1,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.35,
              ),
            ),
          ),
          const SizedBox(height: 13),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontSize: 9.5,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyRhythmCard(
    BuildContext context,
    List<int> dailyCounts,
    int weeklyTotal,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final highest = dailyCounts.fold<int>(
  0,
  (previous, dailyCount) =>
      previous > dailyCount ? previous : dailyCount,
);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(17, 18, 17, 13),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ritme minggu ini',
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            '$weeklyTotal tugas selesai · ${_weekLabel()}',
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 11,
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 13),
          SizedBox(
            height: 118,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final count = dailyCounts[index];
                final barHeight = count == 0
                    ? 4.0
                    : 12.0 + (count / (highest == 0 ? 1 : highest)) * 66.0;

                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: index == 0 ? 0 : 4,
                      right: index == 6 ? 0 : 4,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          height: 14,
                          child: count > 0
                              ? Text(
                                  '$count',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: colors.primary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          height: barHeight,
                          width: double.infinity,
                          constraints: const BoxConstraints(maxWidth: 24),
                          decoration: BoxDecoration(
                            color: count > 0
                                ? colors.primary.withValues(
                                    alpha: count == highest ? 1 : 0.78,
                                  )
                                : colors.onSurface.withValues(alpha: 0.09),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _dayLabels[index],
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colors.onSurfaceVariant,
                            fontSize: 9.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    List<MapEntry<String, int>> categories,
    int maxCount,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(17, 18, 17, 17),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selesai per kategori',
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 14),
          if (categories.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text(
                'Belum ada tugas selesai pada minggu ini.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
            )
          else
            ...categories.map((entry) {
              final fraction = (entry.value / maxCount)
                  .clamp(0.0, 1.0)
                  .toDouble();
              return Padding(
                padding: const EdgeInsets.only(bottom: 11),
                child: Row(
                  children: [
                    SizedBox(
                      width: 105,
                      child: Text(
                        entry.key,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          fontSize: 10.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Stack(
                          children: [
                            Container(
                              height: 6,
                              width: double.infinity,
                              color: colors.onSurface.withValues(alpha: 0.09),
                            ),
                            FractionallySizedBox(
                              widthFactor: fraction,
                              child: Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  color: colors.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 17,
                      child: Text(
                        '${entry.value}',
                        textAlign: TextAlign.end,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colors.onSurface,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
