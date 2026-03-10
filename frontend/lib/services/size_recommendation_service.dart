import '../models/size_recommendation.dart';
import 'api_client.dart';

class SizeRecommendationService {
  final ApiClient _client;

  SizeRecommendationService(this._client);

  Future<SizeRecommendation> getSizeRecommendation(String clothingId) async {
    final response = await _client.get('/size-recommendation/$clothingId');
    return SizeRecommendation.fromJson(response);
  }

  Future<List<BulkSizeRecommendation>> getBulkRecommendations(
      List<String> clothingIds) async {
    final response = await _client.post(
      '/size-recommendation/bulk',
      body: {'clothingIds': clothingIds},
    );
    return (response['recommendations'] as List<dynamic>)
        .map((r) => BulkSizeRecommendation.fromJson(r))
        .toList();
  }
}
