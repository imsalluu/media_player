import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_player/presentation/providers/media_provider.dart';
import 'package:media_player/presentation/widgets/media_list_item.dart';
import 'package:media_player/presentation/providers/audio_player_provider.dart';
import 'package:media_player/presentation/screens/audio_player_screen.dart';


class MusicListScreen extends ConsumerWidget {
  const MusicListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioAsync = ref.watch(filteredAudioProvider);
    final searchController = TextEditingController(text: ref.read(searchQueryProvider));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Music'),
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
                hintText: 'Search music...',
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
            child: audioAsync.when(
              data: (songs) {
                if (songs.isEmpty) {
                  return const Center(child: Text('No music found'));
                }
                return ListView.builder(
                  itemCount: songs.length,
                  itemBuilder: (context, index) {
                    final song = songs[index];
                    return MediaListItem(
                      file: song,
                      onTap: () {
                        ref.read(audioPlayerServiceProvider).setPlaylist(songs, index);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AudioPlayerScreen()),
                        );
                      },
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
