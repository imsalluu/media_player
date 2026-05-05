enum MediaType { audio, video }

class MediaFile {
  final String id;
  final String title;
  final String? artist;
  final String? album;
  final String path;
  final int duration; // in milliseconds
  final int size;
  final MediaType type;
  final DateTime dateAdded;
  final String? thumbnailPath;

  MediaFile({
    required this.id,
    required this.title,
    this.artist,
    this.album,
    required this.path,
    required this.duration,
    required this.size,
    required this.type,
    required this.dateAdded,
    this.thumbnailPath,
  });
}
