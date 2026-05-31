import 'package:flutter/material.dart';
import '../../../../common/theme/app_colors.dart';
import 'package:grotix/l10n/app_localizations.dart';

import '../widgets/main_tab_view.dart';
import '../widgets/people_tab_view.dart' show PeopleTabView;
import '../widgets/settings_tab_view.dart';
import '../widgets/tab_button.dart';


enum DashboardTab { main, settings, people }

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  DashboardTab _activeTab = DashboardTab.main;

  // Estados locales fake para desarrollo
  bool _allowAuto = true;
  bool _manualIrrigation = false;
  String _maxTime = '30 min';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Header: Dropdown de Zona
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Text(
                    'Zona Tomatitos',
                    style: TextStyle(color: AppColors.white, fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.arrow_drop_down, color: AppColors.greenEmerald, size: 30),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Segmented Tab Bar Superior
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

            // Contenedor Scrollable del renderizado dinámico
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: switch (_activeTab) {
                  DashboardTab.main => MainTabView(l10n: l10n),
                  DashboardTab.settings => SettingsTabView(
                    l10n: l10n,
                    allowAuto: _allowAuto,
                    manualIrrigation: _manualIrrigation,
                    maxTime: _maxTime,
                    onAutoChanged: (v) => setState(() => _allowAuto = v),
                    onManualChanged: (v) => setState(() => _manualIrrigation = v),
                    onTimeChanged: (v) => setState(() => _maxTime = v!),
                  ),
                  DashboardTab.people => PeopleTabView(l10n: l10n),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}