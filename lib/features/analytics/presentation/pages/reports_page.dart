import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grotix/common/theme/app_colors.dart';
import 'package:grotix/features/supervision/application/services/zone_service.dart';
import 'package:grotix/features/supervision/infrastructure/datasource/zone_datasource.dart';
import 'package:grotix/features/supervision/infrastructure/repositories/zone_repository_impl.dart';
import 'package:grotix/features/supervision/presentation/providers/dashboard_provider.dart';
import 'package:grotix/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  static const _customRangeKey = 'custom';

  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedRange = '3m';
  bool _isGenerating = false;

  final ZoneService _zoneService =
      ZoneService(ZoneRepositoryImpl(ZoneRemoteDatasource()));

  @override
  void initState() {
    super.initState();
    _applyQuickRange('3m');
  }

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  int _daysForRange(String key) => switch (key) {
        '1w' => 7,
        '1m' => 30,
        '3m' => 90,
        '6m' => 180,
        '1y' => 365,
        _ => 90,
      };

  void _applyQuickRange(String key) {
    final end = _dateOnly(DateTime.now());
    final start = end.subtract(Duration(days: _daysForRange(key)));
    setState(() {
      _endDate = end;
      _startDate = start;
      _selectedRange = key;
    });
  }

  void _markCustomRange() {
    if (_selectedRange != _customRangeKey) {
      setState(() => _selectedRange = _customRangeKey);
    }
  }

  Future<void> _pickDate({required bool isStart}) async {
    final l10n = AppLocalizations.of(context)!;
    final today = _dateOnly(DateTime.now());
    final initial = isStart
        ? (_startDate ?? today)
        : (_endDate ?? _startDate ?? today);

    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: today,
      helpText: isStart ? l10n.start : l10n.finish,
    );

    if (date == null) return;

    setState(() {
      if (isStart) {
        _startDate = _dateOnly(date);
        if (_endDate != null && _startDate!.isAfter(_endDate!)) {
          _endDate = _startDate;
        }
      } else {
        _endDate = _dateOnly(date);
        if (_startDate != null && _endDate!.isBefore(_startDate!)) {
          _startDate = _endDate;
        }
      }
      _markCustomRange();
    });
  }

  void _onGenerate() async {
    final l10n = AppLocalizations.of(context)!;
    final zone = context.read<DashboardProvider>().selectedZone;

    if (zone == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.selectZone)),
      );
      return;
    }

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.reportMissingDates)),
      );
      return;
    }

    if (_startDate!.isAfter(_endDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.reportInvalidRange)),
      );
      return;
    }

    setState(() => _isGenerating = true);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final pdfBytes = await _zoneService.exportZoneReportPdf(
        zone.id,
        _startDate!,
        _endDate!,
      );

      final dir = await getTemporaryDirectory();
      final fileName =
          'grotix-zona-${zone.id}-${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(pdfBytes, flush: true);

      if (!mounted) return;
      await OpenFile.open(file.path);

      messenger.showSnackBar(
        SnackBar(content: Text(l10n.reportGenerated)),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.reportGenerateFailed)),
      );
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final selectedZone = context.watch<DashboardProvider>().selectedZone;

    final Map<String, String> rangeOptions = {
      '1w': l10n.week,
      '1m': l10n.month,
      '3m': l10n.threeMonths,
      '6m': l10n.sixMonths,
      '1y': l10n.year,
      _customRangeKey: l10n.customRange,
    };

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
                l10n.generateReport,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (selectedZone != null) ...[
                const SizedBox(height: 8),
                Text(
                  selectedZone.displayName,
                  style: TextStyle(
                    color: AppColors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.darkCardBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.reportPeriodTitle,
                      style: const TextStyle(
                        color: AppColors.blueCerulean,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _DateRow(
                      label: l10n.start,
                      date: _startDate != null
                          ? DateFormat('dd/MM/yy').format(_startDate!)
                          : '--/--/--',
                      onTap: () => _pickDate(isStart: true),
                    ),
                    const SizedBox(height: 12),
                    _DateRow(
                      label: l10n.finish,
                      date: _endDate != null
                          ? DateFormat('dd/MM/yy').format(_endDate!)
                          : '--/--/--',
                      onTap: () => _pickDate(isStart: false),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.quickRangeLabel,
                      style: TextStyle(
                        color: AppColors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _RangeDropdown(
                      value: _selectedRange,
                      options: rangeOptions,
                      onChanged: (val) {
                        if (val == null || val == _customRangeKey) return;
                        _applyQuickRange(val);
                      },
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: _GenerateButton(
                        label: l10n.generate,
                        onPressed: _onGenerate,
                        isLoading: _isGenerating,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.darkCardBg.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: FaIcon(
                      FontAwesomeIcons.fileLines,
                      size: 60,
                      color: AppColors.white.withOpacity(0.1),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateRow extends StatelessWidget {
  final String label;
  final String date;
  final VoidCallback onTap;

  const _DateRow({required this.label, required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          SizedBox(
            width: 45,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.white, fontSize: 13),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                date,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.white, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RangeDropdown extends StatelessWidget {
  final String value;
  final Map<String, String> options;
  final ValueChanged<String?> onChanged;

  const _RangeDropdown({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: AppColors.darkCardBg,
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.white),
          style: const TextStyle(color: AppColors.white, fontSize: 12),
          isExpanded: true,
          onChanged: onChanged,
          items: options.entries
              .map((e) => DropdownMenuItem(
                    value: e.key,
                    enabled: e.key != 'custom',
                    child: Text(e.value),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class _GenerateButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;

  const _GenerateButton({
    required this.label,
    required this.onPressed,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.greenEmerald, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: isLoading
          ? const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.greenEmerald,
              ),
            )
          : Text(
              label,
              style: const TextStyle(
                color: AppColors.greenEmerald,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }
}
