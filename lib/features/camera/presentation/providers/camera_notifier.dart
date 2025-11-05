import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/camera_repository.dart';
import '../../domain/repositories/media_repository.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/logger.dart';
import 'camera_state.dart';

/// Camera state notifier
class CameraNotifier extends StateNotifier<CameraState> {
  final CameraRepository _cameraRepository;
  final MediaRepository _mediaRepository;
  Timer? _recordingTimer;

  CameraNotifier({
    required CameraRepository cameraRepository,
    required MediaRepository mediaRepository,
  })  : _cameraRepository = cameraRepository,
        _mediaRepository = mediaRepository,
        super(CameraState());

  /// Initialize camera with permissions
  Future<void> initialize() async {
    try {
      Logger.info('Initializing camera...');
      
      // Request permissions
      final cameraGranted = await _cameraRepository.requestCameraPermission();
      final micGranted = await _cameraRepository.requestMicrophonePermission();
      
      if (!cameraGranted) {
        state = state.copyWith(
          errorMessage: 'Camera permission denied',
        );
        return;
      }

      if (!micGranted) {
        Logger.info('Microphone permission denied, video recording will be without audio');
      }

      // Get available cameras
      final cameras = await _cameraRepository.getAvailableCameras();
      
      if (cameras.isEmpty) {
        state = state.copyWith(
          errorMessage: 'No cameras found',
        );
        return;
      }

      state = state.copyWith(
        cameras: cameras,
        currentCameraIndex: 0, // Start with back camera
      );

      // Initialize camera controller
      await _initializeCamera(cameras[0]);
      
      Logger.info('Camera initialized successfully');
    } catch (e, stackTrace) {
      Logger.error('Error initializing camera', error: e, stackTrace: stackTrace);
      state = state.copyWith(
        errorMessage: 'Failed to initialize camera: $e',
      );
    }
  }

  /// Initialize camera controller
  Future<void> _initializeCamera(CameraDescription camera) async {
    try {
      // Dispose previous controller
      await state.controller?.dispose();

      final controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: await _cameraRepository.isMicrophonePermissionGranted(),
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await controller.initialize();

      state = state.copyWith(
        controller: controller,
        isInitialized: true,
        clearError: true,
      );
    } catch (e, stackTrace) {
      Logger.error('Error initializing camera controller', error: e, stackTrace: stackTrace);
      state = state.copyWith(
        errorMessage: 'Failed to initialize camera: $e',
        isInitialized: false,
      );
    }
  }

  /// Switch between front and back camera
  Future<void> switchCamera() async {
    if (state.cameras.length < 2) {
      Logger.info('Only one camera available');
      return;
    }

    try {
      final newIndex = (state.currentCameraIndex + 1) % state.cameras.length;
      state = state.copyWith(
        currentCameraIndex: newIndex,
        isInitialized: false,
      );

      await _initializeCamera(state.cameras[newIndex]);
      Logger.info('Switched to camera: ${state.cameras[newIndex].name}');
    } catch (e, stackTrace) {
      Logger.error('Error switching camera', error: e, stackTrace: stackTrace);
      state = state.copyWith(
        errorMessage: 'Failed to switch camera: $e',
      );
    }
  }

  /// Pick overlay image from gallery
  Future<void> pickOverlayImage() async {
    try {
      final image = await _mediaRepository.pickImageForOverlay();
      
      if (image != null) {
        state = state.copyWith(overlayImage: image);
        Logger.info('Overlay image selected');
      }
    } catch (e, stackTrace) {
      Logger.error('Error picking overlay image', error: e, stackTrace: stackTrace);
      state = state.copyWith(
        errorMessage: 'Failed to pick overlay image: $e',
      );
    }
  }

  /// Remove overlay image
  void removeOverlay() {
    state = state.copyWith(clearOverlay: true);
    Logger.info('Overlay removed');
  }

  /// Take a photo
  Future<String?> takePhoto() async {
    if (!state.isInitialized || state.controller == null) {
      Logger.error('Camera not initialized');
      return null;
    }

    try {
      Logger.info('Taking photo...');
      final XFile photo = await state.controller!.takePicture();
      
      // Save photo to storage
      final savedPath = await _mediaRepository.savePhoto(photo.path);
      
      if (savedPath != null) {
        Logger.info('Photo saved successfully');
        return savedPath;
      } else {
        state = state.copyWith(
          errorMessage: 'Failed to save photo',
        );
        return null;
      }
    } catch (e, stackTrace) {
      Logger.error('Error taking photo', error: e, stackTrace: stackTrace);
      state = state.copyWith(
        errorMessage: 'Failed to take photo: $e',
      );
      return null;
    }
  }

  /// Start video recording
  Future<void> startVideoRecording() async {
    if (!state.isInitialized || state.controller == null) {
      Logger.error('Camera not initialized');
      return;
    }

    if (state.isRecording) {
      Logger.info('Already recording');
      return;
    }

    try {
      Logger.info('Starting video recording...');
      await state.controller!.startVideoRecording();
      
      state = state.copyWith(
        isRecording: true,
        recordingDuration: Duration.zero,
      );

      // Start timer for recording duration
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        state = state.copyWith(
          recordingDuration: Duration(seconds: timer.tick),
        );
      });

      Logger.info('Video recording started');
    } catch (e, stackTrace) {
      Logger.error('Error starting video recording', error: e, stackTrace: stackTrace);
      state = state.copyWith(
        errorMessage: 'Failed to start recording: $e',
      );
    }
  }

  /// Stop video recording
  Future<String?> stopVideoRecording() async {
    if (!state.isRecording || state.controller == null) {
      Logger.info('Not recording');
      return null;
    }

    try {
      Logger.info('Stopping video recording...');
      
      _recordingTimer?.cancel();
      _recordingTimer = null;

      final XFile video = await state.controller!.stopVideoRecording();
      
      state = state.copyWith(
        isRecording: false,
        recordingDuration: Duration.zero,
      );

      // Save video to storage
      final savedPath = await _mediaRepository.saveVideo(video.path);
      
      if (savedPath != null) {
        Logger.info('Video saved successfully');
        return savedPath;
      } else {
        state = state.copyWith(
          errorMessage: 'Failed to save video',
        );
        return null;
      }
    } catch (e, stackTrace) {
      Logger.error('Error stopping video recording', error: e, stackTrace: stackTrace);
      state = state.copyWith(
        errorMessage: 'Failed to stop recording: $e',
        isRecording: false,
      );
      return null;
    }
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    state.controller?.dispose();
    super.dispose();
  }
}

/// Provider for camera notifier
final cameraProvider = StateNotifierProvider<CameraNotifier, CameraState>((ref) {
  return CameraNotifier(
    cameraRepository: getIt<CameraRepository>(),
    mediaRepository: getIt<MediaRepository>(),
  );
});
