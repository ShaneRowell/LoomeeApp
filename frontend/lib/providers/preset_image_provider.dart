import 'package:flutter/foundation.dart';
import '../models/preset_image.dart';
import '../services/preset_image_service.dart';
import '../services/api_client.dart';

class PresetImageProvider extends ChangeNotifier {
  final PresetImageService _presetImageService;

  List<PresetImage> _images = [];
  PresetImage? _defaultImage;
  bool _isLoading = false;
  bool _isUploading = false;
  String? _error;

  PresetImageProvider(this._presetImageService);

  List<PresetImage> get images => _images;
  PresetImage? get defaultImage => _defaultImage;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  String? get error => _error;

  Future<void> fetchImages() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _images = await _presetImageService.getPresetImages();
      _defaultImage = _images.where((img) => img.isDefault).firstOrNull;
    } on ApiException catch (e) {
      _error = e.message;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> uploadImage(
    String filePath, {
    String imageType = 'front',
    bool isDefault = false,
  }) async {
    _isUploading = true;
    _error = null;
    notifyListeners();

    try {
      final image = await _presetImageService.uploadPresetImage(
        filePath,
        imageType: imageType,
        isDefault: isDefault,
      );
      _images.insert(0, image);
      if (isDefault) _defaultImage = image;
      _isUploading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isUploading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> setDefault(String id) async {
    _error = null; // clear any stale error before starting the call
    try {
      final image = await _presetImageService.setDefault(id);
      _defaultImage = image;
      await fetchImages(); // re-fetches and notifies
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteImage(String id) async {
    try {
      await _presetImageService.deletePresetImage(id);
      _images.removeWhere((img) => img.id == id);
      if (_defaultImage?.id == id) {
        _defaultImage = _images.where((img) => img.isDefault).firstOrNull;
      }
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }
}
