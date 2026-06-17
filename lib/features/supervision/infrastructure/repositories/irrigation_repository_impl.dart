import '../../domain/repositories/irrigation_repository.dart';
import '../datasource/irrigation_datasource.dart';

class IrrigationRepositoryImpl implements IrrigationRepository {
  final IrrigationDatasource _datasource;

  IrrigationRepositoryImpl(this._datasource);

  @override
  Future<bool> startManualIrrigation(int zoneId, {double? volumeLiters, int? durationMinutes}) async {
    try {
      final response = await _datasource.startManual(zoneId, volumeLiters, durationMinutes);
      // Retorna true si el backend responde 200 OK o 202 Accepted
      return response.statusCode == 200 || response.statusCode == 202;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> stopManualIrrigation(int zoneId, {String? reason}) async {
    try {
      final response = await _datasource.stopManual(zoneId, reason);
      // Retorna true si el backend responde 200 OK
      return response.statusCode == 200 || response.statusCode == 202;
    } catch (_) {
      return false;
    }
  }
}