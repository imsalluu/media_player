import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:media_player/domain/entities/media_file.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_player/presentation/providers/favorites_provider.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:volume_controller/volume_controller.dart';

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
  
  double _volumeValue = 0.5;
  double _brightnessValue = 0.5;
  bool _showOverlay = false;
  String _overlayText = '';
  IconData _overlayIcon = Icons.volume_up;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _initializePlayer();
    WakelockPlus.enable();
    _initVolumeAndBrightness();
  }

  Future<void> _initVolumeAndBrightness() async {
    _volumeValue = await VolumeController.instance.getVolume();
    try {
      _brightnessValue = await ScreenBrightness().application;
    } catch (e) {
      _brightnessValue = 0.5;
    }
  }

  Future<void> _initializePlayer() async {
    final video = widget.videos[_currentIndex];
    
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
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ],
      placeholder: Container(color: Colors.black),
      autoInitialize: true,
      allowMuting: true,
      showControls: true,
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

  void _handleVerticalDragUpdate(DragUpdateDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLeftSide = details.localPosition.dx < screenWidth / 2;
    final delta = details.primaryDelta! / -200; // Adjust sensitivity

    if (isLeftSide) {
      // Volume
      _volumeValue = (_volumeValue + delta).clamp(0.0, 1.0);
      VolumeController.instance.setVolume(_volumeValue);
      _showGestureOverlay(
        icon: _volumeValue == 0 ? Icons.volume_off : Icons.volume_up,
        text: '${(_volumeValue * 100).toInt()}%',
      );
    } else {
      // Brightness
      _brightnessValue = (_brightnessValue + delta).clamp(0.0, 1.0);
      ScreenBrightness().setApplicationScreenBrightness(_brightnessValue);
      _showGestureOverlay(
        icon: Icons.brightness_6,
        text: '${(_brightnessValue * 100).toInt()}%',
      );
    }
  }

  void _showGestureOverlay({required IconData icon, required String text}) {
    setState(() {
      _overlayIcon = icon;
      _overlayText = text;
      _showOverlay = true;
    });
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _showOverlay = false;
        });
      }
    });
  }

  void _seekForward() {
    final currentPosition = _videoPlayerController.value.position;
    final duration = _videoPlayerController.value.duration;
    final newPosition = currentPosition + const Duration(seconds: 10);
    
    if (newPosition < duration) {
      _videoPlayerController.seekTo(newPosition);
    } else {
      _videoPlayerController.seekTo(duration);
    }
    _showGestureOverlay(icon: Icons.forward_10, text: '+10s');
  }

  @override
  void dispose() {
    WakelockPlus.disable();
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
                ? GestureDetector(
                    onVerticalDragUpdate: _handleVerticalDragUpdate,
                    onDoubleTap: _seekForward,
                    child: Chewie(controller: _chewieController!),
                  )
                : const CircularProgressIndicator(color: Color(0xFFFF003A)),
          ),
          if (_showOverlay)
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_overlayIcon, color: Colors.white, size: 40),
                    const SizedBox(height: 8),
                    Text(_overlayText, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          if (!_isFullScreen)
            Positioned(
              bottom: 40,
              right: 20,
              child: FloatingActionButton(
                backgroundColor: const Color(0xFFFF003A),
                onPressed: _currentIndex < widget.videos.length - 1 ? _nextVideo : null,
                child: const Icon(Icons.skip_next_rounded, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}

