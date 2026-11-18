
import 'package:flutter/material.dart';

class AppShell extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget child;

  const AppShell({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.child,
  });

  static const double desktopBreakpoint = 800;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= desktopBreakpoint;

        if (isDesktop) {
          return Scaffold(
            body: Row(
              children: [
                _buildSidebar(context),
                Expanded(child: child),
              ],
            ),
          );
        }

        return Scaffold(
          body: child,
          bottomNavigationBar: _buildBottomNavigation(context),
        );
      },
    );
  }

  Widget _buildSidebar(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: 250,
      color: colors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
            child: Image.asset(
              'assets/images/logo.png',
              width: 145,
              fit: BoxFit.contain,
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'RUANG KERJAMU',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontSize: 9,
                letterSpacing: 1,
              ),
            ),
          ),

          const SizedBox(height: 16),

          _sidebarItem(context, 0, Icons.home_outlined, 'Beranda'),
          _sidebarItem(context, 1, Icons.check_box_outlined, 'Daftar tugas'),
          _sidebarItem(context, 3, Icons.calendar_month_outlined, 'Kalender'),
          _sidebarItem(context, 5, Icons.sell_outlined, 'Kategori & label'),
          _sidebarItem(context, 6, Icons.bar_chart_outlined, 'Statistik'),
          _sidebarItem(context, 7, Icons.notifications_none, 'Notifikasi'),

          const Spacer(),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'Satu tugas lagi?\nKamu pasti bisa.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const Divider(height: 1),

          _sidebarItem(
            context,
            4,
            Icons.person_outline,
            'Profil & pengaturan',
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _sidebarItem(
    BuildContext context,
    int index,
    IconData icon,
    String label,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isSelected = selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 3,
      ),
      child: Material(
        color: isSelected
            ? colors.primary.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => onDestinationSelected(index),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 19,
                  color: isSelected
                      ? colors.primary
                      : colors.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isSelected
                          ? colors.primary
                          : colors.onSurfaceVariant,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SafeArea(
      child: Container(
        height: 66,
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(
            top: BorderSide(
              color: theme.dividerColor.withValues(alpha: 0.3),
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _bottomItem(context, 0, Icons.home_outlined, 'Beranda'),
            _bottomItem(context, 1, Icons.check_box_outlined, 'Tugas'),

            IconButton(
              onPressed: () => onDestinationSelected(2),
              style: IconButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                fixedSize: const Size(42, 42),
              ),
              icon: const Icon(Icons.add, size: 25),
            ),

            _bottomItem(
              context,
              3,
              Icons.calendar_month_outlined,
              'Kalender',
            ),
            _bottomItem(context, 4, Icons.person_outline, 'Profil'),
          ],
        ),
      ),
    );
  }

  Widget _bottomItem(
    BuildContext context,
    int index,
    IconData icon,
    String label,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isSelected = selectedIndex == index;

    return InkWell(
      onTap: () => onDestinationSelected(index),
      child: SizedBox(
        width: 62,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? colors.primary
                  : colors.onSurfaceVariant,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 9,
                color: isSelected
                    ? colors.primary
                    : colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
