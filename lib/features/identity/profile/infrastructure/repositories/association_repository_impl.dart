import '../../domain/entities/association.dart';
import '../../domain/repositories/association_repository.dart';
import '../datasource/association_datasource.dart';

class AssociationRepositoryImpl implements AssociationRepository {
  final AssociationRemoteDatasource remoteDataSource;

  AssociationRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Association>> getAssociations() async {
    return await remoteDataSource.getAssociations();
  }

  @override
  Future<Association> getMyAssociation() async {
    return await remoteDataSource.getMyAssociation();
  }

  @override
  Future<Association> createAssociation({
    required String name,
    required String email,
  }) async {
    return await remoteDataSource.createAssociation(
      name: name,
      email: email,
    );
  }

  @override
  Future<Association> getAssociationById(int associationId) async {
    return await remoteDataSource.getAssociationById(associationId);
  }

  @override
  Future<Association> updateAssociation({
    required int associationId,
    String? name,
    String? email,
  }) async {
    return await remoteDataSource.updateAssociation(
      associationId: associationId,
      name: name,
      email: email,
    );
  }
}