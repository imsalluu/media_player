import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_player/presentation/providers/theme_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverAppBar(
              floating: true,
              pinned: false,
              title: Text('Settings', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                _SectionHeader(title: 'APPEARANCE'),
                _SettingsTile(
                  icon: Icons.palette_rounded,
                  title: 'Theme Mode',
                  subtitle: themeMode.name.toUpperCase(),
                  onTap: () => _showThemeDialog(context, ref),
                ),
                const SizedBox(height: 16),
                _SectionHeader(title: 'PLAYBACK'),
                _SettingsSwitchTile(
                  icon: Icons.skip_next_rounded,
                  title: 'Auto-play Next',
                  subtitle: 'Play the next track automatically',
                  value: true,
                  onChanged: (val) {},
                ),
                _SettingsSwitchTile(
                  icon: Icons.loop_rounded,
                  title: 'Loop Playback',
                  subtitle: 'Repeat current track/list',
                  value: false,
                  onChanged: (val) {},
                ),
                const SizedBox(height: 16),
                _SectionHeader(title: 'ABOUT'),
                FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snapshot) {
                    final version = snapshot.data?.version ?? '1.0.0';
                    return _SettingsTile(
                      icon: Icons.info_outline_rounded,
                      title: 'App Version',
                      subtitle: 'v$version',
                    );
                  },
                ),
                const _SettingsTile(
                  icon: Icons.code_rounded,
                  title: 'Developer',
                  subtitle: 'Senior Flutter Expert (Salman Hossain)',
                ),
                const SizedBox(height: 60),
                const Center(
                  child: Text(
                    'DESIGNED FOR PREMIUM EXPERIENCE',
                    style: TextStyle(color: Colors.white24, fontSize: 10, letterSpacing: 2),
                  ),
                ),
                const SizedBox(height: 120),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF121212),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select Theme', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 16),
            _ThemeOption(mode: ThemeMode.system, icon: Icons.brightness_auto, label: 'System Default'),
            _ThemeOption(mode: ThemeMode.light, icon: Icons.light_mode, label: 'Light Mode'),
            _ThemeOption(mode: ThemeMode.dark, icon: Icons.dark_mode, label: 'Dark Mode'),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Text(
        title,
        style: const TextStyle(color: Color(0xFFFF003A), fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.5),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _SettingsTile({required this.icon, required this.title, required this.subtitle, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: Colors.white70),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.5))),
        trailing: onTap != null ? const Icon(Icons.chevron_right, color: Colors.white24) : null,
      ),
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitchTile({required this.icon, required this.title, required this.subtitle, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20)),
      child: SwitchListTile(
        secondary: Icon(icon, color: Colors.white70),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.5))),
        value: value,
        activeColor: const Color(0xFFFF003A),
        onChanged: onChanged,
      ),
    );
  }
}

class _ThemeOption extends ConsumerWidget {
  final ThemeMode mode;
  final IconData icon;
  final String label;

  const _ThemeOption({required this.mode, required this.icon, required this.label});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMode = ref.watch(themeProvider);
    final isSelected = currentMode == mode;

    return ListTile(
      leading: Icon(icon, color: isSelected ? const Color(0xFFFF003A) : Colors.white54),
      title: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.white54, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      trailing: isSelected ? const Icon(Icons.check_circle, color: Color(0xFFFF003A)) : null,
      onTap: () {
        ref.read(themeProvider.notifier).setThemeMode(mode);
        Navigator.pop(context);
      },
    );
  }
}
