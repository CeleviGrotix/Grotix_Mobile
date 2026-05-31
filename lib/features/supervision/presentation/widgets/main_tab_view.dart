import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grotix/common/theme/app_colors.dart';
import 'package:grotix/l10n/app_localizations.dart';

class MainTabView extends StatelessWidget {
  final AppLocalizations l10n;

  const MainTabView({super.key, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Card Info Cultivo
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.darkCardBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 100,
                  height: 100,
                  color: Colors.white10,
                  child: const Icon(Icons.broken_image_outlined, color: Colors.white30),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tomate',
                      style: TextStyle(color: AppColors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(l10n.germinationStage('Seed'), style: const TextStyle(color: Colors.white70, fontSize: 15)),
                    Text(l10n.latitude('58° 22\' 16\" O'), style: const TextStyle(color: Colors.white70, fontSize: 15)),
                    Text(l10n.longitude('34° 36\' 30\" S'), style: const TextStyle(color: Colors.white70, fontSize: 15)),
                  ],
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Humedad
        _buildSectionTitle(l10n.moisture),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.darkCardBg, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      value: 0.75,
                      strokeWidth: 8,
                      color: AppColors.greenEmerald,
                      backgroundColor: AppColors.redCoral.withOpacity(0.3),
                    ),
                  ),
                  const Text('75%', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.optimal, style: const TextStyle(color: AppColors.greenEmerald, fontSize: 18, fontWeight: FontWeight.w600)),
                  const Text('Last update 10:58', style: TextStyle(color: Colors.white38, fontSize: 12)),
                ],
              )
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Radiación
        _buildSectionTitle(l10n.lightRadiation),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.darkCardBg, borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              Text(l10n.average, style: const TextStyle(color: AppColors.redCoral, fontSize: 16, fontWeight: FontWeight.bold)),
              const Text('Last update 10:58', style: TextStyle(color: Colors.white38, fontSize: 11)),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('0%', style: TextStyle(color: AppColors.white, fontSize: 12)),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: 0.45,
                          minHeight: 14,
                          color: AppColors.redCoral,
                          backgroundColor: Colors.white10,
                        ),
                      ),
                    ),
                  ),
                  const Text('100%', style: TextStyle(color: AppColors.white, fontSize: 12)),
                ],
              )
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Temperatura
        _buildSectionTitle(l10n.temperature),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.darkCardBg, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              const FaIcon(FontAwesomeIcons.temperatureHalf, color: AppColors.white, size: 24),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('22° ${l10n.optimal}', style: const TextStyle(color: AppColors.greenEmerald, fontSize: 18, fontWeight: FontWeight.bold)),
                  const Text('Last update 10:58', style: TextStyle(color: Colors.white38, fontSize: 12)),
                ],
              )
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Sensores
        const SizedBox(height: 24),
        _buildSectionTitle(l10n.sensors),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.darkCardBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // COLUMNA IZQUIERDA: Listado de sensores
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    _SensorListItem(
                      '#HF32A1',
                      l10n.microcontroller,
                      '05/05/2026 19:48',
                    ),
                    const Divider(color: Colors.white10, height: 20),
                    _SensorListItem(
                      '#A922B4',
                      l10n.microcontroller,
                      '12/05/2026 08:20',
                    ),
                    const Divider(color: Colors.white10, height: 20),
                    _SensorListItem(
                      '#B110C2',
                      l10n.microcontroller,
                      '20/05/2026 14:15',
                    ),
                  ],
                ),
              ),

              // Divisor vertical sutil
              Container(
                height: 200,
                width: 1,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                color: Colors.white10,
              ),

              // COLUMNA DERECHA: Formulario para añadir
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.addSensor,
                      style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SensorField('# ID', false),
                    const SizedBox(height: 8),
                    _SensorField('SSID red', false),
                    const SizedBox(height: 8),
                    _SensorField(l10n.password, true),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.greenEmerald,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        child: const Text(
                            'ADD',
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30), // Espacio final
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(color: AppColors.blueCerulean, fontSize: 22, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _SensorListItem(String id, String subtitle, String update){
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(id, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 15)),
          Text(subtitle, style: const TextStyle(color: Colors.white60, fontSize: 12)),
          const SizedBox(height: 2),
          Text(
              l10n.lastUpdate(update),
              style: const TextStyle(color: Colors.white38, fontSize: 12)),
        ],
      );
  }

  Widget _SensorField(String hint, bool isPassword){
    return Container(
      height: 35,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white10),
      ),
      child: TextField(
        obscureText: isPassword,
        style: const TextStyle(color: AppColors.white, fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white24, fontSize: 15),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
        ),
      ),
    );
  }
}
