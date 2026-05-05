import 'package:on_audio_query/on_audio_query.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:media_player/domain/entities/media_file.dart';
import 'package:media_player/domain/entities/media_folder.dart';

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

  Future<List<MediaFolder>> fetchAudioFolders() async {
    final List<AlbumModel> albums = await _audioQuery.queryAlbums(
      sortType: null,
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
      ignoreCase: true,
    );

    return albums.map((album) => MediaFolder(
      id: album.id.toString(),
      name: album.album,
      path: '', // AlbumModel doesn't have a direct path, but we can query by album id
      mediaCount: album.numOfSongs,
      type: MediaType.audio,
    )).toList();
  }

  Future<List<MediaFile>> fetchVideoFiles() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (!ps.isAuth) return [];

    final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
      type: RequestType.video,
    );

    List<MediaFile> videos = [];
    final Set<String> seenIds = {};

    for (var path in paths) {
      final List<AssetEntity> assets = await path.getAssetListRange(
        start: 0,
        end: 1000,
      );

      for (var asset in assets) {
        if (seenIds.contains(asset.id)) continue;
        seenIds.add(asset.id);

        final file = await asset.file;
        if (file == null) continue;

        videos.add(MediaFile(
          id: asset.id,
          title: asset.title ?? 'Unknown Video',
          path: file.path,
          duration: asset.duration * 1000,
          size: await file.length(),
          type: MediaType.video,
          dateAdded: asset.createDateTime,
          thumbnailPath: asset.id,
        ));
      }
    }
    return videos;
  }

  Future<List<MediaFolder>> fetchVideoFolders() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (!ps.isAuth) return [];

    final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
      type: RequestType.video,
    );

    final List<MediaFolder> folders = await Future.wait(paths.map((path) async {
      final count = await path.assetCountAsync;
      return MediaFolder(
        id: path.id,
        name: path.name,
        path: '',
        mediaCount: count,
        type: MediaType.video,
        firstMediaThumbnail: path.id,
      );
    }));
    return folders;
  }

  Future<List<MediaFile>> fetchAudioByAlbum(String albumId) async {
    final List<SongModel> songs = await _audioQuery.queryAudiosFrom(
      AudiosFromType.ALBUM_ID,
      int.parse(albumId),
      sortType: null,
      orderType: OrderType.ASC_OR_SMALLER,
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

  Future<List<MediaFile>> fetchVideosByFolder(String folderId) async {
    final path = await AssetPathEntity.fromId(folderId, type: RequestType.video);
    if (path == null) return [];

    final assets = await path.getAssetListRange(start: 0, end: 1000);
    List<MediaFile> videos = [];
    for (var asset in assets) {
      final file = await asset.file;
      if (file == null) continue;
      videos.add(MediaFile(
        id: asset.id,
        title: asset.title ?? 'Unknown Video',
        path: file.path,
        duration: asset.duration * 1000,
        size: await file.length(),
        type: MediaType.video,
        dateAdded: asset.createDateTime,
        thumbnailPath: asset.id,
      ));
    }
    return videos;
  }
}
