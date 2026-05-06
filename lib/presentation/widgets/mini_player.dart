import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_player/presentation/providers/audio_player_provider.dart';
import 'package:media_player/presentation/screens/audio_player_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:audio_service/audio_service.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final handler = ref.watch(audioHandlerProvider);
    final mediaItem = ref.watch(currentMediaItemProvider).value;
    final playbackState = ref.watch(playerStateProvider).value;
    
    if (mediaItem == null) {
      return const SizedBox.shrink();
    }

    final isPlaying = playbackState?.playing ?? false;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AudioPlayerScreen()),
        );
      },
      child: Container(
        height: 70,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1)),
              ),
              child: Stack(
                children: [
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _MiniProgressBar(),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Row(
                      children: [
                        Hero(
                          tag: 'art_${mediaItem.extras?['id'] ?? mediaItem.id}',
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: QueryArtworkWidget(
                                id: int.tryParse(mediaItem.extras?['id']?.toString() ?? '') ?? 0,
                                type: ArtworkType.AUDIO,
                                nullArtworkWidget: Icon(Icons.music_note_rounded, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                mediaItem.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
                              ),
                              Text(
                                mediaItem.artist ?? 'Unknown Artist',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          onPressed: () => isPlaying ? handler.pause() : handler.play(),
                        ),
                        IconButton(
                          icon: Icon(Icons.skip_next_rounded, color: Theme.of(context).colorScheme.onSurface),
                          onPressed: () => handler.skipToNext(),
                        ),
                        IconButton(
                          icon: Icon(Icons.close_rounded, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                          onPressed: () => handler.stop(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ).animate().slideY(begin: 1, end: 0, duration: 400.ms, curve: Curves.easeOutBack),
    );
  }
}

class _MiniProgressBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final position = ref.watch(positionProvider).value ?? Duration.zero;
    final item = ref.watch(currentMediaItemProvider).value;
    final duration = item?.duration ?? Duration.zero;
    
    final progress = duration.inMilliseconds > 0 
        ? position.inMilliseconds / duration.inMilliseconds 
        : 0.0;

    return LinearProgressIndicator(
      value: progress.clamp(0.0, 1.0),
      minHeight: 2,
      backgroundColor: Colors.transparent,
      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF003A)),
    );
  }
}
