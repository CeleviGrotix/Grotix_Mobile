import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:grotix/common/theme/app_colors.dart';
import 'package:grotix/features/supervision/presentation/providers/irrigation_provider.dart';

class IrrigationActiveDialog extends StatefulWidget {
  final int zoneId;
  final int durationMinutes;
  final VoidCallback onStop;

  const IrrigationActiveDialog({
    super.key,
    required this.zoneId,
    required this.durationMinutes,
    required this.onStop,
  });

  @override
  State<IrrigationActiveDialog> createState() => _IrrigationActiveDialogState();
}

class _IrrigationActiveDialogState extends State<IrrigationActiveDialog> with SingleTickerProviderStateMixin {
  late int _secondsRemaining;
  Timer? _timer;
  Timer? _statusPoller;
  late AnimationController _waveController;
  bool _checkingStatus = false;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.durationMinutes * 60;

    _waveController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();

    _startTimer();
    _startStatusPolling();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _closeDialog();
      }
    });
  }

  /// Consulta cada 4s si el backend todavía reporta un ciclo activo.
  /// Si el edge ya cortó el riego (fail-safe, stop remoto, lo que sea),
  /// el modal se cierra solo en vez de esperar al countdown local.
  void _startStatusPolling() {
    _statusPoller = Timer.periodic(const Duration(seconds: 4), (timer) async {
      if (_checkingStatus) return; // evita superposición si una consulta tarda
      _checkingStatus = true;
      try {
        final stillActive = await context.read<IrrigationProvider>().hasActiveCycle(widget.zoneId);
        if (!stillActive && mounted) {
          _closeDialog();
        }
      } catch (_) {
        // Fallo de red puntual: no cerramos el modal por una consulta
        // fallida aislada, esperamos al siguiente intento.
      } finally {
        _checkingStatus = false;
      }
    });
  }

  void _closeDialog() {
    if (!mounted) return;
    _timer?.cancel();
    _statusPoller?.cancel();
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _statusPoller?.cancel();
    _waveController.dispose();
    super.dispose();
  }

  String get _formattedTime {
    final minutes = (_secondsRemaining / 60).floor();
    final seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350,
      decoration: const BoxDecoration(
        color: AppColors.darkCardBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Regando Zona...",
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Mecanismo de seguridad activado a ${widget.durationMinutes} min",
            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
          ),
          const SizedBox(height: 30),
          Stack(
            alignment: Alignment.center,
            children: [
              RotationTransition(
                turns: _waveController,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.greenEmerald.withOpacity(0.3), width: 4),
                    gradient: SweepGradient(
                      colors: [AppColors.greenEmerald.withOpacity(0.1), AppColors.greenEmerald],
                    ),
                  ),
                ),
              ),
              Container(
                width: 110,
                height: 110,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.black),
                child: Center(
                  child: Text(
                    _formattedTime,
                    style: const TextStyle(color: AppColors.greenEmerald, fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: () {
              widget.onStop();
              _closeDialog();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent.withOpacity(0.2),
              foregroundColor: Colors.redAccent,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            icon: const FaIcon(FontAwesomeIcons.stop, size: 16),
            label: const Text("Detener Riego", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          )
        ],
      ),
    );
  }
}