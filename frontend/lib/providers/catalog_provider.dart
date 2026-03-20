import 'dart:async';

import 'package:flutter/foundation.dart';
import '../models/clothing.dart';
import '../services/catalog_service.dart';
import '../services/api_client.dart';

class CatalogProvider extends ChangeNotifier {
  final CatalogService _catalogService;

  List<Clothing> _clothingItems = [];
  Clothing? _selectedClothing;
  String _selectedCategory = '';
  String _searchQuery = '';
  bool _isLoading = false;
  bool _isLoadingDetail = false;
  String? _error;

  // Debounce timer — prevents a network request on every keystroke.
  Timer? _searchDebounce;

  CatalogProvider(this._catalogService);

  List<Clothing> get clothingItems => _clothingItems;
  Clothing? get selectedClothing => _selectedClothing;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  bool get isLoadingDetail => _isLoadingDetail;
  String? get error => _error;

  Future<void> fetchClothing({
    String? category,
    String? gender,
    double? minPrice,
    double? maxPrice,
    String? brand,
    String? search,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _clothingItems = await _catalogService.getAllClothing(
        category: category ?? (_selectedCategory.isNotEmpty ? _selectedCategory : null),
        gender: gender,
        minPrice: minPrice,
        maxPrice: maxPrice,
        brand: brand,
        search: search ?? (_searchQuery.isNotEmpty ? _searchQuery : null),
      );
      _error = null;
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Failed to load clothing';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchClothingDetail(String id) async {
    _isLoadingDetail = true;
    _error = null;
    notifyListeners();

    try {
      _selectedClothing = await _catalogService.getClothingById(id);
    } on ApiException catch (e) {
      _error = e.message;
    }

    _isLoadingDetail = false;
    notifyListeners();
  }

  /// Category changes fetch immediately — the user made a deliberate tap.
  void setCategory(String category) {
    _searchDebounce?.cancel();
    _selectedCategory = category;
    fetchClothing();
  }

  /// Search debounces 300 ms so we don't fire a request on every keystroke.
  void setSearchQuery(String query) {
    _searchQuery = query;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      const Duration(milliseconds: 300),
      fetchClothing,
    );
  }

  void clearFilters() {
    _searchDebounce?.cancel();
    _selectedCategory = '';
    _searchQuery = '';
    fetchClothing();
  }

  void clearSelectedClothing() {
    _selectedClothing = null;
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }
}
