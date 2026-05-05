import 'package:just_audio/just_audio.dart';
import 'package:media_player/domain/entities/media_file.dart';
import 'package:audio_service/audio_service.dart';

class AudioPlayerService {
  final AudioPlayer _player = AudioPlayer();
  
  AudioPlayer get player => _player;

  Future<void> play(MediaFile file) async {
    try {
      await _player.setFilePath(file.path);
      _player.play();
    } catch (e) {
      print("Error playing audio: $e");
    }
  }

  Future<void> setPlaylist(List<MediaFile> files, int initialIndex) async {
    final playlist = ConcatenatingAudioSource(
      children: files.map((file) => AudioSource.file(file.path, tag: MediaItem(
        id: file.id,
        title: file.title,
        artist: file.artist,
        album: file.album,
      ))).toList(),
    );

    await _player.setAudioSource(playlist, initialIndex: initialIndex);
    _player.play();
  }

  void pause() => _player.pause();
  void resume() => _player.play();
  void seek(Duration position) => _player.seek(position);
  void stop() => _player.stop();
  
  void dispose() {
    _player.dispose();
  }
}
