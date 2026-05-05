import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_player/core/services/audio_handler.dart';
import 'package:audio_service/audio_service.dart';

// This will be overridden in main.dart
final audioHandlerProvider = Provider<MyAudioHandler>((ref) {
  throw UnimplementedError();
});

final playerStateProvider = StreamProvider<PlaybackState>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return handler.playbackState.stream;
});

final currentMediaItemProvider = StreamProvider<MediaItem?>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return handler.mediaItem.stream;
});

final positionProvider = StreamProvider<Duration>((ref) {
  return AudioService.position;
});

final durationProvider = Provider<Duration?>((ref) {
  final item = ref.watch(currentMediaItemProvider).value;
  return item?.duration;
});
