abstract class IrrigationRepository {
  Future<bool> startManualIrrigation(int zoneId, {double? volumeLiters, int? durationMinutes});
  Future<bool> stopManualIrrigation(int zoneId, {String? reason});

  /// Consulta si la zona tiene al menos un ciclo de riego activo ahora mismo.
  Future<bool> hasActiveCycle(int zoneId);
}