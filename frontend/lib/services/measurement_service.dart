import '../models/measurement.dart';
import 'api_client.dart';

class MeasurementService {
  final ApiClient _client;

  MeasurementService(this._client);

  Future<Measurement> addOrUpdateMeasurements(Measurement measurement) async {
    final response = await _client.post(
      '/measurements',
      body: measurement.toJson(),
    );
    return Measurement.fromJson(response['measurement']);
  }

  Future<Measurement?> getMeasurements() async {
    try {
      final response = await _client.get('/measurements');
      return Measurement.fromJson(response['measurement']);
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<void> deleteMeasurements() async {
    await _client.delete('/measurements');
  }
}
