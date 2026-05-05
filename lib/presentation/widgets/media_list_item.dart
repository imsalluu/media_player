import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:media_player/presentation/providers/favorites_provider.dart';
import 'package:media_player/domain/entities/media_file.dart';

class MediaListItem extends ConsumerWidget {
  final MediaFile file;
  final VoidCallback onTap;

  const MediaListItem({
    super.key,
    required this.file,
    required this.onTap,
  });

  String _formatDuration(int ms) {
    final duration = Duration(milliseconds: ms);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatSize(int bytes) {
    if (bytes <= 0) return "0 B";
    if (bytes < 1000) return "$bytes B";
    if (bytes < 1000000) return "${(bytes / 1024).toStringAsFixed(1)} KB";
    if (bytes < 1000000000) return "${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB";
    return "${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(favoritesProvider).contains(file.id);

    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          file.type == MediaType.audio ? Icons.music_note : Icons.video_library,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
      title: Text(
        file.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${file.type == MediaType.audio ? (file.artist ?? "Unknown Artist") : _formatSize(file.size)} • ${_formatDuration(file.duration)}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        icon: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: isFavorite ? Colors.red : null,
        ),
        onPressed: () {
          ref.read(favoritesProvider.notifier).toggleFavorite(file.id);
        },
      ),
    );
  }
}
