import 'package:flutter/material.dart';

import '../../application/services/crop_service.dart';
import '../../application/services/farm_service.dart';
import '../../application/services/zone_service.dart';
import '../../domain/entities/farm.dart';
import '../../domain/entities/zone.dart';

enum ZoneSortOption { nameAz, nameZa, phaseDateNewest, phaseDateOldest }

class ZoneProvider extends ChangeNotifier {
  final ZoneService _zoneService;
  final FarmService _farmService;
  final CropService _cropService;

  ZoneProvider({
    required ZoneService zoneService,
    required FarmService farmService,
    required CropService cropService,
  })  : _zoneService = zoneService,
        _farmService = farmService,
        _cropService = cropService;

  // ── Estado ────────────────────────────────────────────────────────────────

  Farm? _currentFarm;
  List<Zone> _zones = [];
  List<Zone> _filteredZones = [];
  bool _isLoading = false;
  String _errorMessage = '';
  String _searchQuery = '';
  ZoneSortOption _sortOption = ZoneSortOption.nameAz;
  ZonePhase? _phaseFilter;

  // ── Getters ───────────────────────────────────────────────────────────────

  Farm? get currentFarm => _currentFarm;
  List<Zone> get zones => _filteredZones;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  ZoneSortOption get sortOption => _sortOption;
  ZonePhase? get phaseFilter => _phaseFilter;
  bool get hasError => _errorMessage.isNotEmpty;

  // ── Carga: association → farm → zones ────────────────────────────────────

  /// Recibe el associationId del usuario loggeado (viene del ProfileProvider).
  Future<void> loadFromAssociation(int associationId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final allFarms = await _farmService.getAllFarms();
      final farm = allFarms.firstWhere(
            (f) => f.associationId == associationId,
        orElse: () => throw Exception('No farm found for this association'),
      );
      _currentFarm = farm;

      final rawZones = await _zoneService.getZonesByFarm(farm.id);

      final cropMap = await _cropService.getCropMap();
      _zones = _zoneService.enrichWithCrops(rawZones, cropMap);

      _applyFilters();
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('🔴 [ZoneProvider] loadFromAssociation error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Recarga sin cambiar el associationId (útil para pull-to-refresh)
  Future<void> refresh() async {
    if (_currentFarm == null) return;
    await loadZones(_currentFarm!.id);
  }

  /// Carga directa por farmId (si ya la tienes)
  Future<void> loadZones(int farmId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final rawZones = await _zoneService.getZonesByFarm(farmId);
      final cropMap = await _cropService.getCropMap();
      _zones = _zoneService.enrichWithCrops(rawZones, cropMap);
      _applyFilters();
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('🔴 [ZoneProvider] loadZones error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Filtros y ordenamiento ────────────────────────────────────────────────

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void setSortOption(ZoneSortOption option) {
    _sortOption = option;
    _applyFilters();
  }

  void setPhaseFilter(ZonePhase? phase) {
    _phaseFilter = phase;
    _applyFilters();
  }

  void clearFilters() {
    _searchQuery = '';
    _phaseFilter = null;
    _sortOption = ZoneSortOption.nameAz;
    _applyFilters();
  }

  void _applyFilters() {
    Iterable<Zone> results = _zones.where((z) =>
        z.displayName.toLowerCase().contains(_searchQuery.toLowerCase()));

    if (_phaseFilter != null) {
      results = results.where((z) => z.phase == _phaseFilter);
    }

    List<Zone> sorted = results.toList();
    switch (_sortOption) {
      case ZoneSortOption.nameAz:
        sorted.sort((a, b) => a.displayName.compareTo(b.displayName));
      case ZoneSortOption.nameZa:
        sorted.sort((a, b) => b.displayName.compareTo(a.displayName));
      case ZoneSortOption.phaseDateNewest:
        sorted.sort((a, b) => (b.phaseStartDate ?? DateTime(0))
            .compareTo(a.phaseStartDate ?? DateTime(0)));
      case ZoneSortOption.phaseDateOldest:
        sorted.sort((a, b) => (a.phaseStartDate ?? DateTime(0))
            .compareTo(b.phaseStartDate ?? DateTime(0)));
    }

    _filteredZones = sorted;
    notifyListeners();
  }

  // ── Mutaciones ────────────────────────────────────────────────────────────

  Future<bool> createZone({
    required int cropId,
    required ZonePhase phase,
    String? imageUrl,
  }) async {
    if (_currentFarm == null) return false;

    try {
      final newZone = await _zoneService.createZone(
        farmId: _currentFarm!.id,
        cropId: cropId,
        phase: phase,
        imageUrl: imageUrl,
      );
      if (newZone == null) return false;

      // Enriquecer la nueva zona con su crop antes de agregarla
      final cropMap = await _cropService.getCropMap();
      final enriched = _zoneService.enrichWithCrops([newZone], cropMap);
      _zones = [..._zones, ...enriched];
      _applyFilters();
      return true;
    } catch (e) {
      debugPrint('🔴 [ZoneProvider] createZone error: $e');
      return false;
    }
  }

  Future<bool> updateZoneFields(
      int zoneId, {
        double? latitude,
        double? longitude,
        String? imageUrl,
      }) async {
    try {
      final data = <String, dynamic>{
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (imageUrl != null) 'imageUrl': imageUrl,
      };
      if (data.isEmpty) return true;

      await _zoneService.updateZone(zoneId, data);

      _zones = _zones.map((z) {
        if (z.id == zoneId) {
          return z.copyWith(
            latitude: latitude ?? z.latitude,
            longitude: longitude ?? z.longitude,
            imageUrl: imageUrl ?? z.imageUrl,
          );
        }
        return z;
      }).toList();
      _applyFilters();
      return true;
    } catch (e) {
      debugPrint('🔴 [ZoneProvider] updateZoneFields error: $e');
      return false;
    }
  }

  Future<void> refreshZone(int zoneId) async {
    try {
      final updated = await _zoneService.getZoneDetails(zoneId);
      if (updated == null) return;
      final cropMap = await _cropService.getCropMap();
      final enriched = _zoneService.enrichWithCrops([updated], cropMap).first;
      _zones = _zones.map((z) => z.id == zoneId ? enriched : z).toList();
      _applyFilters();
    } catch (e) {
      debugPrint("🔴 [ZoneProvider] refreshZone error: $e");
    }
  }

  Future<bool> updateZonePhase(int zoneId, ZonePhase newPhase) async {
    try {
      final updated = await _zoneService.updatePhase(zoneId, newPhase);
      if (updated == null) return false;

      // Actualiza localmente sin recargar todo
      _zones = _zones.map((z) {
        if (z.id == zoneId) {
          return z.copyWith(
            currentPhase: newPhase.label,
            phaseStartDate: DateTime.now(),
          );
        }
        return z;
      }).toList();
      _applyFilters();
      return true;
    } catch (e) {
      debugPrint('🔴 [ZoneProvider] updateZonePhase error: $e');
      return false;
    }
  }
}