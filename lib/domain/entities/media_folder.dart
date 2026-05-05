import 'package:media_player/domain/entities/media_file.dart';

class MediaFolder {
  final String id;
  final String name;
  final String path;
  final int mediaCount;
  final MediaType type; // To distinguish between music folders and video folders
  final String? firstMediaThumbnail; // ID of the first item for preview

  MediaFolder({
    required this.id,
    required this.name,
    required this.path,
    required this.mediaCount,
    required this.type,
    this.firstMediaThumbnail,
  });
}
