import 'dart:io';
import 'package:camera/camera.dart';

/// Camera state model
class CameraState {
  final bool isInitialized;
  final bool isRecording;
  final CameraController? controller;
  final List<CameraDescription> cameras;
  final int currentCameraIndex;
  final File? overlayImage;
  final String? errorMessage;
  final Duration recordingDuration;

  CameraState({
    this.isInitialized = false,
    this.isRecording = false,
    this.controller,
    this.cameras = const [],
    this.currentCameraIndex = 0,
    this.overlayImage,
    this.errorMessage,
    this.recordingDuration = Duration.zero,
  });

  CameraState copyWith({
    bool? isInitialized,
    bool? isRecording,
    CameraController? controller,
    List<CameraDescription>? cameras,
    int? currentCameraIndex,
    File? overlayImage,
    String? errorMessage,
    Duration? recordingDuration,
    bool clearOverlay = false,
    bool clearError = false,
  }) {
    return CameraState(
      isInitialized: isInitialized ?? this.isInitialized,
      isRecording: isRecording ?? this.isRecording,
      controller: controller ?? this.controller,
      cameras: cameras ?? this.cameras,
      currentCameraIndex: currentCameraIndex ?? this.currentCameraIndex,
      overlayImage: clearOverlay ? null : (overlayImage ?? this.overlayImage),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      recordingDuration: recordingDuration ?? this.recordingDuration,
    );
  }

  bool get hasBackCamera => cameras.isNotEmpty;
  bool get hasFrontCamera => cameras.length > 1;
  CameraDescription? get currentCamera => 
      cameras.isNotEmpty && currentCameraIndex < cameras.length 
          ? cameras[currentCameraIndex] 
          : null;
}
