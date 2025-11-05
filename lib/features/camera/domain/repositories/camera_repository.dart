import 'package:camera/camera.dart';

/// Repository interface for camera operations
abstract class CameraRepository {
  /// Get available cameras
  Future<List<CameraDescription>> getAvailableCameras();
  
  /// Request camera permission
  Future<bool> requestCameraPermission();
  
  /// Request microphone permission for video recording
  Future<bool> requestMicrophonePermission();
  
  /// Check if camera permission is granted
  Future<bool> isCameraPermissionGranted();
  
  /// Check if microphone permission is granted
  Future<bool> isMicrophonePermissionGranted();
}
