
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../providers/theme_provider.dart';
import '../services/auth_service.dart';
import '../widgets/app_shell.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';
import 'calendar_screen.dart';
import 'tasks_screen.dart';
import 'reminder_settings_screen.dart';
import 'notifications_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    
return AppShell(
  selectedIndex: 4,
  onDestinationSelected: (index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const DashboardScreen(),
        ),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const CalendarScreen(),
        ),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const TasksScreen(),
        ),
      );
    } else if (index == 7) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => const NotificationsScreen(),
    ),
  );
} else if (index != 4) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Halaman ini akan segera tersedia.'),
    ),
  );
}
    
  },
  child: _ProfileContent(user: user),
  
);


  }
}

class _ProfileContent extends StatelessWidget {
  final User? user;

  const _ProfileContent({required this.user});

  String get _profileInitials {
    final name = (user?.displayName?.trim().isNotEmpty == true)
        ? user!.displayName!.trim()
        : (user?.email?.split('@').first ?? 'Pengguna');
    final parts = name.split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();
    if (parts.isEmpty) return 'P';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 800;

        return Container(
          color: theme.scaffoldBackgroundColor,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 32 : 16,
                vertical: 20,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isDesktop) _buildDesktopHeader(context),

                      Text(
                        'Profil & pengaturan',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.onSurface,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        'Personalisasi Daymark sesuai caramu.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),

                      const SizedBox(height: 24),

                      if (isDesktop)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 7,
                              child: _buildMainProfile(context),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              flex: 3,
                              child: _buildMascotCard(context),
                            ),
                          ],
                        )
                      else
                        Column(
                          children: [
                            _buildUserCard(context),
                            const SizedBox(height: 16),
                            _buildSettingsCard(context),
                            const SizedBox(height: 16),
                            _buildLogoutButton(context),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Row(
        children: [
          Text(
            'Ruang kerja  /  Personal',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: 250,
            height: 38,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari tugas atau kategori...',
                hintStyle: const TextStyle(fontSize: 11),
                prefixIcon: const Icon(Icons.search, size: 17),
                filled: true,
                fillColor: colors.surface,
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),
          Text(
            user?.displayName ?? 'Pengguna',
            style: theme.textTheme.labelMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildMainProfile(BuildContext context) {
    return Column(
      children: [
        _buildUserCard(context),
        const SizedBox(height: 16),
        _buildSettingsCard(context),
        const SizedBox(height: 16),
        _buildLogoutButton(context),
      ],
    );
  }

  Widget _buildUserCard(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: colors.surface,
            backgroundImage: user?.photoURL != null
                ? NetworkImage(user!.photoURL!)
                : null,
            child: user?.photoURL == null
                ? Text(
                    _profileInitials,
                    style: TextStyle(
                      color: colors.primary,
                      fontSize: 21,
                      letterSpacing: 0.2,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.displayName ?? 'Pengguna Daymark',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  user?.email ?? '-',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final themeProvider = ThemeProviderScope.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _settingItem(
            context,
            icon: Icons.person_outline,
            title: 'Informasi profil',
            subtitle: 'Nama, email, dan foto profil',
            onTap: () => _showInfoDialog(
              context,
              'Informasi profil',
              'Pengaturan nama, email, dan foto profil akan tersedia di sini.',
            ),
          ),
          _settingItem(
            context,
            icon: Icons.lock_outline,
            title: 'Keamanan akun',
            subtitle: 'Ubah kata sandi',
            onTap: () => _showInfoDialog(
              context,
              'Keamanan akun',
              'Pengaturan keamanan akun akan tersedia di sini.',
            ),
          ),
          _settingItem(
            context,
            icon: Icons.palette_outlined,
            title: 'Tema aplikasi',
            subtitle: themeProvider.isDarkMode ? 'Gelap' : 'Terang',
            onTap: () => _showThemeDialog(context),
          ),
          _settingItem(
            context,
            icon: Icons.language,
            title: 'Bahasa',
            subtitle: 'Bahasa Indonesia',
            onTap: () => _showInfoDialog(
              context,
              'Bahasa',
              'Saat ini Daymark menggunakan Bahasa Indonesia.',
            ),
          ),
 
_settingItem(
  context,
  icon: Icons.notifications_none,
  title: 'Pengingat & notifikasi',
  subtitle: 'Atur waktu pemberitahuan',
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ReminderSettingsScreen(),
      ),
    );
  },
),

_settingItem(
  context,
  icon: Icons.notifications_active_outlined,
  title: 'Kotak masuk notifikasi',
  subtitle: 'Lihat pemberitahuan dan aktivitas terbaru',
  showDivider: false,
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const NotificationsScreen(),
      ),
    );
  },
),


        ],
      ),
    );
  }

  Widget _settingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: colors.onSurfaceVariant,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            color: theme.dividerColor.withValues(alpha: 0.3),
          ),
      ],
    );
  }

  Widget _buildMascotCard(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Image.asset(
            'assets/images/maskot.png',
            height: 170,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Daymark selalu menemani.',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Terima kasih telah merawat ruang untuk langkah kecil setiap hari.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: () => _confirmLogout(context),
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.onSurface,
          side: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.5),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text('Keluar dari akun'),
      ),
    );
  }


  void _showThemeDialog(BuildContext context) {
    final provider = ThemeProviderScope.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Tema aplikasi'),
          content: RadioGroup<ThemeMode>(
            groupValue: provider.themeMode,
            onChanged: (value) {
              if (value != null) {
                provider.setThemeMode(value);
                Navigator.pop(dialogContext);
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                RadioListTile<ThemeMode>(
                  title: Text('Terang'),
                  value: ThemeMode.light,
                ),
                RadioListTile<ThemeMode>(
                  title: Text('Gelap'),
                  value: ThemeMode.dark,
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  void _showInfoDialog(
    BuildContext context,
    String title,
    String message,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Keluar dari akun?'),
        content: const Text(
          'Apakah kamu yakin ingin keluar dari akun Daymark?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await AuthService.signOut();

      if (!context.mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal keluar: $e')),
      );
    }
  }
}
