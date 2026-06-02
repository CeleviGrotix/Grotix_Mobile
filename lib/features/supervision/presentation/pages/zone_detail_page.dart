import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:grotix/common/theme/app_colors.dart';
import 'package:grotix/features/supervision/domain/entities/zone.dart';
import 'package:grotix/features/supervision/presentation/providers/zone_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../identity/auth/presentation/providers/auth_provider.dart';

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

  @override
  void initState() {
    super.initState();
    _selectedPhase = widget.zone.phase;
    _latController = TextEditingController(
        text: widget.zone.latitude?.toString() ?? '');
    _lngController = TextEditingController(
        text: widget.zone.longitude?.toString() ?? '');
    _imageController = TextEditingController(
        text: widget.zone.imageUrl ?? '');
  }

  @override
  void dispose() {
    _latController.dispose();
    _lngController.dispose();
    _imageController.dispose();
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

    final success = await context.read<ZoneProvider>().updateZonePhase(
      widget.zone.id,
      _selectedPhase,
    );

    // Si hay otros campos editados (lat, lng, image) también los mandamos
    if (success) {
      final lat = double.tryParse(_latController.text.trim());
      final lng = double.tryParse(_lngController.text.trim());
      final img = _imageController.text.trim();

      final hasOtherChanges = lat != widget.zone.latitude ||
          lng != widget.zone.longitude ||
          img != (widget.zone.imageUrl ?? '');

      if (hasOtherChanges) {
        await context.read<ZoneProvider>().updateZoneFields(
          widget.zone.id,
          latitude: lat,
          longitude: lng,
          imageUrl: img.isEmpty ? null : img,
        );
      }
    }

    setState(() {
      _isSaving = false;
      if (success) _isEditing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Zone updated' : 'Failed to update zone'),
          backgroundColor:
          success ? AppColors.greenEmerald : Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().session?.user;
    final canEdit = _canEdit(user?.roleId);
    final zone = widget.zone;
    final crop = zone.crop;

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        elevation: 0,
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft,
              color: AppColors.white, size: 18),
          onPressed: () => context.pop(),
        ),
        title: Text(
          zone.displayName,
          style: const TextStyle(
              color: AppColors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700),
        ),
        actions: [
          if (canEdit)
            TextButton(
              onPressed: _isSaving ? null : _toggleEdit,
              child: Text(
                _isEditing ? 'Cancel' : 'Edit',
                style: TextStyle(
                  color: _isEditing
                      ? AppColors.white.withOpacity(0.5)
                      : AppColors.greenEmerald,
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

            // ── Imagen de la zona ──────────────────────────────
            _ZoneHeroImage(imageUrl: zone.imageUrl),
            const SizedBox(height: 24),

            // ── Fase actual ────────────────────────────────────
            _SectionHeader(label: 'PHASE'),
            const SizedBox(height: 12),

            _isEditing
                ? _PhaseSelector(
              selected: _selectedPhase,
              onChanged: (p) => setState(() => _selectedPhase = p),
            )
                : _InfoChip(
              label: zone.phase.label,
              color: _phaseColor(zone.phase),
            ),

            if (zone.phaseStartDate != null) ...[
              const SizedBox(height: 8),
              Text(
                'Since ${DateFormat('dd MMM yyyy').format(zone.phaseStartDate!)}${zone.daysInPhase != null ? ' · ${zone.daysInPhase} days' : ''}',
                style: TextStyle(
                    color: AppColors.white.withOpacity(0.45), fontSize: 13),
              ),
            ],

            const SizedBox(height: 24),

            // ── Info del cultivo ───────────────────────────────
            if (crop != null) ...[
              _SectionHeader(label: 'CROP'),
              const SizedBox(height: 12),
              _InfoCard(
                children: [
                  _DetailRow(
                    icon: FontAwesomeIcons.seedling,
                    label: 'Common name',
                    value: crop.commonName,
                  ),
                  _DetailRow(
                    icon: FontAwesomeIcons.microscope,
                    label: 'Scientific name',
                    value: crop.scientificName,
                    italic: true,
                  ),
                  const Divider(color: Colors.white12, height: 20),
                  _DetailRow(
                    icon: FontAwesomeIcons.temperatureHalf,
                    label: 'Optimal temperature',
                    value: '${crop.optimalTemperature}°C',
                  ),
                  _DetailRow(
                    icon: FontAwesomeIcons.droplet,
                    label: 'Optimal humidity',
                    value: '${crop.optimalHumidity}%',
                  ),
                  _DetailRow(
                    icon: FontAwesomeIcons.sun,
                    label: 'Optimal light',
                    value: '${crop.optimalLight} lux',
                  ),
                  _DetailRow(
                    icon: FontAwesomeIcons.clock,
                    label: 'Max stress time',
                    value: '${crop.maxStressTime} min',
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],

            // ── Ubicación ──────────────────────────────────────
            _SectionHeader(label: 'LOCATION'),
            const SizedBox(height: 12),
            _InfoCard(
              children: [
                _EditableDetailRow(
                  icon: FontAwesomeIcons.locationDot,
                  label: 'Latitude',
                  controller: _latController,
                  value: zone.latitude?.toString() ?? '—',
                  enabled: _isEditing,
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true, signed: true),
                ),
                _EditableDetailRow(
                  icon: FontAwesomeIcons.locationDot,
                  label: 'Longitude',
                  controller: _lngController,
                  value: zone.longitude?.toString() ?? '—',
                  enabled: _isEditing,
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true, signed: true),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Imagen URL (solo si edita) ─────────────────────
            if (_isEditing) ...[
              _SectionHeader(label: 'IMAGE URL'),
              const SizedBox(height: 12),
              _InfoCard(
                children: [
                  _EditableDetailRow(
                    icon: FontAwesomeIcons.image,
                    label: 'Image URL',
                    controller: _imageController,
                    value: zone.imageUrl ?? '—',
                    enabled: true,
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],

            // ── Metadata ───────────────────────────────────────
            _SectionHeader(label: 'INFO'),
            const SizedBox(height: 12),
            _InfoCard(
              children: [
                _DetailRow(
                  icon: FontAwesomeIcons.hashtag,
                  label: 'Zone ID',
                  value: '#${zone.id}',
                ),
                _DetailRow(
                  icon: FontAwesomeIcons.tractor,
                  label: 'Farm ID',
                  value: '#${zone.farmId}',
                ),
              ],
            ),

            const SizedBox(height: 32),

            // ── Botón guardar ──────────────────────────────────
            if (_isEditing)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.greenEmerald,
                    disabledBackgroundColor:
                    AppColors.greenEmerald.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.white),
                  )
                      : const Text(
                    'Save changes',
                    style: TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
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
  final IconData icon;
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
  final IconData icon;
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