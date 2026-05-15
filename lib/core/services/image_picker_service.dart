import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  ImagePickerService({ImagePicker? imagePicker})
    : _imagePicker = imagePicker ?? ImagePicker();

  final ImagePicker _imagePicker;

  Future<XFile?> pickImageFromGallery({
    int imageQuality = 100,
    double? maxWidth,
    double? maxHeight,
  }) async {
    return _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: imageQuality,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
    );
  }

  Future<List<XFile>> pickMultipleImages({
    int imageQuality = 70,
    double? maxWidth = 1280,
    double? maxHeight,
  }) async {
    final List<XFile> images = await _imagePicker.pickMultiImage(
      imageQuality: imageQuality,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
    );
    return images;
  }
}
