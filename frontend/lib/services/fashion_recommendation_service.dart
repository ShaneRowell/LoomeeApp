import '../models/fashion_recommendation.dart';
import 'api_client.dart';

class FashionRecommendationService {
  final ApiClient _client;

  FashionRecommendationService(this._client);

  Future<FashionRecommendation> getRecommendations(String clothingId) async {
    final response = await _client.get(
      '/fashion-recommendations/$clothingId',
      withAuth: false,
    );
    return FashionRecommendation.fromJson(response);
  }

  Future<PersonalizedRecommendation> getPersonalized() async {
    final response =
        await _client.get('/fashion-recommendations/personalized/for-you');
    return PersonalizedRecommendation.fromJson(response);
  }

  Future<List<CompleteOutfit>> getCompleteOutfit({
    String? occasion,
    String? style,
  }) async {
    final queryParams = <String, String>{};
    if (occasion != null && occasion.isNotEmpty) {
      queryParams['occasion'] = occasion;
    }
    if (style != null && style.isNotEmpty) queryParams['style'] = style;

    final response = await _client.get(
      '/fashion-recommendations/outfit/complete',
      queryParams: queryParams.isNotEmpty ? queryParams : null,
      withAuth: false,
    );
    return (response['outfits'] as List<dynamic>)
        .map((o) => CompleteOutfit.fromJson(o))
        .toList();
  }
}
