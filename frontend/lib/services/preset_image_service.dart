import '../models/preset_image.dart';
import 'api_client.dart';

class PresetImageService {
  final ApiClient _client;

  PresetImageService(this._client);

  Future<PresetImage> uploadPresetImage(
    String filePath, {
    String imageType = 'front',
    bool isDefault = false,
  }) async {
    final response = await _client.multipartPost(
      '/preset-images',
      filePath: filePath,
      fieldName: 'image',
      fields: {
        'imageType': imageType,
        'isDefault': isDefault.toString(),
      },
    );
    return PresetImage.fromJson(response['image']);
  }

  Future<List<PresetImage>> getPresetImages() async {
    final response = await _client.get('/preset-images');
    return (response['images'] as List<dynamic>)
        .map((img) => PresetImage.fromJson(img))
        .toList();
  }

  Future<PresetImage?> getDefaultPresetImage() async {
    try {
      final response = await _client.get('/preset-images/default');
      return PresetImage.fromJson(response['image']);
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<void> deletePresetImage(String id) async {
    await _client.delete('/preset-images/$id');
  }

  Future<PresetImage> setDefault(String id) async {
    final response = await _client.put('/preset-images/$id/set-default');
    return PresetImage.fromJson(response['image']);
  }
}
