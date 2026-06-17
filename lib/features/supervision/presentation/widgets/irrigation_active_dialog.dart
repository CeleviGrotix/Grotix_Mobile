import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grotix/common/theme/app_colors.dart';

class IrrigationActiveDialog extends StatefulWidget {
  final int durationMinutes;
  final VoidCallback onStop;

  const IrrigationActiveDialog({
    super.key,
    required this.durationMinutes,
    required this.onStop,
  });

  @override
  State<IrrigationActiveDialog> createState() => _IrrigationActiveDialogState();
}

class _IrrigationActiveDialogState extends State<IrrigationActiveDialog> with SingleTickerProviderStateMixin {
  late int _secondsRemaining;
  Timer? _timer;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.durationMinutes * 60;

    // Animación continua para simular agua fluyendo
    _waveController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();

    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _timer?.cancel();
        Navigator.of(context).pop(); // Cierra el modal cuando termina
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
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
        color: AppColors.darkCardBg, // Usa el color oscuro de tus tarjetas
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

          // Círculo animado con el temporizador
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

          // Botón de Parada de Emergencia (Abortar)
          ElevatedButton.icon(
            onPressed: () {
              widget.onStop();
              Navigator.of(context).pop();
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