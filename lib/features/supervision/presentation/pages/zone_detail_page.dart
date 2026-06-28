import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:grotix/common/theme/app_colors.dart';
import 'package:grotix/features/supervision/domain/entities/zone.dart';
import 'package:grotix/features/supervision/presentation/providers/zone_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/irrigation_active_dialog.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../identity/auth/presentation/providers/auth_provider.dart';
import 'package:grotix/features/supervision/presentation/providers/irrigation_provider.dart';
import 'package:grotix/features/supervision/infrastructure/datasource/telemetry_datasource.dart';

class ZoneDetailPage extends StatefulWidget {
  final Zone zone;

  const ZoneDetailPage({super.key, required this.zone});

  @override
  State<ZoneDetailPage> createState() => _ZoneDetailPageState();
}

class _ZoneDetailPageState extends State<ZoneDetailPage> {
  bool _isEditing = false;
  bool _isSaving = false;

  late ZonePhase _selectedPhase;
  late final TextEditingController _latController;
  late final TextEditingController _lngController;
  late final TextEditingController _imageController;
  late final TextEditingController _minTempCtrl;
  late final TextEditingController _maxTempCtrl;
  late final TextEditingController _minAirHumCtrl;
  late final TextEditingController _maxAirHumCtrl;
  late final TextEditingController _minSoilHumCtrl;
  late final TextEditingController _maxSoilHumCtrl;
  late final TextEditingController _minLightCtrl;
  late final TextEditingController _maxLightCtrl;

  bool _isLoadingThresholds = true;

  @override
  void initState() {
    super.initState();
    _selectedPhase = widget.zone.phase;
    _latController = TextEditingController(text: widget.zone.latitude?.toString() ?? '');
    _lngController = TextEditingController(text: widget.zone.longitude?.toString() ?? '');
    _imageController = TextEditingController(text: widget.zone.imageUrl ?? '');

    final crop = widget.zone.crop;
    _minTempCtrl = TextEditingController(text: crop != null ? (crop.optimalTemperature - 5).round().toString() : '');
    _maxTempCtrl = TextEditingController(text: crop != null ? (crop.optimalTemperature + 5).round().toString() : '');
    _minAirHumCtrl = TextEditingController(text: crop != null ? (crop.optimalHumidityAir - 10).round().toString() : '');
    _maxAirHumCtrl = TextEditingController(text: crop != null ? (crop.optimalHumidityAir + 10).round().toString() : '');
    _minSoilHumCtrl = TextEditingController(text: crop != null ? (crop.optimalHumiditySoil - 10).round().toString() : '');
    _maxSoilHumCtrl = TextEditingController(text: crop != null ? (crop.optimalHumiditySoil + 10).round().toString() : '');
    _minLightCtrl = TextEditingController(text: crop != null ? (crop.optimalLight - 10).round().toString() : '');
    _maxLightCtrl = TextEditingController(text: crop != null ? (crop.optimalLight + 10).round().toString() : '');

    _loadThresholds(); // <- Llamamos al backend al abrir la pantalla
  }

  Future<void> _loadThresholds() async {
    try {
      final thresholds = await TelemetryDatasource().getThresholds(widget.zone.id);


      final crop = widget.zone.crop;

      // Función auxiliar para llenar los inputs con la BD o usar el default del cultivo
      void setCtrl(TextEditingController minC, TextEditingController maxC, String type, double? cropOpt, double margin) {
        final t = thresholds.where((x) => x.sensorType == type).firstOrNull;
        if (t != null && (t.minValue > 0 || t.maxValue > 0)) {
          // Si el backend ya tiene un umbral personalizado, lo usamos
          minC.text = t.minValue.toString();
          maxC.text = t.maxValue.toString();
        } else if (cropOpt != null) {
          // Si no, sugerimos uno en base al cultivo
          minC.text = (cropOpt - margin).toString();
          maxC.text = (cropOpt + margin).toString();
        }
      }

      setCtrl(_minTempCtrl, _maxTempCtrl, 'AIR_TEMPERATURE', crop?.optimalTemperature, 5);
      setCtrl(_minAirHumCtrl, _maxAirHumCtrl, 'AIR_HUMIDITY', crop?.optimalHumidityAir, 10);
      setCtrl(_minSoilHumCtrl, _maxSoilHumCtrl, 'SOIL_MOISTURE', crop?.optimalHumiditySoil, 10);
      setCtrl(_minLightCtrl, _maxLightCtrl, 'LIGHT_INTENSITY', crop?.optimalLight, 10);
    } catch (e) {
      debugPrint("Error cargando umbrales: $e");
    } finally {
      if (mounted) setState(() => _isLoadingThresholds = false);
    }
  }

  @override
  void dispose() {
    _latController.dispose();
    _lngController.dispose();
    _imageController.dispose();
    _minTempCtrl.dispose();
    _maxTempCtrl.dispose();
    _minAirHumCtrl.dispose();
    _maxAirHumCtrl.dispose();
    _minSoilHumCtrl.dispose();
    _maxSoilHumCtrl.dispose();
    _minLightCtrl.dispose();
    _maxLightCtrl.dispose();
    super.dispose();
  }

  /// Roles que pueden editar: admin(1), staff(2), user_admin(3)
  bool _canEdit(int? roleId) => roleId != null && roleId <= 3;

  void _toggleEdit() {
    if (_isEditing) {
      // Cancelar — restaurar valores originales
      setState(() {
        _selectedPhase = widget.zone.phase;
        _latController.text = widget.zone.latitude?.toString() ?? '';
        _lngController.text = widget.zone.longitude?.toString() ?? '';
        _imageController.text = widget.zone.imageUrl ?? '';
        _isEditing = false;
      });
    } else {
      setState(() => _isEditing = true);
    }
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);
    final l10n = AppLocalizations.of(context)!;

    try {
      // 1. Guardar Fase
      final phaseSuccess = await context.read<ZoneProvider>().updateZonePhase(
        widget.zone.id,
        _selectedPhase,
      );

      // 2. Guardar otros campos (Lat, Lng, Image)
      final lat = double.tryParse(_latController.text.trim());
      final lng = double.tryParse(_lngController.text.trim());
      final img = _imageController.text.trim();

      // Forzamos el update de campos para asegurarnos
      await context.read<ZoneProvider>().updateZoneFields(
        widget.zone.id,
        latitude: lat,
        longitude: lng,
        imageUrl: img.isEmpty ? null : img,
      );

      // 3. Guardar Umbrales
      final dashboardProv = context.read<DashboardProvider>();
      List<Map<String, dynamic>> thresholdUpdates = [];

      bool hasValidationErrors = false;

      void addIfValid(String type, String minStr, String maxStr, String labelName) {
        final minV = double.tryParse(minStr.trim());
        final maxV = double.tryParse(maxStr.trim());

        if (minV != null && maxV != null) {
          // VALIDACIÓN: El mínimo no puede ser mayor que el máximo
          if (minV > maxV) {
            hasValidationErrors = true;
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error en $labelName: El mínimo no puede ser mayor al máximo.'),
                  backgroundColor: Colors.redAccent,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
            return; // Sale de la función auxiliar, no lo añade a la lista
          }

          thresholdUpdates.add({
            "SensorType": type,
            "MinValue": minV,
            "MaxValue": maxV
          });
        }
      }

      addIfValid("AIR_TEMPERATURE", _minTempCtrl.text, _maxTempCtrl.text, "Temperatura");
      addIfValid("AIR_HUMIDITY", _minAirHumCtrl.text, _maxAirHumCtrl.text, "Humedad del Aire");
      addIfValid("SOIL_MOISTURE", _minSoilHumCtrl.text, _maxSoilHumCtrl.text, "Humedad del Suelo");
      addIfValid("LIGHT_INTENSITY", _minLightCtrl.text, _maxLightCtrl.text, "Luz");

      // Si hubo errores, detenemos el guardado
      if (hasValidationErrors) {
        setState(() => _isSaving = false);
        return;
      }

      if (thresholdUpdates.isNotEmpty) {
        // Aquí capturaremos si esto falla
        await dashboardProv.updateZoneThresholds(widget.zone.id, thresholdUpdates);
      }

      setState(() => _isEditing = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.changesSaved)));

    } catch (e) {
      debugPrint("💥 ERROR AL GUARDAR: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al guardar: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // Obtener l10n
    final user = context.watch<AuthProvider>().session?.user;
    final canEdit = _canEdit(user?.roleId);
    final zone = widget.zone;
    final crop = zone.crop;
    final isIrrigating = context.watch<IrrigationProvider>().isIrrigating;

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(

        backgroundColor: AppColors.black,
        elevation: 0,
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft, color: AppColors.white, size: 18),
          onPressed: () => context.pop(),
        ),
        title: Text(
          zone.displayName,
          style: const TextStyle(color: AppColors.white, fontSize: 22, fontWeight: FontWeight.w700),
        ),
        actions: [
          if (canEdit)
            TextButton(
              onPressed: _isSaving ? null : _toggleEdit,
              child: Text(
                _isEditing ? l10n.cancel : l10n.edit,
                style: TextStyle(
                  color: _isEditing ? AppColors.white.withOpacity(0.5) : AppColors.greenEmerald,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _ZoneHeroImage(imageUrl: zone.imageUrl),
            const SizedBox(height: 24),

            // SECCIÓN FASE
            _SectionHeader(label: l10n.sectionPhase),
            const SizedBox(height: 12),
            _isEditing
                ? _PhaseSelector(
              selected: _selectedPhase,
              onChanged: (p) => setState(() => _selectedPhase = p),
            )
                : _InfoChip(
              label: _getPhaseLabel(zone.phase, l10n),
              color: _phaseColor(zone.phase),
            ),

            if (zone.phaseStartDate != null) ...[
              const SizedBox(height: 8),
              Text(
                '${l10n.since} ${DateFormat('dd MMM yyyy').format(zone.phaseStartDate!)}${zone.daysInPhase != null ? ' · ${zone.daysInPhase} ${l10n.days}' : ''}',
                style: TextStyle(color: AppColors.white.withOpacity(0.45), fontSize: 13),
              ),
            ],

            const SizedBox(height: 24),

            // SECCIÓN CULTIVO
            if (crop != null) ...[
              _SectionHeader(label: l10n.sectionCrop),
              const SizedBox(height: 12),
              _InfoCard(
                children: [
                  _DetailRow(icon: FontAwesomeIcons.seedling, label: l10n.commonName, value: crop.commonName),
                  _DetailRow(icon: FontAwesomeIcons.microscope, label: l10n.scientificName, value: crop.scientificName, italic: true),
                  const Divider(color: Colors.white12, height: 20),
                  _DetailRow(icon: FontAwesomeIcons.temperatureHalf, label: l10n.optimalTemp, value: '${crop.optimalTemperature}°C'),
                  _DetailRow(icon: FontAwesomeIcons.wind, label: l10n.optimalHumAir, value: '${crop.optimalHumidityAir}%'),
                  _DetailRow(icon: FontAwesomeIcons.droplet, label: l10n.optimalHumSoil, value: '${crop.optimalHumiditySoil}%'),
                  _DetailRow(icon: FontAwesomeIcons.sun, label: l10n.optimalLight, value: '${crop.optimalLight}%'),
                  _DetailRow(icon: FontAwesomeIcons.clock, label: l10n.maxStressTime, value: '${crop.maxStressTime} min'),
                ],
              ),
              const SizedBox(height: 24),
            ],
            if (crop != null && _isEditing) ...[
              _SectionHeader(label: 'Critical Levels (Overrides)'),
              const SizedBox(height: 12),
              _InfoCard(
                children: [
                  const Text('Temperature (°C)', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(child: _EditableDetailRow(icon: FontAwesomeIcons.arrowDown, label: 'Min', controller: _minTempCtrl, value: '', enabled: true, keyboardType: TextInputType.number)),
                      const SizedBox(width: 8),
                      Expanded(child: _EditableDetailRow(icon: FontAwesomeIcons.arrowUp, label: 'Max', controller: _maxTempCtrl, value: '', enabled: true, keyboardType: TextInputType.number)),
                    ],
                  ),
                  const Divider(color: Colors.white12, height: 24),

                  const Text('Air Humidity (%)', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(child: _EditableDetailRow(icon: FontAwesomeIcons.arrowDown, label: 'Min', controller: _minAirHumCtrl, value: '', enabled: true, keyboardType: TextInputType.number)),
                      const SizedBox(width: 8),
                      Expanded(child: _EditableDetailRow(icon: FontAwesomeIcons.arrowUp, label: 'Max', controller: _maxAirHumCtrl, value: '', enabled: true, keyboardType: TextInputType.number)),
                    ],
                  ),
                  const Divider(color: Colors.white12, height: 24),

                  const Text('Soil Moisture (%)', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(child: _EditableDetailRow(icon: FontAwesomeIcons.arrowDown, label: 'Min', controller: _minSoilHumCtrl, value: '', enabled: true, keyboardType: TextInputType.number)),
                      const SizedBox(width: 8),
                      Expanded(child: _EditableDetailRow(icon: FontAwesomeIcons.arrowUp, label: 'Max', controller: _maxSoilHumCtrl, value: '', enabled: true, keyboardType: TextInputType.number)),
                    ],
                  ),
                  const Divider(color: Colors.white12, height: 24),

                  const Text('Light / Radiation (%)', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(child: _EditableDetailRow(icon: FontAwesomeIcons.arrowDown, label: 'Min', controller: _minLightCtrl, value: '', enabled: true, keyboardType: TextInputType.number)),
                      const SizedBox(width: 8),
                      Expanded(child: _EditableDetailRow(icon: FontAwesomeIcons.arrowUp, label: 'Max', controller: _maxLightCtrl, value: '', enabled: true, keyboardType: TextInputType.number)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],

            // SECCIÓN UBICACIÓN
            _SectionHeader(label: l10n.sectionLocation),
            const SizedBox(height: 12),
            _InfoCard(
              children: [
                _EditableDetailRow(
                  icon: FontAwesomeIcons.locationDot,
                  label: l10n.latitudee,
                  controller: _latController,
                  value: zone.latitude?.toString() ?? '—',
                  enabled: _isEditing,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                ),
                _EditableDetailRow(
                  icon: FontAwesomeIcons.locationDot,
                  label: l10n.longitudee,
                  controller: _lngController,
                  value: zone.longitude?.toString() ?? '—',
                  enabled: _isEditing,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                ),
              ],
            ),

            if (_isEditing) ...[
              const SizedBox(height: 24),
              _SectionHeader(label: l10n.sectionImageUrl),
              const SizedBox(height: 12),
              _InfoCard(
                children: [
                  _EditableDetailRow(icon: FontAwesomeIcons.image, label: l10n.imageUrl, controller: _imageController, value: zone.imageUrl ?? '—', enabled: true),
                ],
              ),
            ],

            const SizedBox(height: 24),
            _SectionHeader(label: l10n.sectionInfo),
            const SizedBox(height: 12),
            _InfoCard(
              children: [
                _DetailRow(icon: FontAwesomeIcons.hashtag, label: l10n.zoneId, value: '#${zone.id}'),
                _DetailRow(icon: FontAwesomeIcons.tractor, label: l10n.farmId, value: '#${zone.farmId}'),
              ],
            ),

            const SizedBox(height: 32),
            if (_isEditing)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.greenEmerald,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSaving
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
                      : Text(l10n.saveChanges, style: const TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // Helper para traducir las fases dinámicamente
  String _getPhaseLabel(ZonePhase phase, AppLocalizations l10n) {
    return switch (phase) {
      ZonePhase.seed => l10n.phaseSeed,
      ZonePhase.germination => l10n.phaseGermination,
      ZonePhase.vegetative => l10n.phaseVegetative,
      ZonePhase.flowering => l10n.phaseFlowering,
      ZonePhase.fruiting => l10n.phaseFruiting,
      ZonePhase.harvest => l10n.phaseHarvest,
      _ => l10n.phaseUnknown,
    };
  }

  Color _phaseColor(ZonePhase phase) => switch (phase) {
    ZonePhase.seed => Colors.brown.shade300,
    ZonePhase.germination => Colors.lightGreen,
    ZonePhase.vegetative => AppColors.greenEmerald,
    ZonePhase.flowering => Colors.pinkAccent,
    ZonePhase.fruiting => Colors.orange,
    ZonePhase.harvest => Colors.amber,
    ZonePhase.unknown => Colors.white38,
  };
}

// ─── Widgets privados ─────────────────────────────────────────────────────────

class _ZoneHeroImage extends StatelessWidget {
  final String? imageUrl;
  const _ZoneHeroImage({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white10,
        image: imageUrl != null
            ? DecorationImage(
            image: NetworkImage(imageUrl!), fit: BoxFit.cover)
            : null,
      ),
      child: imageUrl == null
          ? Center(
        child: FaIcon(FontAwesomeIcons.seedling,
            size: 48, color: Colors.white12),
      )
          : null,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Colors.redAccent,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCardBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final FaIconData icon;
  final String label;
  final String value;
  final bool italic;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.italic = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          FaIcon(icon, size: 14, color: AppColors.white.withOpacity(0.4)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                  color: AppColors.white.withOpacity(0.5), fontSize: 15),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: AppColors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              fontStyle: italic ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class _EditableDetailRow extends StatelessWidget {
  final FaIconData icon;
  final String label;
  final TextEditingController controller;
  final String value;
  final bool enabled;
  final TextInputType? keyboardType;

  const _EditableDetailRow({
    required this.icon,
    required this.label,
    required this.controller,
    required this.value,
    required this.enabled,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          FaIcon(icon, size: 14, color: AppColors.white.withOpacity(0.4)),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                  color: AppColors.white.withOpacity(0.5), fontSize: 14),
            ),
          ),
          Expanded(
            flex: 3,
            child: enabled
                ? Container(
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.07),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: controller,
                keyboardType: keyboardType,
                style: const TextStyle(
                    color: AppColors.white, fontSize: 14),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 10, vertical: 8),
                ),
              ),
            )
                : Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final Color color;
  const _InfoChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color, fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _PhaseSelector extends StatelessWidget {
  final ZonePhase selected;
  final ValueChanged<ZonePhase> onChanged;

  const _PhaseSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final phases = ZonePhase.values
        .where((p) => p != ZonePhase.unknown)
        .toList();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: phases.map((phase) {
        final isSelected = phase == selected;
        return GestureDetector(
          onTap: () => onChanged(phase),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.greenEmerald
                  : Colors.white.withOpacity(0.07),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? AppColors.greenEmerald
                    : Colors.white12,
              ),
            ),
            child: Text(
              phase.label,
              style: TextStyle(
                color: isSelected
                    ? AppColors.white
                    : AppColors.white.withOpacity(0.6),
                fontSize: 13,
                fontWeight: isSelected
                    ? FontWeight.w600
                    : FontWeight.w400,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}