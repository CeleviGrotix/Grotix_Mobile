import '../../domain/repositories/irrigation_repository.dart';

class IrrigationService {
  final IrrigationRepository _repository;

  const IrrigationService(this._repository);

  Future<bool> startManualIrrigation(int zoneId, {int durationMinutes = 5}) async {
    return await _repository.startManualIrrigation(
        zoneId,
        durationMinutes: durationMinutes
    );
  }
  Future<bool> stopManualIrrigation(int zoneId, {String reason = "USER_MANUAL_STOP"}) async {
    return await _repository.stopManualIrrigation(zoneId, reason: reason);
  }

  /// Consulta si la zona tiene un ciclo de riego activo en este momento.
  /// Lo usa el modal de riego para cerrarse solo si el edge cortó el riego
  /// antes de que termine el countdown visual local.
  Future<bool> hasActiveCycle(int zoneId) async {
    return await _repository.hasActiveCycle(zoneId);
  }
}