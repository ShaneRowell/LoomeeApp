import 'package:flutter/foundation.dart';
import '../models/measurement.dart';
import '../services/measurement_service.dart';
import '../services/api_client.dart';

class MeasurementProvider extends ChangeNotifier {
  final MeasurementService _measurementService;

  Measurement? _measurement;
  bool _isLoading = false;
  String? _error;

  MeasurementProvider(this._measurementService);

  Measurement? get measurement => _measurement;
  bool get isLoading => _isLoading;
  bool get hasMeasurements => _measurement != null;
  String? get error => _error;

  Future<void> fetchMeasurements() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _measurement = await _measurementService.getMeasurements();
    } on ApiException catch (e) {
      if (e.statusCode != 404) _error = e.message;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> saveMeasurements(Measurement measurement) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _measurement =
          await _measurementService.addOrUpdateMeasurements(measurement);
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteMeasurements() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _measurementService.deleteMeasurements();
      _measurement = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
