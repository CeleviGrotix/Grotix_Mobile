import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grotix/common/theme/app_colors.dart';
import 'package:grotix/features/supervision/domain/entities/crop.dart';
import 'package:grotix/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../providers/dashboard_provider.dart';

class SettingsTabView extends StatefulWidget {
  final AppLocalizations l10n;
  final bool allowAuto;
  final bool manualIrrigation;
  final String maxTime;
  final int? userRoleId;
  final Future<void> Function(bool) onAutoChanged;
  final Future<void> Function(bool) onManualChanged;
  final ValueChanged<String?> onTimeChanged;

  const SettingsTabView({
    super.key,
    required this.l10n,
    required this.allowAuto,
    required this.manualIrrigation,
    required this.maxTime,
    required this.onAutoChanged,
    required this.onManualChanged,
    required this.onTimeChanged,
    this.userRoleId,
  });

  @override
  State<SettingsTabView> createState() => _SettingsTabViewState();
}

class _SettingsTabViewState extends State<SettingsTabView> {
  final _moistureAirController = TextEditingController();
  final _moistureSoilController = TextEditingController();
  final _lightController = TextEditingController();
  final _tempController = TextEditingController();
  bool _isEditingLevels = false;
  bool _isSavingLevels = false;

  // ── Duración de riego (nuevo: input numérico en vez de dropdown) ─────────
  final _maxTimeController = TextEditingController();
  final _maxTimeFocusNode = FocusNode();

  bool get _canEditLevels =>
      widget.userRoleId != null && widget.userRoleId! <= 3;

  @override
  void initState() {
    super.initState();
    _maxTimeController.text = _extractMinutes(widget.maxTime).toString();
    _maxTimeFocusNode.addListener(() {
      if (!_maxTimeFocusNode.hasFocus) {
        _commitMaxTime(_maxTimeController.text);
      }
    });
  }

  @override
  void didUpdateWidget(covariant SettingsTabView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si el valor cambió desde afuera (ej. otro lugar de la app lo actualizó)
    // y el usuario no está editando en este momento, sincronizamos el campo.
    if (oldWidget.maxTime != widget.maxTime && !_maxTimeFocusNode.hasFocus) {
      _maxTimeController.text = _extractMinutes(widget.maxTime).toString();
    }
  }

  int _extractMinutes(String maxTime) =>
      int.tryParse(maxTime.split(' ').first) ?? 1;

  void _commitMaxTime(String raw) {
    final parsed = int.tryParse(raw);
    final clamped = (parsed ?? 1).clamp(1, 100);
    if (clamped.toString() != raw) {
      _maxTimeController.text = clamped.toString();
    }
    widget.onTimeChanged('$clamped min');
  }

  void _stepMaxTime(int delta) {
    final current = int.tryParse(_maxTimeController.text) ?? 1;
    final next = (current + delta).clamp(1, 100);
    _maxTimeController.text = next.toString();
    widget.onTimeChanged('$next min');
  }

  @override
  void dispose() {
    _moistureAirController.dispose();
    _moistureSoilController.dispose();
    _lightController.dispose();
    _tempController.dispose();
    _maxTimeController.dispose();
    _maxTimeFocusNode.dispose();
    super.dispose();
  }

  void _fillLevelControllers(Crop crop) {
    _moistureAirController.text = crop.optimalHumidityAir.round().toString();
    _moistureSoilController.text = crop.optimalHumiditySoil.round().toString();
    _lightController.text = crop.optimalLight.round().toString();
    _tempController.text = crop.optimalTemperature.round().toString();
  }

  Future<void> _saveLevels() async {
    setState(() => _isSavingLevels = true);

    // TODO: PATCH /crops/{id} cuando el backend lo exponga
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _isSavingLevels = false;
      _isEditingLevels = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Critical levels updated'),
          backgroundColor: AppColors.greenEmerald,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = context.watch<DashboardProvider>();
    final crop = dashboard.selectedZone?.crop;

    if (crop != null && !_isEditingLevels) {
      _fillLevelControllers(crop);
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: AppColors.darkCardBg,
              borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle(widget.l10n.irrigation),
              const SizedBox(height: 4),
              _IrrigationToggle(
                label: widget.l10n.allowAutoIrrigation,
                value: widget.allowAuto,
                onChanged: (bool val) async {
                  await widget.onAutoChanged(val);
                },
              ),
              const Divider(color: Colors.white10, height: 20),

              _IrrigationToggle(
                label: widget.l10n.startManualIrrigation,
                value: widget.manualIrrigation,
                onChanged: (bool val) async {
                  await widget.onManualChanged(val);
                },
              ),

              const SizedBox(height: 20),
              _SectionTitle(widget.l10n.maxTimeIrrigation),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, color: AppColors.white),
                      onPressed: () => _stepMaxTime(-1),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _maxTimeController,
                        focusNode: _maxTimeFocusNode,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(3),
                        ],
                        style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          suffixText: 'min',
                          suffixStyle: TextStyle(color: Colors.white54),
                        ),
                        onSubmitted: (value) {
                          _commitMaxTime(value);
                          _maxTimeFocusNode.unfocus();
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, color: AppColors.white),
                      onPressed: () => _stepMaxTime(1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: AppColors.darkCardBg,
              borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _SectionTitle(widget.l10n.criticalLevels),
                  if (_canEditLevels)
                    TextButton(
                      onPressed: _isSavingLevels
                          ? null
                          : () {
                        if (_isEditingLevels) {
                          _saveLevels();
                        } else {
                          setState(() => _isEditingLevels = true);
                        }
                      },
                      child: _isSavingLevels
                          ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.greenEmerald),
                      )
                          : Text(
                        _isEditingLevels ? 'Save' : 'Edit',
                        style: TextStyle(
                          color: _isEditingLevels
                              ? AppColors.greenEmerald
                              : AppColors.white.withOpacity(0.5),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              if (crop == null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'No crop data available',
                    style: TextStyle(
                        color: AppColors.white.withOpacity(0.4),
                        fontSize: 14),
                  ),
                )
              else ...[
                _CriticalLevelRow(
                  label: widget.l10n.moistureAir,
                  controller: _moistureAirController,
                  unit: '%',
                  enabled: _isEditingLevels,
                ),
                _CriticalLevelRow(
                  label: widget.l10n.moistureSoil,
                  controller: _moistureSoilController,
                  unit: '%',
                  enabled: _isEditingLevels,
                ),
                _CriticalLevelRow(
                  label: widget.l10n.lightRadiation,
                  controller: _lightController,
                  unit: 'lux',
                  enabled: _isEditingLevels,
                ),
                _CriticalLevelRow(
                  label: widget.l10n.temperature,
                  controller: _tempController,
                  unit: '°C',
                  enabled: _isEditingLevels,
                ),
              ],
              if (_isEditingLevels) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => setState(() {
                      _isEditingLevels = false;
                      if (crop != null) _fillLevelControllers(crop);
                    }),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                          color: AppColors.white.withOpacity(0.4),
                          fontSize: 14),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: const TextStyle(
            color: AppColors.blueCerulean,
            fontSize: 18,
            fontWeight: FontWeight.w600));
  }
}

class _IrrigationToggle extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _IrrigationToggle({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label,
              style: const TextStyle(color: AppColors.white, fontSize: 15)),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.greenEmerald,
          activeTrackColor: AppColors.greenEmerald.withOpacity(0.3),
          inactiveThumbColor: AppColors.redCoral,
          inactiveTrackColor: AppColors.redCoral.withOpacity(0.3),
        ),
      ],
    );
  }
}

class _CriticalLevelRow extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String unit;
  final bool enabled;

  const _CriticalLevelRow({
    required this.label,
    required this.controller,
    required this.unit,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
              const TextStyle(color: AppColors.white, fontSize: 15)),
          enabled
              ? Container(
            width: 80,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                  color: AppColors.greenEmerald.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                      isDense: true,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Text(unit,
                      style: TextStyle(
                          color: AppColors.white.withOpacity(0.4),
                          fontSize: 11)),
                ),
              ],
            ),
          )
              : Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(6)),
            child: Text(
              '${controller.text} $unit',
              style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}