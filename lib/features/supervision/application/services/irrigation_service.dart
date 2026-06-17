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
}