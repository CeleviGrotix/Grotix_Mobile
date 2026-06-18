import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../application/services/crop_service.dart';
import '../../application/services/farm_service.dart';
import '../../application/services/zone_service.dart';
import '../../domain/entities/farm.dart';
import '../../domain/entities/zone.dart';

import '../../../intelligence/infrastructure/datasource/ai_remote_datasource.dart';

enum ZoneSortOption { nameAz, nameZa, phaseDateNewest, phaseDateOldest }

class ZoneProvider extends ChangeNotifier {
  final ZoneService _zoneService;
  final FarmService _farmService;
  final CropService _cropService;

  final AiRemoteDatasource _aiDatasource = AiRemoteDatasource();

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
  final Set<int> _pendingIrrigationToggles = {};

  Map<String, dynamic>? _lastAiResult;
  Map<String, dynamic>? get lastAiResult => _lastAiResult;

  // ── Getters ───────────────────────────────────────────────────────────────

  Farm? get currentFarm => _currentFarm;
  List<Zone> get zones => _filteredZones;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  ZoneSortOption get sortOption => _sortOption;
  ZonePhase? get phaseFilter => _phaseFilter;
  bool get hasError => _errorMessage.isNotEmpty;
  bool isTogglingIrrigation(int zoneId) => _pendingIrrigationToggles.contains(zoneId);


  // ── Funciones Auxiliares (SharedPreferences) ──────────────────────────────

  /// Revisa la memoria del teléfono y le inyecta las observaciones Y EL SCORE guardados
  Future<List<Zone>> _applySavedAiData(List<Zone> inputZones) async {
    final prefs = await SharedPreferences.getInstance();
    return inputZones.map((z) {
      final savedObs = prefs.getString('obs_zone_${z.id}');
      final savedScore = prefs.getInt('score_zone_${z.id}');

      // Si tenemos alguno de los dos datos guardados, se los inyectamos a la zona
      if (savedObs != null || savedScore != null) {
        return z.copyWith(
          aiObservaciones: savedObs ?? z.aiObservaciones,
          healthScore: savedScore ?? z.healthScore,
        );
      }
      return z;
    }).toList();
  }

  // ── Carga ─────────────────────────────────────────────────────────────────

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
      final enrichedZones = _zoneService.enrichWithCrops(rawZones, cropMap);

      _zones = await _applySavedAiData(enrichedZones);

      _applyFilters();
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('🔴 [ZoneProvider] loadFromAssociation error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    if (_currentFarm == null) return;
    await loadZones(_currentFarm!.id);
  }

  Future<void> loadZones(int farmId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final rawZones = await _zoneService.getZonesByFarm(farmId);
      final cropMap = await _cropService.getCropMap();
      final enrichedZones = _zoneService.enrichWithCrops(rawZones, cropMap);

      _zones = await _applySavedAiData(enrichedZones);

      _applyFilters();
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('🔴 [ZoneProvider] loadZones error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Filtros ───────────────────────────────────────────────────────────────

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

  // ── IA ────────────────────────────────────────────────────────────────────

  ZonePhase _mapAiStatusToPhase(String aiStatus) {
    switch (aiStatus.toLowerCase()) {
      case 'seed': return ZonePhase.seed;
      case 'germination': return ZonePhase.germination;
      case 'vegetative': return ZonePhase.vegetative;
      case 'flowering': return ZonePhase.flowering;
      case 'fruiting': return ZonePhase.fruiting;
      case 'harvest': return ZonePhase.harvest;
      case 'unknown': return ZonePhase.unknown;
      default: return ZonePhase.unknown;
    }
  }

  Future<Map<String, dynamic>?> analyzeZoneWithAi(
      int zoneId, String imagePath) async {
    try {
      final aiResult = await _aiDatasource.analyzeCropImage(imagePath);

      final String estado = aiResult['estado_germinacion'] ?? 'unknown';
      final int score = (aiResult['health_score'] as num?)?.toInt() ?? 0;
      final String observaciones = aiResult['observaciones'] ?? '';

      debugPrint('✅ IA: Estado=$estado | Score=$score | Obs=$observaciones');

      _lastAiResult = aiResult;

      // 1. Guardamos silenciosamente las observaciones Y EL SCORE en el teléfono
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('obs_zone_$zoneId', observaciones);
      await prefs.setInt('score_zone_$zoneId', score); // <- AQUÍ ESTÁ LA MAGIA

      // 2. Actualizamos la memoria RAM (Flutter)
      _zones = _zones.map((z) {
        if (z.id == zoneId) {
          return z.copyWith(
            currentPhase: estado.toUpperCase(),
            phaseStartDate: DateTime.now(),
            healthScore: score,
            aiObservaciones: observaciones,
          );
        }
        return z;
      }).toList();

      _applyFilters();

      // 3. Guardamos el REPORTE DE ANÁLISIS en Azure
      final reportSuccess = await _zoneService.createAnalysisReport(
          zoneId,
          estado.toUpperCase(),
          score
      );
      if (!reportSuccess) {
        debugPrint('🔴 Falló al guardar el reporte de análisis en C#.');
      }

      // 4. Guardamos la FASE PRINCIPAL en Azure
      final newPhase = _mapAiStatusToPhase(estado);
      final phaseSuccess = await updateZonePhase(zoneId, newPhase);

      if (!phaseSuccess) {
        debugPrint('🔴 Falló al actualizar la fase principal en C#.');
      }

      return aiResult;
    } catch (e) {
      debugPrint('🔴 [ZoneProvider] analyzeZoneWithAi error: $e');
      _errorMessage = 'Error de IA: $e';
      notifyListeners();
      return null;
    }
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
      final enrichedList = _zoneService.enrichWithCrops([updated], cropMap);

      final enrichedWithAiData = await _applySavedAiData(enrichedList);
      final finalZone = enrichedWithAiData.first;

      _zones = _zones.map((z) => z.id == zoneId ? finalZone : z).toList();
      _applyFilters();
    } catch (e) {
      debugPrint('🔴 [ZoneProvider] refreshZone error: $e');
    }
  }

  Future<bool> updateZonePhase(int zoneId, ZonePhase newPhase) async {
    try {
      final updated = await _zoneService.updatePhase(zoneId, newPhase);
      if (updated == null) return false;

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

  Future<void> updateIrrigationMode(int zoneId, IrrigationMode mode) async {
    if (_pendingIrrigationToggles.contains(zoneId)) return;

    final zoneIndex = _zones.indexWhere((z) => z.id == zoneId);
    if (zoneIndex == -1) return;

    final previousZone = _zones[zoneIndex];
    if (previousZone.mode == mode) return; // ya está en ese modo, no-op

    _pendingIrrigationToggles.add(zoneId);
    _zones = List.of(_zones)
      ..[zoneIndex] = previousZone.copyWith(irrigationMode: mode.label);
    _applyFilters();

    try {
      await _zoneService.updateIrrigationMode(zoneId, mode);
    } catch (e) {
      final rollbackIndex = _zones.indexWhere((z) => z.id == zoneId);
      if (rollbackIndex != -1) {
        _zones = List.of(_zones)..[rollbackIndex] = previousZone;
        _applyFilters();
      }
      debugPrint('🔴 [ZoneProvider] updateIrrigationMode error: $e');
      rethrow;
    } finally {
      _pendingIrrigationToggles.remove(zoneId);
    }
  }
}