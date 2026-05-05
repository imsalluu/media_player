import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_player/presentation/providers/audio_player_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:audio_service/audio_service.dart';

class AudioPlayerScreen extends ConsumerWidget {
  const AudioPlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final handler = ref.watch(audioHandlerProvider);
    final mediaItem = ref.watch(currentMediaItemProvider).value;
    final playbackState = ref.watch(playerStateProvider).value;

    if (mediaItem == null) {
      return const Scaffold(backgroundColor: Colors.black, body: Center(child: Text('No song selected', style: TextStyle(color: Colors.white))));
    }

    final isPlaying = playbackState?.playing ?? false;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, size: 30, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert, color: Colors.white), onPressed: () {}),
        ],
      ),
      body: Stack(
        children: [
          // Background blurs
          Positioned(
            top: -150,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                color: const Color(0xFFFF003A).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
            ),
          ).animate().fadeIn(duration: 1000.ms),
          // Main Content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 30),
                // Circular Art
                Center(
                  child: Hero(
                    tag: 'art_${mediaItem.extras?['id'] ?? mediaItem.id}',
                    child: Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white10,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF003A).withOpacity(0.5),
                            blurRadius: 50,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: QueryArtworkWidget(
                          id: int.tryParse(mediaItem.extras?['id']?.toString() ?? '') ?? 0,
                          type: ArtworkType.AUDIO,
                          artworkWidth: 500,
                          artworkHeight: 500,
                          nullArtworkWidget: const Icon(Icons.music_note, size: 100, color: Colors.white24),
                        ),
                      ),
                    ),
                  ),
                ).animate().scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack, duration: 800.ms),
                const SizedBox(height: 60),
                // Title & Artist
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      Text(
                        mediaItem.title,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        mediaItem.artist ?? 'Unknown Artist',
                        style: TextStyle(fontSize: 18, color: Colors.white.withOpacity(0.6)),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Progress
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: _ProgressControls(),
                ),
                const SizedBox(height: 40),
                // Controls
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.shuffle, color: Colors.white38),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_previous_rounded, size: 45, color: Colors.white),
                        onPressed: () => handler.skipToPrevious(),
                      ),
                      _PlayCircleButton(isPlaying: isPlaying, onTap: () => isPlaying ? handler.pause() : handler.play()),
                      IconButton(
                        icon: const Icon(Icons.skip_next_rounded, size: 45, color: Colors.white),
                        onPressed: () => handler.skipToNext(),
                      ),
                      IconButton(
                        icon: const Icon(Icons.repeat, color: Colors.white38),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayCircleButton extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onTap;
  const _PlayCircleButton({required this.isPlaying, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFFFF003A),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Color(0xFFFF003A), blurRadius: 20, spreadRadius: 2),
          ],
        ),
        child: Icon(
          isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          size: 40,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _ProgressControls extends ConsumerWidget {
  const _ProgressControls();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final position = ref.watch(positionProvider).value ?? Duration.zero;
    final item = ref.watch(currentMediaItemProvider).value;
    final duration = item?.duration ?? Duration.zero;

    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            activeTrackColor: const Color(0xFFFF003A),
            inactiveTrackColor: Colors.white.withOpacity(0.1),
            thumbColor: Colors.white,
          ),
          child: Slider(
            value: position.inMilliseconds.toDouble(),
            max: duration.inMilliseconds.toDouble() > 0 ? duration.inMilliseconds.toDouble() : 1.0,
            onChanged: (val) => ref.read(audioHandlerProvider).seek(Duration(milliseconds: val.toInt())),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatDuration(position), style: const TextStyle(color: Colors.white38, fontSize: 13)),
              Text(_formatDuration(duration), style: const TextStyle(color: Colors.white38, fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
