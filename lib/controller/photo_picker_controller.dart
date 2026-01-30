import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'auth_controller.dart';

class PhotoPickerController extends ChangeNotifier {
  final ImagePicker _picker = ImagePicker();
  XFile? _photo;

  XFile? get photo => _photo;
  bool get hasPhoto => _photo != null;

  Future<void> pickFromGallery(AuthController controller) async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    _photo = picked;
    notifyListeners();
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      final path = picked.path;
      final parts = path.split('.');
      final ext = parts.length > 1 ? parts.last.toLowerCase() : 'jpg';
      controller.setPhoto(bytes, ext);
    }
  }

  void clear(AuthController controller) {
    if (_photo == null) return;
    _photo = null;
    controller.clearPhoto();
    notifyListeners();
  }
}
