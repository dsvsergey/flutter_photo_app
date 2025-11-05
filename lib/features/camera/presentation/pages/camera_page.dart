import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/camera_notifier.dart';
import '../widgets/camera_preview_widget.dart';
import '../widgets/overlay_widget.dart';
import '../widgets/recording_timer_widget.dart';
import '../widgets/camera_controls_widget.dart';

/// Main camera page
class CameraPage extends ConsumerStatefulWidget {
  const CameraPage({super.key});

  @override
  ConsumerState<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends ConsumerState<CameraPage> {
  @override
  void initState() {
    super.initState();
    // Initialize camera on page load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cameraProvider.notifier).initialize();
    });
  }

  void _handleCapturePhoto() async {
    final notifier = ref.read(cameraProvider.notifier);
    final path = await notifier.takePhoto();
    
    if (path != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Photo saved: $path'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _handleToggleRecording() async {
    final state = ref.read(cameraProvider);
    final notifier = ref.read(cameraProvider.notifier);
    
    if (state.isRecording) {
      final path = await notifier.stopVideoRecording();
      if (path != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Video saved: $path'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      await notifier.startVideoRecording();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cameraProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Camera preview - full screen
            if (state.isInitialized && state.controller != null)
              Positioned.fill(
                child: ClipRect(
                  child: OverflowBox(
                    alignment: Alignment.center,
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.width * state.controller!.value.aspectRatio,
                        child: CameraPreviewWidget(
                          controller: state.controller!,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            else if (state.errorMessage != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    state.errorMessage!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            
            // Overlay image
            if (state.overlayImage != null)
              Positioned.fill(
                child: OverlayWidget(overlayImage: state.overlayImage!),
              ),
            
            // Header with title
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: const Row(
                  children: [
                    Text(
                      'Camera test task',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Recording timer
            if (state.isRecording)
              Positioned(
                top: 80,
                right: 16,
                child: RecordingTimerWidget(
                  duration: state.recordingDuration,
                ),
              ),
            
            // Camera controls at bottom
            if (state.isInitialized)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: CameraControlsWidget(
                  onSwitchCamera: () {
                    ref.read(cameraProvider.notifier).switchCamera();
                  },
                  onPickOverlay: () {
                    ref.read(cameraProvider.notifier).pickOverlayImage();
                  },
                  onCapturePhoto: _handleCapturePhoto,
                  onToggleRecording: _handleToggleRecording,
                  isRecording: state.isRecording,
                  hasFrontCamera: state.hasFrontCamera,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
