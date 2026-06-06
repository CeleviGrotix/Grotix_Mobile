import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grotix/common/theme/app_colors.dart';
import 'package:grotix/common/utils/app_icons.dart';
import 'package:grotix/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/member.dart';
import '../providers/dashboard_provider.dart';
import '../providers/members_provider.dart';

class PeopleTabView extends StatefulWidget {
  final AppLocalizations l10n;
  final int? userRoleId;
  final int? associationId;

  const PeopleTabView({
    super.key,
    required this.l10n,
    this.userRoleId,
    this.associationId,
  });

  @override
  State<PeopleTabView> createState() => _PeopleTabViewState();
}

class _PeopleTabViewState extends State<PeopleTabView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  bool get _isAdmin => widget.userRoleId != null && widget.userRoleId! <= 3;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final zone = context.read<DashboardProvider>().selectedZone;
    if (zone == null) return;

    final provider = context.read<MembersProvider>();
    if (_isAdmin && widget.associationId != null) {
      await provider.loadForAdmin(
        zoneId: zone.id,
        associationId: widget.associationId!,
      );
    } else {
      await provider.loadZoneMembers(zone.id);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MembersProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Buscador
        Container(
          height: 44,
          decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(8)),
          child: TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _searchQuery = v),
            style: const TextStyle(color: AppColors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: widget.l10n.searchPeople,
              hintStyle: TextStyle(
                  color: AppColors.white.withOpacity(0.35), fontSize: 14),
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: FaIcon(AppIcons.search,
                    size: 16, color: AppColors.white.withOpacity(0.4)),
              ),
              prefixIconConstraints:
              const BoxConstraints(minWidth: 40, minHeight: 0),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
        const SizedBox(height: 16),

        if (provider.isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: CircularProgressIndicator(color: AppColors.greenEmerald),
            ),
          )
        else if (_isAdmin)
          _AdminView(
            l10n: widget.l10n,
            provider: provider,
            searchQuery: _searchQuery,
          )
        else
          _MemberView(
            l10n: widget.l10n,
            members: _filterZoneMembers(provider.zoneMembers),
          ),
      ],
    );
  }

  List<ZoneMember> _filterZoneMembers(List<ZoneMember> list) {
    if (_searchQuery.isEmpty) return list;
    return list
        .where((m) =>
        m.displayName.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }
}

// ─── Vista para user_admin: todos los de la asociación con Add/Remove ─────────

class _AdminView extends StatelessWidget {
  final AppLocalizations l10n;
  final MembersProvider provider;
  final String searchQuery;

  const _AdminView({
    required this.l10n,
    required this.provider,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    final filtered = searchQuery.isEmpty
        ? provider.associationMembers
        : provider.associationMembers
        .where((m) => m.displayName
        .toLowerCase()
        .contains(searchQuery.toLowerCase()))
        .toList();

    if (filtered.isEmpty) {
      return _EmptyState(message: l10n.noZonesFound);
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final member = filtered[i];
        final inZone = provider.isInZone(member.userId);
        final isPending = provider.isPending(member.userId);

        return _MemberCard(
          name: member.displayName,
          role: member.roleName,
          inZone: inZone,
          isPending: isPending,
          profilePicture: member.profilePicture,
          onTap: isPending
              ? null
              : () => inZone
              ? provider.removeMember(member.userId)
              : provider.addMember(member.userId),
          addLabel: l10n.invite,
          removeLabel: l10n.remove,
        );
      },
    );
  }
}

// ─── Vista para demás roles: solo miembros de la zona ─────────────────────────

class _MemberView extends StatelessWidget {
  final AppLocalizations l10n;
  final List<ZoneMember> members;

  const _MemberView({required this.l10n, required this.members});

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) {
      return _EmptyState(message: l10n.noZonesFound);
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: members.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _MemberCard(
        name: members[i].displayName,
        role: members[i].roleName,
        inZone: true,
        isPending: false,
        onTap: null,
        profilePicture: members[i].profilePicture,
      ),
    );
  }
}

// ─── Card reutilizable ────────────────────────────────────────────────────────

class _MemberCard extends StatelessWidget {
  final String name;
  final String role;
  final bool inZone;
  final bool isPending;
  final VoidCallback? onTap;
  final String? addLabel;
  final String? removeLabel;
  final String? profilePicture;

  const _MemberCard({
    required this.name,
    required this.role,
    required this.inZone,
    required this.isPending,
    this.onTap,
    this.addLabel,
    this.removeLabel,
    this.profilePicture,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: AppColors.darkCardBg,
          borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.white10,
            backgroundImage: profilePicture != null
                ? NetworkImage(profilePicture!)
                : null,
            child: profilePicture == null
                ? Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold)),
                Text(role,
                    style: const TextStyle(
                        color: Colors.white60, fontSize: 13)),
              ],
            ),
          ),
          if (onTap != null)
            isPending
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.greenEmerald),
            )
                : TextButton(
              onPressed: onTap,
              style: TextButton.styleFrom(
                foregroundColor: inZone
                    ? AppColors.redCoral
                    : AppColors.greenEmerald,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                inZone
                    ? (removeLabel ?? 'Remove')
                    : (addLabel ?? 'Add'),
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 13),
              ),
            )
          else if (inZone)
            const FaIcon(FontAwesomeIcons.circleCheck,
                size: 16, color: AppColors.greenEmerald),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Text(message,
            style: TextStyle(
                color: AppColors.white.withOpacity(0.4), fontSize: 14)),
      ),
    );
  }
}