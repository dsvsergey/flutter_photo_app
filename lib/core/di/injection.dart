import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import '../../features/camera/data/repositories/camera_repository_impl.dart';
import '../../features/camera/data/repositories/media_repository_impl.dart';
import '../../features/camera/domain/repositories/camera_repository.dart';
import '../../features/camera/domain/repositories/media_repository.dart';

final getIt = GetIt.instance;

/// Initialize dependency injection
Future<void> setupDependencies() async {
  // External dependencies
  getIt.registerLazySingleton<ImagePicker>(() => ImagePicker());
  
  // Repositories
  getIt.registerLazySingleton<CameraRepository>(
    () => CameraRepositoryImpl(),
  );
  
  getIt.registerLazySingleton<MediaRepository>(
    () => MediaRepositoryImpl(
      imagePicker: getIt<ImagePicker>(),
    ),
  );
}
