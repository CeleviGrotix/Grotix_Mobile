import 'dart:convert';
import '../../domain/repositories/irrigation_repository.dart';
import '../datasource/irrigation_datasource.dart';

class IrrigationRepositoryImpl implements IrrigationRepository {
  final IrrigationDatasource _datasource;

  IrrigationRepositoryImpl(this._datasource);

  @override
  Future<bool> startManualIrrigation(int zoneId, {double? volumeLiters, int? durationMinutes}) async {
    try {
      final response = await _datasource.startManual(zoneId, volumeLiters, durationMinutes);
      return response.statusCode == 200 || response.statusCode == 202;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> stopManualIrrigation(int zoneId, {String? reason}) async {
    try {
      final response = await _datasource.stopManual(zoneId, reason);
      return response.statusCode == 200 || response.statusCode == 202;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> hasActiveCycle(int zoneId) async {
    try {
      final response = await _datasource.getActive(zoneId);
      if (response.statusCode != 200) return false;
      final List<dynamic> ciclos = jsonDecode(response.body);
      return ciclos.isNotEmpty;
    } catch (_) {
      // Fallo de red puntual: asumimos que sigue activo para no cerrar
      // el modal por error — es más seguro pecar de cauteloso acá que
      // cerrar el modal de golpe por un timeout aislado.
      return true;
    }
  }
}