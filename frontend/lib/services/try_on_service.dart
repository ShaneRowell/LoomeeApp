import '../models/try_on.dart';
import 'api_client.dart';

class TryOnService {
  final ApiClient _client;

  TryOnService(this._client);

  Future<TryOn> createTryOn(
    String clothingId, {
    String? presetImageId,
    String? clothingImageUrl,
  }) async {
    final body = <String, dynamic>{'clothingId': clothingId};
    if (presetImageId != null) body['presetImageId'] = presetImageId;
    if (clothingImageUrl != null) body['clothingImageUrl'] = clothingImageUrl;

    final response = await _client.post('/try-on', body: body);
    return TryOn.fromJson(response['tryOn']);
  }

  Future<List<TryOn>> getUserTryOns({String? status}) async {
    final queryParams = <String, String>{};
    if (status != null && status.isNotEmpty) queryParams['status'] = status;

    final response = await _client.get(
      '/try-on',
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );
    return (response['tryOns'] as List<dynamic>)
        .map((t) => TryOn.fromJson(t))
        .toList();
  }

  Future<TryOn> getTryOnById(String id) async {
    final response = await _client.get('/try-on/$id');
    return TryOn.fromJson(response['tryOn']);
  }

  Future<void> deleteTryOn(String id) async {
    await _client.delete('/try-on/$id');
  }
}
