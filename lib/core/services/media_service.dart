import 'package:on_audio_query/on_audio_query.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:media_player/domain/entities/media_file.dart';

class MediaService {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  Future<List<MediaFile>> fetchAudioFiles() async {
    final List<SongModel> songs = await _audioQuery.querySongs(
      sortType: null,
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
      ignoreCase: true,
    );

    return songs.map((song) => MediaFile(
      id: song.id.toString(),
      title: song.title,
      artist: song.artist,
      album: song.album,
      path: song.data,
      duration: song.duration ?? 0,
      size: song.size,
      type: MediaType.audio,
      dateAdded: DateTime.fromMillisecondsSinceEpoch((song.dateAdded ?? 0) * 1000),
    )).toList();
  }

  Future<List<MediaFile>> fetchVideoFiles() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (!ps.isAuth) return [];

    final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
      type: RequestType.video,
    );

    List<MediaFile> videos = [];
    for (var path in paths) {
      final List<AssetEntity> assets = await path.getAssetListRange(
        start: 0,
        end: 1000, // Reasonable limit
      );

      for (var asset in assets) {
        final file = await asset.file;
        if (file == null) continue;

        videos.add(MediaFile(
          id: asset.id,
          title: asset.title ?? 'Unknown Video',
          path: file.path,
          duration: asset.duration * 1000, // PhotoManager duration is in seconds
          size: await file.length(),
          type: MediaType.video,
          dateAdded: asset.createDateTime,
          thumbnailPath: asset.id, // We'll use AssetEntity to show thumbnails directly in UI
        ));
      }
    }
    return videos;
  }
}
