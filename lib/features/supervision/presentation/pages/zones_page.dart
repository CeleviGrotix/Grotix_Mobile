import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grotix/l10n/app_localizations.dart'; // Importante
import '../../../../common/theme/app_colors.dart';
import '../../../../common/utils/app_icons.dart';
import '../../domain/entities/crop.dart';
import '../../domain/entities/microcontroller.dart';
import '../../domain/entities/zone.dart';
import '../widgets/zone_card.dart';

class ZonesPage extends StatefulWidget {
  const ZonesPage({super.key});

  @override
  State<ZonesPage> createState() => _ZonesPageState();
}

class _ZonesPageState extends State<ZonesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // TODO: reemplazar por datos reales del repositorio / provider
  final List<Zone> _zones = [
    Zone(
      zoneId: 1,
      farmId: 1,
      cropId: 1,
      currentPhase: 'Vegetative',
      phaseStartDate: DateTime.now().subtract(const Duration(days: 10)),
      imageUrl: null,
      lastUpdate: DateTime.now().subtract(const Duration(minutes: 5)),
      crop: const Crop(
        cropId: 1,
        commonName: 'Zona Tomatitos',
        scientificName: 'Solanum lycopersicum',
        optimalTemperature: 22,
        optimalHumidity: 70,
        optimalLight: 8,
        maxStressTime: 48,
      ),
      microcontrollers: [
        Microcontroller(
          deviceId: 1,
          zoneId: 1,
          model: 'ESP32',
          macAddress: 'AA:BB:CC:DD:EE:FF',
          status: MicrocontrollerStatus.active,
          lastSeen: DateTime.now(),
        ),
      ],
    ),
    Zone(
      zoneId: 2,
      farmId: 1,
      cropId: 2,
      currentPhase: 'Growth',
      phaseStartDate: DateTime.now().subtract(const Duration(days: 20)),
      imageUrl: null,
      lastUpdate: DateTime.now().subtract(const Duration(minutes: 15)),
      crop: const Crop(
        cropId: 2,
        commonName: 'Área de Zanahorias',
        scientificName: 'Daucus carota',
        optimalTemperature: 18,
        optimalHumidity: 65,
        optimalLight: 7,
        maxStressTime: 36,
      ),
      microcontrollers: [
        Microcontroller(
          deviceId: 2,
          zoneId: 2,
          model: 'ESP32',
          macAddress: 'AA:BB:CC:DD:EE:01',
          status: MicrocontrollerStatus.error,
          lastSeen: DateTime.now().subtract(const Duration(hours: 1)),
        ),
      ],
    ),
  ];

  List<Zone> get _filteredZones {
    if (_searchQuery.isEmpty) return _zones;
    return _zones
        .where((z) =>
        z.displayName.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos las traducciones
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                l10n.cultivationAreas, // Traducción del título
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _SearchAndActions(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                onAdd: _onAddZone,
                onFilter: _onFilter,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _filteredZones.isEmpty
                    ? const _EmptyState()
                    : ListView.separated(
                  itemCount: _filteredZones.length,
                  separatorBuilder: (_, __) =>
                  const SizedBox(height: 12),
                  itemBuilder: (_, i) => ZoneCard(
                    zone: _filteredZones[i],
                    onTap: () => _onZoneTap(_filteredZones[i]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onAddZone() {
    // TODO: navegar a CreateZonePage
  }

  void _onFilter() {
    // TODO: mostrar bottom sheet de filtros
  }

  void _onZoneTap(Zone zone) {
    // TODO: navegar a ZoneDetailPage
  }
}

// ─── Barra de búsqueda + acciones ───────────────────────────────────────────

class _SearchAndActions extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onAdd;
  final VoidCallback onFilter;

  const _SearchAndActions({
    required this.controller,
    required this.onChanged,
    required this.onAdd,
    required this.onFilter,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: const TextStyle(color: AppColors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: l10n.searchZones, // Traducción del placeholder
                hintStyle: TextStyle(color: AppColors.white.withOpacity(0.35), fontSize: 14),

                prefixIcon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: FaIcon(AppIcons.search,
                      size: 16, color: AppColors.white.withOpacity(0.4)),
                ),

                prefixIconConstraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 0,
                ),

                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        _ActionButton(
          icon: AppIcons.add,
          color: AppColors.greenEmerald,
          onTap: onAdd,
        ),
        const SizedBox(width: 8),
        _ActionButton(
          icon: AppIcons.filter,
          color: Colors.transparent,
          borderColor: AppColors.greenEmerald,
          onTap: onFilter,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color? borderColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          border: borderColor != null
              ? Border.all(color: borderColor!, width: 1.5)
              : null,
        ),
        child: Center(
          child: FaIcon(icon, size: 18, color: AppColors.white),
        ),
      ),
    );
  }
}

// ─── Empty state ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(FontAwesomeIcons.seedling,
              size: 48, color: AppColors.white.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text(
            l10n.noZonesFound,
            style: TextStyle(
              color: AppColors.white.withOpacity(0.4),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}