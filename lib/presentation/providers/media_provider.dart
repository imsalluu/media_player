import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_player/core/services/media_service.dart';
import 'package:media_player/domain/entities/media_file.dart';
import 'package:media_player/domain/entities/media_folder.dart';

final mediaServiceProvider = Provider((ref) => MediaService());

final audioFilesProvider = FutureProvider<List<MediaFile>>((ref) {
  return ref.watch(mediaServiceProvider).fetchAudioFiles();
});

final videoFilesProvider = FutureProvider<List<MediaFile>>((ref) {
  return ref.watch(mediaServiceProvider).fetchVideoFiles();
});

enum SortOption { name, date, size }

final searchQueryProvider = StateProvider<String>((ref) => '');
final sortOptionProvider = StateProvider<SortOption>((ref) => SortOption.date);

final filteredAudioProvider = Provider<AsyncValue<List<MediaFile>>>((ref) {
  final audioAsync = ref.watch(audioFilesProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final sort = ref.watch(sortOptionProvider);

  return audioAsync.whenData((list) {
    var filtered = list.where((item) {
      return item.title.toLowerCase().contains(query) ||
             (item.artist?.toLowerCase().contains(query) ?? false);
    }).toList();

    switch (sort) {
      case SortOption.name:
        filtered.sort((a, b) => a.title.compareTo(b.title));
        break;
      case SortOption.date:
        filtered.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
        break;
      case SortOption.size:
        filtered.sort((a, b) => b.size.compareTo(a.size));
        break;
    }
    return filtered;
  });
});

final filteredVideoProvider = Provider<AsyncValue<List<MediaFile>>>((ref) {
  final videoAsync = ref.watch(videoFilesProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final sort = ref.watch(sortOptionProvider);

  return videoAsync.whenData((list) {
    var filtered = list.where((item) {
      return item.title.toLowerCase().contains(query);
    }).toList();

    switch (sort) {
      case SortOption.name:
        filtered.sort((a, b) => a.title.compareTo(b.title));
        break;
      case SortOption.date:
        filtered.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
        break;
      case SortOption.size:
        filtered.sort((a, b) => b.size.compareTo(a.size));
        break;
    }
    return filtered;
  });
});

final videoFoldersProvider = FutureProvider<List<MediaFolder>>((ref) {
  return ref.watch(mediaServiceProvider).fetchVideoFolders();
});

final musicFoldersProvider = FutureProvider<List<MediaFolder>>((ref) {
  return ref.watch(mediaServiceProvider).fetchAudioFolders();
});
final audioByFolderProvider = FutureProvider.family<List<MediaFile>, String>((ref, folderId) {
  return ref.watch(mediaServiceProvider).fetchAudioByAlbum(folderId);
});

final videoByFolderProvider = FutureProvider.family<List<MediaFile>, String>((ref, folderId) {
  return ref.watch(mediaServiceProvider).fetchVideosByFolder(folderId);
});
