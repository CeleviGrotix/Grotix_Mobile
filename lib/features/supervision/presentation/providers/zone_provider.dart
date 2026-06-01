import 'package:flutter/material.dart';
import '../../application/services/zone_service.dart';
import '../../domain/entities/zone.dart';

enum ZoneSortOption { nameAz, nameZa, phaseDateNewest, phaseDateOldest }

class ZoneProvider extends ChangeNotifier {
  final ZoneService _zoneService;

  ZoneProvider(this._zoneService);

  List<Zone> _zones = [];
  List<Zone> _filteredZones = [];
  bool _isLoading = false;
  String _errorMessage = '';
  String _searchQuery = '';
  ZoneSortOption _sortOption = ZoneSortOption.nameAz;
  ZonePhase? _phaseFilter;

  // Getters
  List<Zone> get zones => _filteredZones;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  ZoneSortOption get sortOption => _sortOption;
  ZonePhase? get phaseFilter => _phaseFilter;

  /// Carga inicial de zonas (normalmente asociada a una Farm específica)
  Future<void> loadZones(int farmId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // Usamos el servicio que conecta con el repositorio e implementación
      _zones = await _zoneService.getZonesByFarm(farmId);
      _applyFilters();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Filtra las zonas por nombre localmente para mayor velocidad de UI
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

  void _applyFilters() {
    // 1. Filtrar por búsqueda
    Iterable<Zone> results = _zones.where((z) =>
        z.displayName.toLowerCase().contains(_searchQuery.toLowerCase()));

    // 2. Filtrar por Fase (si hay una seleccionada)
    if (_phaseFilter != null) {
      results = results.where((z) => z.phase == _phaseFilter);
    }

    // 3. Ordenar
    List<Zone> sortedList = results.toList();
    switch (_sortOption) {
      case ZoneSortOption.nameAz:
        sortedList.sort((a, b) => a.displayName.compareTo(b.displayName));
        break;
      case ZoneSortOption.nameZa:
        sortedList.sort((a, b) => b.displayName.compareTo(a.displayName));
        break;
      case ZoneSortOption.phaseDateNewest:
        sortedList.sort((a, b) => (b.phaseStartDate ?? DateTime(0))
            .compareTo(a.phaseStartDate ?? DateTime(0)));
        break;
      case ZoneSortOption.phaseDateOldest:
        sortedList.sort((a, b) => (a.phaseStartDate ?? DateTime(0))
            .compareTo(b.phaseStartDate ?? DateTime(0)));
        break;
    }

    _filteredZones = sortedList;
    notifyListeners();
  }
}