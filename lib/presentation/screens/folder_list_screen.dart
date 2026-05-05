import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_player/presentation/providers/media_provider.dart';
import 'package:media_player/presentation/screens/folder_detail_screen.dart';

class FolderListScreen extends ConsumerWidget {
  const FolderListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videoFolders = ref.watch(videoFoldersProvider);
    final audioFolders = ref.watch(musicFoldersProvider);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverAppBar(
              floating: true,
              pinned: false,
              title: Text('Libraries', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text('GALLERIES', style: TextStyle(color: Color(0xFFFF003A), fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 12)),
              ),
            ),
            videoFolders.when(
              data: (folders) => SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final folder = folders[index];
                      return _FolderTile(
                        icon: Icons.video_collection_rounded,
                        name: folder.name,
                        count: folder.mediaCount,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => FolderDetailScreen(folder: folder)),
                          );
                        },
                      );
                    },
                    childCount: folders.length,
                  ),
                ),
              ),
              loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
              error: (err, _) => SliverToBoxAdapter(child: Center(child: Text('Error: $err'))),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 32, 16, 8),
                child: Text('MUSIC COLLECTIONS', style: TextStyle(color: Color(0xFFFF003A), fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 12)),
              ),
            ),
            audioFolders.when(
              data: (folders) => SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final folder = folders[index];
                      return _FolderTile(
                        icon: Icons.album_rounded,
                        name: folder.name,
                        count: folder.mediaCount,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => FolderDetailScreen(folder: folder)),
                          );
                        },
                      );
                    },
                    childCount: folders.length,
                  ),
                ),
              ),
              loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
              error: (err, _) => SliverToBoxAdapter(child: Center(child: Text('Error: $err'))),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }
}

class _FolderTile extends StatelessWidget {
  final IconData icon;
  final String name;
  final int count;
  final VoidCallback onTap;

  const _FolderTile({required this.icon, required this.name, required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFFF003A).withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: const Color(0xFFFF003A)),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        subtitle: Text('$count items', style: TextStyle(color: Colors.white.withOpacity(0.5))),
        trailing: const Icon(Icons.chevron_right, color: Colors.white24),
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1, end: 0);
  }
}
