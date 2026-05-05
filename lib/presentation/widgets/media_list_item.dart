import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_player/domain/entities/media_file.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:media_player/presentation/providers/favorites_provider.dart';

class MediaListItem extends ConsumerWidget {
  final MediaFile file;
  final VoidCallback onTap;

  const MediaListItem({super.key, required this.file, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(favoritesProvider).contains(file.id);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(12),
        leading: Hero(
          tag: 'art_${file.id}',
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: file.type == MediaType.audio
                  ? QueryArtworkWidget(
                      id: int.parse(file.id),
                      type: ArtworkType.AUDIO,
                      nullArtworkWidget: Icon(Icons.music_note_rounded, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                    )
                  : Icon(Icons.play_arrow_rounded, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), size: 30),
            ),
          ),
        ),
        title: Text(
          file.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            '${file.type == MediaType.audio ? (file.artist ?? "Unknown Artist") : _formatSize(file.size)} • ${_formatDuration(file.duration)}',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), fontSize: 13),
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: isFavorite ? const Color(0xFFFF003A) : Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          onPressed: () => ref.read(favoritesProvider.notifier).toggleFavorite(file.id),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  String _formatDuration(int ms) {
    final d = Duration(milliseconds: ms);
    return '${d.inMinutes}:${d.inSeconds.remainder(60).toString().padLeft(2, '0')}';
  }

  String _formatSize(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB"];
    var i = (bytes.toString().length - 1) ~/ 3;
    var res = bytes / (1024 * (i == 0 ? 1 : i * 1024)); // Simplified for speed
    return "${res.toStringAsFixed(1)} ${suffixes[i]}";
  }
}
