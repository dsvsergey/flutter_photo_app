import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../domain/repositories/camera_repository.dart';
import '../../../../core/utils/logger.dart';

/// Implementation of CameraRepository
class CameraRepositoryImpl implements CameraRepository {
  @override
  Future<List<CameraDescription>> getAvailableCameras() async {
    try {
      final cameras = await availableCameras();
      Logger.info('Found ${cameras.length} cameras');
      return cameras;
    } catch (e, stackTrace) {
      Logger.error('Error getting available cameras', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<bool> requestCameraPermission() async {
    try {
      final status = await Permission.camera.request();
      final granted = status.isGranted;
      Logger.info('Camera permission: ${granted ? "granted" : "denied"}');
      return granted;
    } catch (e, stackTrace) {
      Logger.error('Error requesting camera permission', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  @override
  Future<bool> requestMicrophonePermission() async {
    try {
      final status = await Permission.microphone.request();
      final granted = status.isGranted;
      Logger.info('Microphone permission: ${granted ? "granted" : "denied"}');
      return granted;
    } catch (e, stackTrace) {
      Logger.error('Error requesting microphone permission', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  @override
  Future<bool> isCameraPermissionGranted() async {
    try {
      final status = await Permission.camera.status;
      return status.isGranted;
    } catch (e, stackTrace) {
      Logger.error('Error checking camera permission', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  @override
  Future<bool> isMicrophonePermissionGranted() async {
    try {
      final status = await Permission.microphone.status;
      return status.isGranted;
    } catch (e, stackTrace) {
      Logger.error('Error checking microphone permission', error: e, stackTrace: stackTrace);
      return false;
    }
  }
}
