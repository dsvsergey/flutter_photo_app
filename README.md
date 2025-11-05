# Camera Test Task

Flutter camera application with overlay support, photo capture, and video recording.

## Architecture

The project follows Clean Architecture principles

## Tech Stack

- **State Management**: Riverpod
- **Dependency Injection**: GetIt
- **Camera**: camera package
- **Image Picker**: image_picker (with Photo Picker support)
- **Permissions**: permission_handler
- **Storage**: path_provider

## Requirements

- Flutter SDK: ^3.9.2
- Android: minSdk 30 (Android 11+)
- iOS: iOS 12+

## Setup

1. Install dependencies:

```bash
flutter pub get
```

2. Run the app:

```bash
flutter run
```

## Permissions

### Android

- `CAMERA` - Required for camera access
- `RECORD_AUDIO` - Required for video recording with audio
- `READ_MEDIA_IMAGES` - For Android 13+ photo picker
- `READ_MEDIA_VIDEO` - For Android 13+ video access

### iOS

- `NSCameraUsageDescription` - Camera access
- `NSMicrophoneUsageDescription` - Microphone access for video
- `NSPhotoLibraryUsageDescription` - Gallery access for overlay selection
- `NSPhotoLibraryAddUsageDescription` - Saving photos/videos

### Notes

- The app is designed for portrait mode only
- Overlay opacity is set to 80% as specified
- Recording timer displays in MM:SS format
- All logs use `dart:developer` instead of `print`
