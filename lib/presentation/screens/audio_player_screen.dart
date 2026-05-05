import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_player/presentation/providers/audio_player_provider.dart';
import 'package:media_player/presentation/providers/media_provider.dart';
import 'package:media_player/presentation/providers/favorites_provider.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerScreen extends ConsumerWidget {
  const AudioPlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerService = ref.watch(audioPlayerServiceProvider);
    final playerState = ref.watch(playerStateProvider).value;
    final position = ref.watch(positionProvider).value ?? Duration.zero;
    final duration = ref.watch(durationProvider).value ?? Duration.zero;
    final currentIndex = ref.watch(currentSongIndexProvider).value;
    
    // We need the original list to get song details. 
    // Ideally, currentSongIndex should map to the playlist in playerService.
    // For simplicity, we'll assume we're playing from filteredAudioProvider.
    final songs = ref.watch(filteredAudioProvider).value ?? [];
    final currentSong = (currentIndex != null && currentIndex < songs.length) ? songs[currentIndex] : null;

    ref.listen(currentSongIndexProvider, (previous, next) {
      if (next.value != null && next.value! < songs.length) {
        ref.read(recentProvider.notifier).addToRecent(songs[next.value!].id);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Now Playing'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Album Art Placeholder
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                Icons.music_note,
                size: 150,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 48),
            
            // Title and Artist
            Text(
              currentSong?.title ?? 'Unknown',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              currentSong?.artist ?? 'Unknown Artist',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            
            // Progress Bar
            ProgressBar(
              progress: position,
              total: duration,
              onSeek: (duration) {
                playerService.seek(duration);
              },
              progressBarColor: Theme.of(context).colorScheme.primary,
              baseBarColor: Theme.of(context).colorScheme.primary.withOpacity(0.24),
              thumbColor: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            
            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.shuffle),
                  onPressed: () {
                    // Toggle shuffle
                  },
                ),
                IconButton(
                  iconSize: 48,
                  icon: const Icon(Icons.skip_previous_rounded),
                  onPressed: () => playerService.player.seekToPrevious(),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    iconSize: 64,
                    color: Theme.of(context).colorScheme.onPrimary,
                    icon: Icon(
                      playerState?.playing == true ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    ),
                    onPressed: () {
                      if (playerState?.playing == true) {
                        playerService.pause();
                      } else {
                        playerService.resume();
                      }
                    },
                  ),
                ),
                IconButton(
                  iconSize: 48,
                  icon: const Icon(Icons.skip_next_rounded),
                  onPressed: () => playerService.player.seekToNext(),
                ),
                IconButton(
                  icon: const Icon(Icons.repeat),
                  onPressed: () {
                    // Toggle repeat
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
