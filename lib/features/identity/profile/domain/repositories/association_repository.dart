import '../entities/association.dart';

abstract class AssociationRepository {
  /// Obtiene la lista de todas las asociaciones.
  Future<List<Association>> getAssociations();

  /// Crea una nueva asociación.
  Future<Association> createAssociation({
    required String name,
    required String email,
  });

  /// Obtiene la asociación del usuario loggeado
  Future<Association> getMyAssociation();

  /// Obtiene el detalle de una asociación específica por su ID.
  Future<Association> getAssociationById(int associationId);

  /// Actualiza los datos de una asociación existente.
  Future<Association> updateAssociation({
    required int associationId,
    String? name,
    String? email,
  });
}