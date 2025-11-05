import 'package:flutter/material.dart';

/// Widget for camera control buttons
class CameraControlsWidget extends StatelessWidget {
  final VoidCallback onSwitchCamera;
  final VoidCallback onPickOverlay;
  final VoidCallback onCapturePhoto;
  final VoidCallback onToggleRecording;
  final bool isRecording;
  final bool hasFrontCamera;

  const CameraControlsWidget({
    super.key,
    required this.onSwitchCamera,
    required this.onPickOverlay,
    required this.onCapturePhoto,
    required this.onToggleRecording,
    required this.isRecording,
    required this.hasFrontCamera,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Left side buttons
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ControlButton(
                  icon: Icons.cameraswitch,
                  onPressed: hasFrontCamera ? onSwitchCamera : null,
                  size: 48,
                ),
                const SizedBox(width: 4),
                // Pick overlay button
                _ControlButton(
                  icon: Icons.image,
                  onPressed: onPickOverlay,
                  size: 48,
                ),
              ],
            ),
          ),

          // Video Record button (centered) - 1.3
          GestureDetector(
            onTap: onToggleRecording,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red,
                border: Border.all(color: Colors.white, width: 4),
              ),
              child: isRecording
                  ? Center(
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    )
                  : null,
            ),
          ),

          // Photo capture button (right) - 1.4
          Align(
            alignment: Alignment.centerRight,
            child: _ControlButton(
              icon: Icons.camera_alt,
              onPressed: onCapturePhoto,
              size: 48,
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;

  const _ControlButton({
    required this.icon,
    required this.onPressed,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: onPressed != null
            ? Colors.black.withValues(alpha: 0.5)
            : Colors.grey.withValues(alpha: 0.3),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon),
        color: Colors.white,
        onPressed: onPressed,
        iconSize: size * 0.5,
      ),
    );
  }
}
