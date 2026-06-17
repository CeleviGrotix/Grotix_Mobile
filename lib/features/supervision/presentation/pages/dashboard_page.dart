import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grotix/features/supervision/presentation/widgets/zone_dropdown.dart';
import 'package:grotix/features/supervision/domain/entities/zone.dart';
import 'package:grotix/l10n/app_localizations.dart';
import 'package:grotix/common/theme/app_colors.dart';
import '../../../identity/auth/presentation/providers/auth_provider.dart';
import '../../../identity/profile/presentation/provider/profile_provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/main_tab_view.dart';
import '../widgets/people_tab_view.dart';
import '../widgets/settings_tab_view.dart';
import '../widgets/tab_button.dart';
import 'package:grotix/features/supervision/presentation/providers/irrigation_provider.dart';
import '../widgets/irrigation_active_dialog.dart';

enum DashboardTab { main, settings, people }

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  DashboardTab _activeTab = DashboardTab.main;

  // _allowAuto ya no es estado local: ahora se deriva de Zone.irrigationMode
  // (ver el cómputo dentro de build()).
  String _maxTime = '1 min';

  @override
  void initState() {
    super.initState();
  }

  /// Pide confirmación antes de pasar la zona a modo manual.
  /// TODO: estos strings son placeholders — reemplazar por l10n.xxx cuando
  /// tengamos las keys agregadas al archivo de localización.
  Future<bool> _confirmSwitchToManual(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkCardBg,
        title: const Text(
          'Switch to manual mode?',
          style: TextStyle(color: AppColors.white),
        ),
        content: const Text(
          'This zone is currently in automatic mode. Starting manual '
              'irrigation will switch it to manual mode, so the automatic '
              'system stops controlling it.',
          style: TextStyle(color: AppColors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.white.withOpacity(0.5)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Switch & start',
              style: TextStyle(color: AppColors.greenEmerald),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showErrorSnackbar(BuildContext context, Object error) {
    final message = error.toString().replaceFirst('Exception: ', '');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.redCoral,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = context.watch<AuthProvider>().session?.user;
    final profileProvider = context.watch<ProfileProvider>();
    final dashboardProvider = context.watch<DashboardProvider>();

    final selectedZone = dashboardProvider.selectedZone;
    // Sin zona cargada todavía, mostramos "auto" por defecto para no
    // arrancar con el switch en un falso estado de "manual".
    final allowAuto =
        selectedZone == null || selectedZone.mode != IrrigationMode.manual;

    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ZoneDropdown(
                selectedZone: dashboardProvider.selectedZone,
                zones: dashboardProvider.availableZones,
                onChanged: (zone) => dashboardProvider.selectZone(zone),
              ),
            ),
            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  TabButton(
                    label: l10n.mainTab,
                    isActive: _activeTab == DashboardTab.main,
                    onTap: () => setState(() => _activeTab = DashboardTab.main),
                  ),
                  const SizedBox(width: 8),
                  TabButton(
                    label: l10n.settingsTab,
                    isActive: _activeTab == DashboardTab.settings,
                    onTap: () => setState(() => _activeTab = DashboardTab.settings),
                  ),
                  const SizedBox(width: 8),
                  TabButton(
                    label: l10n.peopleTab,
                    isActive: _activeTab == DashboardTab.people,
                    onTap: () => setState(() => _activeTab = DashboardTab.people),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: dashboardProvider.isLoadingTelemetry
                  ? const Center(child: CircularProgressIndicator(color: AppColors.greenEmerald))
                  : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: switch (_activeTab) {
                  DashboardTab.main => MainTabView(l10n: l10n),
                  DashboardTab.settings => SettingsTabView(
                    l10n: l10n,
                    allowAuto: allowAuto,
                    manualIrrigation: context.watch<IrrigationProvider>().isIrrigating,
                    maxTime: _maxTime,
                    onAutoChanged: (val) async {
                      final zoneId = dashboardProvider.selectedZone?.id;
                      if (zoneId == null) return;
                      try {
                        await dashboardProvider.setAutoIrrigation(zoneId, val);
                        // Si activamos auto mientras hay un riego manual en
                        // curso, lo detenemos: ya no tiene sentido un ciclo
                        // manual con la zona controlada por el sistema automático.
                        if (val &&
                            context.mounted &&
                            context.read<IrrigationProvider>().isIrrigating) {
                          await context.read<IrrigationProvider>().stopIrrigation(zoneId);
                        }
                      } catch (e) {
                        if (context.mounted) _showErrorSnackbar(context, e);
                      }
                    },
                    onManualChanged: (encender) async {
                      final zoneId = dashboardProvider.selectedZone?.id;
                      if (zoneId == null) return;

                      if (encender) {
                        final zone = dashboardProvider.selectedZone!;
                        if (zone.mode != IrrigationMode.manual) {
                          final confirmed = await _confirmSwitchToManual(context);
                          if (!confirmed) return;

                          try {
                            await dashboardProvider.setAutoIrrigation(zoneId, false);
                          } catch (e) {
                            if (context.mounted) _showErrorSnackbar(context, e);
                            return;
                          }
                        }

                        int duracion = int.tryParse(_maxTime.split(' ').first) ?? 1;

                        final success = await context.read<IrrigationProvider>().startIrrigation(zoneId, durationMinutes: duracion);

                        if (success && context.mounted) {
                          showModalBottomSheet(
                            context: context,
                            isDismissible: false,
                            builder: (context) => IrrigationActiveDialog(
                              durationMinutes: duracion,
                              onStop: () async {
                                await context.read<IrrigationProvider>().stopIrrigation(zoneId);
                              },
                            ),
                          ).then((_) => context.read<IrrigationProvider>().clearIrrigatingState());
                        }
                      } else {
                        await context.read<IrrigationProvider>().stopIrrigation(zoneId);
                      }
                    },
                    onTimeChanged: (v) => setState(() => _maxTime = v!),
                  ),
                  DashboardTab.people => PeopleTabView(
                    l10n: l10n,
                    userRoleId: user?.roleId,
                    associationId: profileProvider.user?.associationId,
                  ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}