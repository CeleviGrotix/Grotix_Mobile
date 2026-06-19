import 'dart:async';
import 'package:flutter/material.dart';
import '../../application/services/irrigation_service.dart';

class IrrigationProvider extends ChangeNotifier {
  final IrrigationService _irrigationService;

  bool _isIrrigating = false;
  bool get isIrrigating => _isIrrigating;

  IrrigationProvider(this._irrigationService);

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

  Future<bool> stopIrrigation(int zoneId, {String reason = "MANUAL_CANCEL"}) async {
    final success = await _irrigationService.stopManualIrrigation(zoneId, reason: reason);

    if (success) {
      _isIrrigating = false;
      notifyListeners();
    }

    return success;
  }

  void clearIrrigatingState() {
    _isIrrigating = false;
    notifyListeners();
  }

  /// Consulta si sigue habiendo un ciclo activo para la zona en el backend.
  /// Lo usa el modal para cerrarse solo si el edge (fail-safe por tiempo,
  /// stop remoto, etc.) cortó el riego antes de que termine el countdown
  /// visual local — sin esto, el modal y la realidad pueden desincronizarse.
  Future<bool> hasActiveCycle(int zoneId) async {
    return await _irrigationService.hasActiveCycle(zoneId);
  }
}