import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_player/core/services/audio_player_service.dart';

final audioPlayerServiceProvider = Provider((ref) {
  final service = AudioPlayerService();
  ref.onDispose(() => service.dispose());
  return service;
});

// Stream providers for player state
final playerStateProvider = StreamProvider((ref) {
  return ref.watch(audioPlayerServiceProvider).player.playerStateStream;
});

final currentSongIndexProvider = StreamProvider((ref) {
  return ref.watch(audioPlayerServiceProvider).player.currentIndexStream;
});

final positionProvider = StreamProvider((ref) {
  return ref.watch(audioPlayerServiceProvider).player.positionStream;
});

final durationProvider = StreamProvider((ref) {
  return ref.watch(audioPlayerServiceProvider).player.durationStream;
});
