import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../domain/repositories/media_repository.dart';
import '../../../../core/utils/logger.dart';

/// Implementation of MediaRepository
class MediaRepositoryImpl implements MediaRepository {
  final ImagePicker imagePicker;

  MediaRepositoryImpl({required this.imagePicker});

  @override
  Future<File?> pickImageForOverlay() async {
    try {
      // Use Photo Picker on Android 11+ (no permission needed)
      final XFile? image = await imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );
      
      if (image != null) {
        Logger.info('Image picked for overlay: ${image.path}');
        return File(image.path);
      }
      
      Logger.info('No image selected');
      return null;
    } catch (e, stackTrace) {
      Logger.error('Error picking image', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  @override
  Future<String?> savePhoto(String sourcePath) async {
    try {
      // On Android 11+, use Media Store through path_provider
      final Directory? directory = Platform.isAndroid
          ? await getExternalStorageDirectory()
          : await getApplicationDocumentsDirectory();
      
      if (directory == null) {
        Logger.error('Could not get storage directory');
        return null;
      }

      // Create Pictures subdirectory
      final String picturesPath = Platform.isAndroid
          ? '/storage/emulated/0/Pictures/CameraApp'
          : path.join(directory.path, 'Pictures');
      
      final Directory picturesDir = Directory(picturesPath);
      if (!await picturesDir.exists()) {
        await picturesDir.create(recursive: true);
      }

      // Generate unique filename
      final String fileName = 'IMG_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String destinationPath = path.join(picturesPath, fileName);

      // Copy file to destination
      final File sourceFile = File(sourcePath);
      await sourceFile.copy(destinationPath);

      Logger.info('Photo saved to: $destinationPath');
      return destinationPath;
    } catch (e, stackTrace) {
      Logger.error('Error saving photo', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  @override
  Future<String?> saveVideo(String sourcePath) async {
    try {
      // On Android 11+, use Media Store through path_provider
      final Directory? directory = Platform.isAndroid
          ? await getExternalStorageDirectory()
          : await getApplicationDocumentsDirectory();
      
      if (directory == null) {
        Logger.error('Could not get storage directory');
        return null;
      }

      // Create Movies subdirectory
      final String moviesPath = Platform.isAndroid
          ? '/storage/emulated/0/Movies/CameraApp'
          : path.join(directory.path, 'Movies');
      
      final Directory moviesDir = Directory(moviesPath);
      if (!await moviesDir.exists()) {
        await moviesDir.create(recursive: true);
      }

      // Generate unique filename
      final String fileName = 'VID_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final String destinationPath = path.join(moviesPath, fileName);

      // Copy file to destination
      final File sourceFile = File(sourcePath);
      await sourceFile.copy(destinationPath);

      Logger.info('Video saved to: $destinationPath');
      return destinationPath;
    } catch (e, stackTrace) {
      Logger.error('Error saving video', error: e, stackTrace: stackTrace);
      return null;
    }
  }
}
