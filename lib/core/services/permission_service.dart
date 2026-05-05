import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class PermissionService {
  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      
      if (androidInfo.version.sdkInt >= 33) {
        // Android 13+ requires specific media permissions
        final audio = await Permission.audio.request();
        final video = await Permission.videos.request();
        final photos = await Permission.photos.request();
        
        return audio.isGranted && video.isGranted && photos.isGranted;
      } else {
        // Older Android versions
        final storage = await Permission.storage.request();
        return storage.isGranted;
      }
    }
    return true; // iOS handles this differently or permissions are handled by individual plugins
  }

  static Future<bool> checkPermissionStatus() async {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      
      if (androidInfo.version.sdkInt >= 33) {
        final audio = await Permission.audio.status;
        final video = await Permission.videos.status;
        final photos = await Permission.photos.status;
        
        return audio.isGranted && video.isGranted && photos.isGranted;
      } else {
        final storage = await Permission.storage.status;
        return storage.isGranted;
      }
    }
    return true;
  }
}
