import 'package:flutter/material.dart';
import '../../application/services/irrigation_service.dart';

class IrrigationProvider extends ChangeNotifier {
  final IrrigationService _irrigationService;

  bool _isIrrigating = false;
  bool get isIrrigating => _isIrrigating;

  IrrigationProvider(this._irrigationService);

  // Modificado para aceptar duración configurable
  Future<bool> startIrrigation(int zoneId, {int durationMinutes = 5}) async {
    _isIrrigating = true;
    notifyListeners();

    final success = await _irrigationService.startManualIrrigation(
        zoneId,
        durationMinutes: durationMinutes
    );

    if (!success) {
      _isIrrigating = false;
      notifyListeners();
    }
    return success;
  }

  // NUEVO: Método para detener el riego
  Future<bool> stopIrrigation(int zoneId, {String reason = "MANUAL_CANCEL"}) async {
    // Llamamos al servicio real
    final success = await _irrigationService.stopManualIrrigation(zoneId, reason: reason);

    // Si la llamada fue exitosa, limpiamos el estado de irrigación
    if (success) {
      _isIrrigating = false;
      notifyListeners();
    }

    return success;
  }

  // Para usar si la ventana modal se cierra sola por tiempo
  void clearIrrigatingState() {
    _isIrrigating = false;
    notifyListeners();
  }
}