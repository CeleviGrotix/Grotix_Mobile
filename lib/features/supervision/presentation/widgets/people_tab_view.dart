import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grotix/common/theme/app_colors.dart';
import 'package:grotix/l10n/app_localizations.dart';
import '../../../../common/utils/app_icons.dart';

class PeopleTabView extends StatefulWidget {
  final AppLocalizations l10n;

  const PeopleTabView({super.key, required this.l10n});

  @override
  State<PeopleTabView> createState() => _PeopleTabViewState();
}

class _PeopleTabViewState extends State<PeopleTabView> {
  late List<Map<String, dynamic>> _allStaff;
  List<Map<String, dynamic>> _filteredStaff = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Inicializamos la data fake
    _allStaff = [
      {'name': 'Tomio Nakamurakare', 'role': widget.l10n.agriculturist, 'isAdded': true},
      {'name': 'Cassius Martel', 'role': widget.l10n.agriculturist, 'isAdded': false},
      {'name': 'Pedro Choquehuanca', 'role': widget.l10n.agriculturist, 'isAdded': false},
    ];
    _filteredStaff = _allStaff;
  }

  void _filterPeople(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredStaff = _allStaff;
      } else {
        _filteredStaff = _allStaff
            .where((person) => person['name']
            .toLowerCase()
            .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Buscador
        Container(
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: _filterPeople,
            style: const TextStyle(color: AppColors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: widget.l10n.searchPeople,
              hintStyle: TextStyle(
                color: AppColors.white.withOpacity(0.35),
                fontSize: 14,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: FaIcon(
                  AppIcons.search,
                  size: 16,
                  color: AppColors.white.withOpacity(0.4),
                ),
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
        const SizedBox(height: 16),

        // Lista de Personal
        _filteredStaff.isEmpty
            ? Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Text(
            widget.l10n.noZonesFound, // Podrías agregar "noPeopleFound" en tu ARB
            style: TextStyle(color: AppColors.white.withOpacity(0.4)),
          ),
        )
            : ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _filteredStaff.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final person = _filteredStaff[i];
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.darkCardBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white10,
                    child: Icon(
                      Icons.person,
                      color: AppColors.white.withOpacity(0.4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          person['name'],
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          person['role'],
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Acción para invitar/eliminar
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: person['isAdded']
                          ? AppColors.redCoral
                          : AppColors.greenEmerald,
                    ),
                    child: Text(
                      person['isAdded']
                          ? widget.l10n.remove
                          : widget.l10n.invite,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}