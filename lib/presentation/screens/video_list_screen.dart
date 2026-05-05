import 'dart:typed_data';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_player/presentation/providers/media_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:media_player/presentation/screens/video_player_screen.dart';

class VideoListScreen extends ConsumerWidget {
  const VideoListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videoAsync = ref.watch(filteredVideoProvider);
    final searchController = TextEditingController(text: ref.read(searchQueryProvider));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Videos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () => _showSortDialog(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search videos...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) => ref.read(searchQueryProvider.notifier).state = value,
            ),
          ),
          Expanded(
            child: videoAsync.when(
              data: (videos) {
                if (videos.isEmpty) {
                  return const Center(child: Text('No videos found'));
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: videos.length,
                  itemBuilder: (context, index) {
                    final video = videos[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VideoPlayerScreen(video: video),
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
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
                                              return Image.memory(
                                                thumbSnapshot.data!,
                                                fit: BoxFit.cover,
                                              );
                                            }
                                            return Container(color: Colors.grey[800]);
                                          },
                                        );
                                      }
                                      return Container(color: Colors.grey[800]);
                                    },
                                  ),
                                  const Center(
                                    child: Icon(Icons.play_circle_fill, size: 40, color: Colors.white70),
                                  ),
                                  Positioned(
                                    bottom: 4,
                                    right: 4,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        _formatDuration(video.duration),
                                        style: const TextStyle(color: Colors.white, fontSize: 10),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            video.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int ms) {
    final duration = Duration(milliseconds: ms);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  void _showSortDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort By'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Date Added'),
              leading: Radio<SortOption>(
                value: SortOption.date,
                groupValue: ref.watch(sortOptionProvider),
                onChanged: (val) {
                  ref.read(sortOptionProvider.notifier).state = val!;
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('Name'),
              leading: Radio<SortOption>(
                value: SortOption.name,
                groupValue: ref.watch(sortOptionProvider),
                onChanged: (val) {
                  ref.read(sortOptionProvider.notifier).state = val!;
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('Size'),
              leading: Radio<SortOption>(
                value: SortOption.size,
                groupValue: ref.watch(sortOptionProvider),
                onChanged: (val) {
                  ref.read(sortOptionProvider.notifier).state = val!;
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
