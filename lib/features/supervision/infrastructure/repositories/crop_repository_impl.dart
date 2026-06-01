import 'dart:convert';

import '../../domain/entities/crop.dart';
import '../../domain/repositories/crop_repository.dart';
import '../datasource/crop_datasource.dart';


class CropRepositoryImpl implements CropRepository {
  final CropRemoteDatasource _ds;
  const CropRepositoryImpl(this._ds);

  @override
  Future<List<Crop>> getAll() async {
    final res = await _ds.getAll();
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final raw = jsonDecode(res.body) as List<dynamic>;
      return raw
          .map((e) => Crop.fromMap(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('HTTP ${res.statusCode}: ${res.reasonPhrase}');
  }

  @override
  Future<Crop> getById(int cropId) async {
    final res = await _ds.getById(cropId);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return Crop.fromMap(jsonDecode(res.body) as Map<String, dynamic>);
    }
    throw Exception('HTTP ${res.statusCode}: ${res.reasonPhrase}');
  }
}