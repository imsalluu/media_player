import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_player/core/services/permission_service.dart';
import 'package:media_player/presentation/screens/music_list_screen.dart';
import 'package:media_player/presentation/screens/video_list_screen.dart';
import 'package:media_player/presentation/screens/folder_list_screen.dart';
import 'package:media_player/presentation/screens/settings_screen.dart';
import 'package:media_player/presentation/widgets/mini_player.dart';
import 'package:media_player/presentation/providers/audio_player_provider.dart';

import 'dart:ui';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;
  bool _permissionsGranted = false;

  final List<Widget> _screens = [
    const VideoListScreen(),
    const MusicListScreen(),
    const FolderListScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final granted = await PermissionService.checkPermissionStatus();
    setState(() {
      _permissionsGranted = granted;
    });
    if (!granted) {
      _requestPermissions();
    }
  }

  Future<void> _requestPermissions() async {
    final granted = await PermissionService.requestStoragePermission();
    setState(() {
      _permissionsGranted = granted;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_permissionsGranted) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.security, size: 64, color: Color(0xFFFF003A)),
              const SizedBox(height: 16),
              const Text('Storage Permission Required', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF003A), foregroundColor: Colors.white),
                onPressed: _requestPermissions,
                child: const Text('Grant Permission'),
              ),
            ],
          ),
        ),
      );
    }

    final hasActiveMedia = ref.watch(currentMediaItemProvider).value != null;

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          // Mini Player
          if (hasActiveMedia)
            Positioned(
              bottom: 90, // Above nav bar
              left: 0,
              right: 0,
              child: const MiniPlayer(),
            ),
          // Custom Glass Nav Bar
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: _GlassNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const _GlassNavigationBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavIcon(icon: Icons.movie_outlined, activeIcon: Icons.movie, isActive: currentIndex == 0, onTap: () => onTap(0)),
              _NavIcon(icon: Icons.music_note_outlined, activeIcon: Icons.music_note, isActive: currentIndex == 1, onTap: () => onTap(1)),
              _NavIcon(icon: Icons.folder_outlined, activeIcon: Icons.folder, isActive: currentIndex == 2, onTap: () => onTap(2)),
              _NavIcon(icon: Icons.settings_outlined, activeIcon: Icons.settings, isActive: currentIndex == 3, onTap: () => onTap(3)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final bool isActive;
  final VoidCallback onTap;

  const _NavIcon({required this.icon, required this.activeIcon, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? activeIcon : icon,
            color: isActive ? const Color(0xFFFF003A) : Colors.white.withOpacity(0.5),
            size: 28,
          ),
          if (isActive)
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 4,
              height: 4,
              decoration: const BoxDecoration(color: Color(0xFFFF003A), shape: BoxShape.circle),
            ),
        ],
      ),
    );
  }
}
