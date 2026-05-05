import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:media_player/domain/entities/media_file.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_player/presentation/providers/favorites_provider.dart';
import 'package:flutter/services.dart';

class VideoPlayerScreen extends ConsumerStatefulWidget {
  final List<MediaFile> videos;
  final int initialIndex;

  const VideoPlayerScreen({
    super.key,
    required this.videos,
    required this.initialIndex,
  });

  @override
  ConsumerState<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends ConsumerState<VideoPlayerScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  late int _currentIndex;
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    final video = widget.videos[_currentIndex];
    
    // Dispose old controller if switching videos
    if (mounted && _chewieController != null) {
      await _videoPlayerController.dispose();
      _chewieController?.dispose();
    }

    _videoPlayerController = VideoPlayerController.file(File(video.path));
    await _videoPlayerController.initialize();
    
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: false,
      aspectRatio: _videoPlayerController.value.aspectRatio,
      materialProgressColors: ChewieProgressColors(
        playedColor: const Color(0xFFFF003A),
        handleColor: const Color(0xFFFF003A),
        backgroundColor: Colors.grey,
        bufferedColor: Colors.white24,
      ),
      deviceOrientationsAfterFullScreen: [
        DeviceOrientation.portraitUp,
      ],
      placeholder: Container(color: Colors.black),
      autoInitialize: true,
    );
    
    if (mounted) setState(() {});
    
    ref.read(recentProvider.notifier).addToRecent(video.id);
  }

  void _nextVideo() {
    if (_currentIndex < widget.videos.length - 1) {
      setState(() {
        _currentIndex++;
        _initializePlayer();
      });
    }
  }

  void _toggleRotation() {
    if (_isFullScreen) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
    setState(() {
      _isFullScreen = !_isFullScreen;
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final video = widget.videos[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _isFullScreen 
          ? null 
          : AppBar(
              title: Text(video.title, style: const TextStyle(color: Colors.white, fontSize: 16)),
              backgroundColor: Colors.black,
              iconTheme: const IconThemeData(color: Colors.white),
              actions: [
                IconButton(
                  icon: const Icon(Icons.screen_rotation_rounded),
                  onPressed: _toggleRotation,
                ),
              ],
            ),
      body: Stack(
        children: [
          Center(
            child: _chewieController != null && _chewieController!.videoPlayerController.value.isInitialized
                ? Chewie(controller: _chewieController!)
                : const CircularProgressIndicator(color: Color(0xFFFF003A)),
          ),
          if (!_isFullScreen)
            Positioned(
              bottom: 40,
              right: 20,
              child: FloatingActionButton(
                backgroundColor: const Color(0xFFFF003A),
                child: const Icon(Icons.skip_next_rounded, color: Colors.white),
                onPressed: _currentIndex < widget.videos.length - 1 ? _nextVideo : null,
              ),
            ),
        ],
      ),
    );
  }
}
