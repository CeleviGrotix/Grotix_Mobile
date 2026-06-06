import 'package:flutter/material.dart';
import '../../domain/entities/member.dart';
import '../../infrastructure/datasource/members_datasource.dart';

class MembersProvider extends ChangeNotifier {
  final MembersRemoteDatasource _datasource;

  MembersProvider({required MembersRemoteDatasource datasource})
      : _datasource = datasource;

  // ── Estado ────────────────────────────────────────────────────────────────

  List<ZoneMember> _zoneMembers = [];
  List<ZoneMember> _associationMembers = [];
  Set<int> _zoneMemberIds = {}; // para lookup O(1) de "¿está en zona?"
  bool _isLoading = false;
  String? _errorMessage;
  final Set<int> _pendingIds = {}; // usuarios en proceso de add/remove

  int? _currentZoneId;
  int? _currentAssociationId;

  // ── Getters ───────────────────────────────────────────────────────────────

  List<ZoneMember> get zoneMembers => _zoneMembers;
  List<ZoneMember> get associationMembers => _associationMembers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool isInZone(int userId) => _zoneMemberIds.contains(userId);
  bool isPending(int userId) => _pendingIds.contains(userId);

  // ── Carga ─────────────────────────────────────────────────────────────────

  /// Para user_admin: carga miembros de la asociación + miembros de zona
  Future<void> loadForAdmin({
    required int zoneId,
    required int associationId,
  }) async {
    _currentZoneId = zoneId;
    _currentAssociationId = associationId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _datasource.getZoneMembers(zoneId),
        _datasource.getAssociationMembers(associationId),
      ]);

      _zoneMembers = results[0] as List<ZoneMember>;
      _associationMembers = results[1] as List<ZoneMember>;
      _zoneMemberIds = _zoneMembers.map((m) => m.userId).toSet();
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('🔴 [MembersProvider] loadForAdmin error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Para demás roles: solo miembros de zona
  Future<void> loadZoneMembers(int zoneId) async {
    _currentZoneId = zoneId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _zoneMembers = await _datasource.getZoneMembers(zoneId);
      _zoneMemberIds = _zoneMembers.map((m) => m.userId).toSet();
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('🔴 [MembersProvider] loadZoneMembers error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Mutaciones ────────────────────────────────────────────────────────────

  Future<void> addMember(int userId) async {
    if (_currentZoneId == null) return;
    _pendingIds.add(userId);
    notifyListeners();

    try {
      await _datasource.addZoneMember(_currentZoneId!, userId);
      _zoneMemberIds.add(userId);

      // Agrega a zoneMembers desde associationMembers para actualizar UI
      final assocMember = _associationMembers
          .where((m) => m.userId == userId)
          .firstOrNull;
      if (assocMember != null) {
        _zoneMembers = [
          ..._zoneMembers,
          ZoneMember(
            userId: assocMember.userId,
            name: assocMember.name,
            email: assocMember.email,
            roleId: assocMember.roleId,
            roleName: assocMember.roleName,
            assignedAt: DateTime.now(),
          ),
        ];
      }
    } catch (e) {
      debugPrint('🔴 [MembersProvider] addMember error: $e');
    } finally {
      _pendingIds.remove(userId);
      notifyListeners();
    }
  }

  Future<void> removeMember(int userId) async {
    if (_currentZoneId == null) return;
    _pendingIds.add(userId);
    notifyListeners();

    try {
      await _datasource.removeZoneMember(_currentZoneId!, userId);
      _zoneMemberIds.remove(userId);
      _zoneMembers =
          _zoneMembers.where((m) => m.userId != userId).toList();
    } catch (e) {
      debugPrint('🔴 [MembersProvider] removeMember error: $e');
    } finally {
      _pendingIds.remove(userId);
      notifyListeners();
    }
  }
}