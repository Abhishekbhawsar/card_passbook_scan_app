import 'package:image_picker/image_picker.dart';

class ImagePickService {
  ImagePickService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  Future<XFile?> captureImage() {
    return _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 92,
      maxWidth: 1800,
    );
  }

  Future<XFile?> pickFromGallery() {
    return _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 92,
      maxWidth: 1800,
    );
  }
}
