import 'dart:async';

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
  Timer? _pollingTimer;
  int _consecutiveErrors = 0;

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
    // If we're loading a *different* try-on, clear the stale one immediately
    // so the result screen never briefly flashes the previous item's data.
    if (_currentTryOn != null && _currentTryOn!.id != id) {
      _currentTryOn = null;
    }
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

  /// Polls GET /api/try-on/:id until status is completed or failed.
  ///
  /// Uses a recursive Timer (not Timer.periodic) so we can implement
  /// exponential backoff on errors without a fixed 2 s cadence.
  /// Stops automatically after 5 consecutive network failures.
  void startPolling(String tryOnId) {
    _stopPolling();
    _consecutiveErrors = 0;
    _scheduleNextPoll(tryOnId, const Duration(seconds: 2));
  }

  void _scheduleNextPoll(String tryOnId, Duration delay) {
    _pollingTimer = Timer(delay, () => _doPoll(tryOnId));
  }

  Future<void> _doPoll(String tryOnId) async {
    try {
      final updated = await _tryOnService.getTryOnById(tryOnId);
      _consecutiveErrors = 0; // reset on success

      // Only rebuild the UI when something meaningful changed.
      final changed = _currentTryOn?.status != updated.status ||
          _currentTryOn?.progress != updated.progress ||
          _currentTryOn?.currentStage != updated.currentStage;

      _currentTryOn = updated;
      if (changed) notifyListeners();

      if (updated.status == 'completed' || updated.status == 'failed') {
        _stopPolling();
      } else {
        // Still in progress — schedule next poll at the normal interval.
        _scheduleNextPoll(tryOnId, const Duration(seconds: 2));
      }
    } catch (_) {
      _consecutiveErrors++;
      // Give up entirely after 5 consecutive failures (e.g. lost network).
      if (_consecutiveErrors >= 5) {
        _stopPolling();
        return;
      }
      // Exponential backoff: 4 s → 8 s → 16 s → 30 s (capped).
      final backoffSec = (4 * (1 << (_consecutiveErrors - 1))).clamp(4, 30);
      _scheduleNextPoll(tryOnId, Duration(seconds: backoffSec));
    }
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

  @override
  void dispose() {
    _stopPolling();
    super.dispose();
  }
}
