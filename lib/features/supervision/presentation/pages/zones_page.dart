import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:grotix/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../../common/theme/app_colors.dart';
import '../../../../common/utils/app_icons.dart';
import '../../../identity/profile/presentation/provider/profile_provider.dart';
import '../../domain/entities/zone.dart';
import '../providers/zone_provider.dart';
import '../widgets/zone_card.dart';

class ZonesPage extends StatefulWidget {
  const ZonesPage({super.key});

  @override
  State<ZonesPage> createState() => _ZonesPageState();
}

class _ZonesPageState extends State<ZonesPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<ProfileProvider>().user;
      if (user?.associationId != null) {
        context.read<ZoneProvider>().loadFromAssociation(user!.associationId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final zoneProvider = context.watch<ZoneProvider>();

    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(l10n.cultivationAreas, style: const TextStyle(
                color: AppColors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),),
              const SizedBox(height: 16),

              _SearchAndActions(
                controller: _searchController,
                onChanged: (v) => zoneProvider.setSearchQuery(v),
                onAdd: () => _onAddZone(context, l10n), // Pasamos contexto y l10n
                onFilter: _onFilter,
              ),

              const SizedBox(height: 20),

              Expanded(
                child: _buildContent(zoneProvider, l10n),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(ZoneProvider provider, AppLocalizations l10n) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.greenEmerald));
    }

    if (provider.zones.isEmpty) {
      return const _EmptyState();
    }

    return ListView.separated(
      itemCount: provider.zones.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => ZoneCard(
        zone: provider.zones[i],
        onTap: () => _onZoneTap(provider.zones[i]),
      ),
    );
  }

  // ── MODAL DE SOPORTE PARA NUEVAS ZONAS (INTERNACIONALIZADO) ────────────
  void _onAddZone(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.darkCardBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Para que el modal se adapte al contenido
              children: [
                // Icono decorativo
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.greenEmerald.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.support_agent, color: AppColors.greenEmerald, size: 42),
                ),
                const SizedBox(height: 20),

                // Título
                Text(
                  l10n.addNewZone,
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                // Explicación técnica y elegante
                Text(
                  l10n.addZoneSupportDesc,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
                ),
                const SizedBox(height: 24),

                // Tarjeta con el número de contacto
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  // AQUÍ ESTÁ EL FIX: Agregamos "child:"
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.phone, color: AppColors.greenEmerald, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        l10n.supportPhone,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Botón de cerrar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.greenEmerald,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    child: Text(
                        l10n.understood,
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15)
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _onFilter() {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.read<ZoneProvider>();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkCardBg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.filterAndSort, style: const TextStyle(color: AppColors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // SECCIÓN: ORDENAR
            Text(l10n.sortBy, style: TextStyle(color: AppColors.white.withOpacity(0.5), fontSize: 14)),
            _buildSortTile(l10n.nameAz, ZoneSortOption.nameAz, provider),
            _buildSortTile(l10n.nameZa, ZoneSortOption.nameZa, provider),
            _buildSortTile(l10n.newestPhase, ZoneSortOption.phaseDateNewest, provider),

            const Divider(color: Colors.white10),

            // SECCIÓN: FILTRAR POR FASE
            Text(l10n.filterByPhase, style: TextStyle(color: AppColors.white.withOpacity(0.5), fontSize: 14)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: ZonePhase.values.where((p) => p != ZonePhase.unknown).map((phase) {
                final isSelected = provider.phaseFilter == phase;
                return ChoiceChip(
                  label: Text(phase.label),
                  selected: isSelected,
                  onSelected: (selected) => provider.setPhaseFilter(selected ? phase : null),
                  selectedColor: AppColors.greenEmerald,
                  backgroundColor: AppColors.darkNavBarB,
                  labelStyle: TextStyle(color: isSelected ? Colors.black : Colors.white),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSortTile(String title, ZoneSortOption option, ZoneProvider provider) {
    final isSelected = provider.sortOption == option;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: TextStyle(color: isSelected ? AppColors.greenEmerald : AppColors.white)),
      trailing: isSelected ? const Icon(Icons.check, color: AppColors.greenEmerald) : null,
      onTap: () => provider.setSortOption(option),
    );
  }

  void _onZoneTap(Zone zone) {
    // Navegación al detalle usando GoRouter y pasando el ID
    context.push('/zones/${zone.id}', extra: zone);
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
                hintText: l10n.searchZones,
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
  final FaIconData icon;
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