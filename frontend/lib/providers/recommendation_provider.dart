import 'package:flutter/foundation.dart';
import '../models/size_recommendation.dart';
import '../models/fashion_recommendation.dart';
import '../services/size_recommendation_service.dart';
import '../services/fashion_recommendation_service.dart';
import '../services/api_client.dart';

class RecommendationProvider extends ChangeNotifier {
  final SizeRecommendationService _sizeService;
  final FashionRecommendationService _fashionService;

  SizeRecommendation? _sizeRecommendation;
  FashionRecommendation? _fashionRecommendation;
  PersonalizedRecommendation? _personalizedRecommendation;
  List<CompleteOutfit> _outfits = [];
  bool _isLoading = false;
  bool _isLoadingSize = false;
  String? _error;

  RecommendationProvider(this._sizeService, this._fashionService);

  SizeRecommendation? get sizeRecommendation => _sizeRecommendation;
  FashionRecommendation? get fashionRecommendation => _fashionRecommendation;
  PersonalizedRecommendation? get personalizedRecommendation =>
      _personalizedRecommendation;
  List<CompleteOutfit> get outfits => _outfits;
  bool get isLoading => _isLoading;
  bool get isLoadingSize => _isLoadingSize;
  String? get error => _error;

  Future<void> fetchSizeRecommendation(String clothingId) async {
    _isLoadingSize = true;
    _error = null;
    notifyListeners();

    try {
      _sizeRecommendation =
          await _sizeService.getSizeRecommendation(clothingId);
    } on ApiException catch (e) {
      if (e.statusCode != 404) _error = e.message;
    }

    _isLoadingSize = false;
    notifyListeners();
  }

  Future<void> fetchFashionRecommendations(String clothingId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _fashionRecommendation =
          await _fashionService.getRecommendations(clothingId);
    } on ApiException catch (e) {
      _error = e.message;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchPersonalized() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _personalizedRecommendation = await _fashionService.getPersonalized();
    } on ApiException catch (e) {
      _error = e.message;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchCompleteOutfit({String? occasion, String? style}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _outfits = await _fashionService.getCompleteOutfit(
        occasion: occasion,
        style: style,
      );
    } on ApiException catch (e) {
      _error = e.message;
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearSizeRecommendation() {
    _sizeRecommendation = null;
    notifyListeners();
  }
}
