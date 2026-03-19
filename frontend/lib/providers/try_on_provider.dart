import 'package:flutter/foundation.dart';
import '../models/try_on.dart';
import '../services/try_on_service.dart';
import '../services/api_client.dart';

class TryOnProvider extends ChangeNotifier {
  final TryOnService _tryOnService;

  List<TryOn> _tryOns = [];
  TryOn? _currentTryOn;
  bool _isLoading = false;
  bool _isProcessing = false;
  String? _error;

  TryOnProvider(this._tryOnService);

  List<TryOn> get tryOns => _tryOns;
  TryOn? get currentTryOn => _currentTryOn;
  bool get isLoading => _isLoading;
  bool get isProcessing => _isProcessing;
  String? get error => _error;

  Future<TryOn?> createTryOn(
    String clothingId, {
    String? presetImageId,
    String? clothingImageUrl,
  }) async {
    _isProcessing = true;
    _error = null;
    notifyListeners();

    try {
      _currentTryOn = await _tryOnService.createTryOn(
        clothingId,
        presetImageId: presetImageId,
        clothingImageUrl: clothingImageUrl,
      );
      _isProcessing = false;
      notifyListeners();
      return _currentTryOn;
    } on ApiException catch (e) {
      _error = e.message;
      _isProcessing = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> fetchTryOns({String? status}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tryOns = await _tryOnService.getUserTryOns(status: status);
    } on ApiException catch (e) {
      _error = e.message;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchTryOnDetail(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentTryOn = await _tryOnService.getTryOnById(id);
    } on ApiException catch (e) {
      _error = e.message;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Polls GET /api/try-on/:id every 5 seconds until status is completed or failed.
  void startPolling(String tryOnId) {
    _stopPolling();
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      try {
        final updated = await _tryOnService.getTryOnById(tryOnId);
        _currentTryOn = updated;
        notifyListeners();
        if (updated.status == 'completed' || updated.status == 'failed') {
          _stopPolling();
        }
      } catch (_) {
        // Silently ignore polling errors to avoid disrupting the UX
      }
    });
  }

  void stopPolling() => _stopPolling();

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }


  Future<bool> deleteTryOn(String id) async {
    try {
      await _tryOnService.deleteTryOn(id);
      _tryOns.removeWhere((t) => t.id == id);
      if (_currentTryOn?.id == id) _currentTryOn = null;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }
}
