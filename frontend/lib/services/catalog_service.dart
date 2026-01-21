import '../models/clothing.dart';
import 'api_client.dart';

class CatalogService {
  final ApiClient _client;

  CatalogService(this._client);

  Future<List<Clothing>> getAllClothing({
    String? category,
    String? gender,
    double? minPrice,
    double? maxPrice,
    String? brand,
    String? search,
  }) async {
    final queryParams = <String, String>{};
    if (category != null && category.isNotEmpty) {
      queryParams['category'] = category;
    }
    if (gender != null && gender.isNotEmpty) queryParams['gender'] = gender;
    if (minPrice != null) queryParams['minPrice'] = minPrice.toString();
    if (maxPrice != null) queryParams['maxPrice'] = maxPrice.toString();
    if (brand != null && brand.isNotEmpty) queryParams['brand'] = brand;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    final response = await _client.get(
      '/catalog',
      queryParams: queryParams.isNotEmpty ? queryParams : null,
      withAuth: false,
    );

    return (response['clothing'] as List<dynamic>)
        .map((item) => Clothing.fromJson(item))
        .toList();
  }

  Future<Clothing> getClothingById(String id) async {
    final response = await _client.get('/catalog/$id', withAuth: false);
    return Clothing.fromJson(response['clothing']);
  }

  Future<List<Clothing>> getClothingByCategory(String category) async {
    final response =
        await _client.get('/catalog/category/$category', withAuth: false);
    return (response['clothing'] as List<dynamic>)
        .map((item) => Clothing.fromJson(item))
        .toList();
  }
}
