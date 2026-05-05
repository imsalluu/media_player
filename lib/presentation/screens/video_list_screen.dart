import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_player/presentation/providers/media_provider.dart';
import 'package:media_player/presentation/screens/video_player_screen.dart';
import 'package:photo_manager/photo_manager.dart';

class VideoListScreen extends ConsumerWidget {
  const VideoListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videoAsync = ref.watch(filteredVideoProvider);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              pinned: false,
              title: const Text('Cinematics', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              actions: [
                IconButton(icon: const Icon(Icons.search), onPressed: () {}),
                const SizedBox(width: 8),
              ],
            ),
            videoAsync.when(
              data: (videos) => SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final video = videos[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VideoPlayerScreen(
                                videos: videos,
                                initialIndex: index,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      FutureBuilder<AssetEntity?>(
                                        future: AssetEntity.fromId(video.id),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData && snapshot.data != null) {
                                            return FutureBuilder<Uint8List?>(
                                              future: snapshot.data!.thumbnailData,
                                              builder: (context, thumbSnapshot) {
                                                if (thumbSnapshot.hasData && thumbSnapshot.data != null) {
                                                  return Image.memory(thumbSnapshot.data!, fit: BoxFit.cover);
                                                }
                                                return Container(color: Colors.white10);
                                              },
                                            );
                                          }
                                          return Container(color: Colors.white10);
                                        },
                                      ),
                                      const Center(
                                        child: Icon(Icons.play_circle_outline, size: 40, color: Colors.white70),
                                      ),
                                      Positioned(
                                        bottom: 10,
                                        right: 10,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
                                          child: Text(_formatDuration(video.duration), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text(video.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: (50 * index).ms).scale(begin: const Offset(0.9, 0.9));
                    },
                    childCount: videos.length,
                  ),
                ),
              ),
              loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
              error: (err, stack) => SliverFillRemaining(child: Center(child: Text('Error: $err'))),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int ms) {
    final d = Duration(milliseconds: ms);
    return '${d.inMinutes}:${d.inSeconds.remainder(60).toString().padLeft(2, '0')}';
  }
}
