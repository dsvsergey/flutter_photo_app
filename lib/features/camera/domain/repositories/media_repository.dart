import 'dart:io';

/// Repository interface for media operations
abstract class MediaRepository {
  /// Pick an image from gallery for overlay
  Future<File?> pickImageForOverlay();
  
  /// Save photo to device storage
  Future<String?> savePhoto(String path);
  
  /// Save video to device storage
  Future<String?> saveVideo(String path);
}
