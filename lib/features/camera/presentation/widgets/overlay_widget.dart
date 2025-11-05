import 'dart:io';
import 'package:flutter/material.dart';

/// Widget for displaying overlay image
class OverlayWidget extends StatelessWidget {
  final File overlayImage;

  const OverlayWidget({
    super.key,
    required this.overlayImage,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Opacity(
        opacity: 0.8, // 80% opacity as specified
        child: Image.file(
          overlayImage,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
