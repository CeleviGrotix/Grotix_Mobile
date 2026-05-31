import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grotix/common/theme/app_colors.dart';
import 'package:grotix/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedRange;
  bool _isGenerating = false;

  void _onGenerate() async {
    setState(() => _isGenerating = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _isGenerating = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.changesSaved)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Mapa de rangos para el dropdown
    final Map<String, String> rangeOptions = {
      '1w': l10n.week,
      '1m': l10n.month,
      '3m': l10n.threeMonths,
      '6m': l10n.sixMonths,
      '1y': l10n.year,
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
                      l10n.irrigation,
                      style: const TextStyle(
                        color: AppColors.blueCerulean,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            children: [
                              _DateRow(
                                label: l10n.start,
                                date: _startDate != null ? DateFormat('dd/MM/yy').format(_startDate!) : '--/--/--',
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime.now(),
                                  );
                                  if (date != null) setState(() => _startDate = date);
                                },
                              ),
                              const SizedBox(height: 12),
                              _DateRow(
                                label: l10n.finish,
                                date: _endDate != null ? DateFormat('dd/MM/yy').format(_endDate!) : '--/--/--',
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime.now(),
                                  );
                                  if (date != null) setState(() => _endDate = date);
                                },
                              ),
                            ],
                          ),
                        ),

                        Container(
                          height: 80,
                          width: 1,
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          color: AppColors.white.withOpacity(0.1),
                        ),

                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.selectTimeRange,
                                style: TextStyle(
                                  color: AppColors.white.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _RangeDropdown(
                                value: _selectedRange ?? '3m',
                                options: rangeOptions,
                                onChanged: (val) => setState(() => _selectedRange = val),
                              ),
                            ],
                          ),
                        ),
                      ],
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

  const _RangeDropdown({required this.value, required this.options, required this.onChanged});

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
              .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
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

  const _GenerateButton({required this.label, required this.onPressed, required this.isLoading});

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
        height: 18, width: 18,
        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.greenEmerald),
      )
          : Text(
        label,
        style: const TextStyle(color: AppColors.greenEmerald, fontWeight: FontWeight.bold),
      ),
    );
  }
}