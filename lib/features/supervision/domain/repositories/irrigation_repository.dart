abstract class IrrigationRepository {
  Future<bool> startManualIrrigation(int zoneId, {double? volumeLiters, int? durationMinutes});
  Future<bool> stopManualIrrigation(int zoneId, {String? reason});
}