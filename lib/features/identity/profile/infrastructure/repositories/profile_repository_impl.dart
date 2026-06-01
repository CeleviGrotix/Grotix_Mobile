import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasource/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDatasource remoteDataSource;

  ProfileRepositoryImpl(this.remoteDataSource);

  @override
  Future<UserProfile> getMe() async {
    return await remoteDataSource.getMe();
  }

  @override
  Future<UserProfile> updateProfile({
    required int userId,
    String? name,
    String? taxId,
    String? phone,
    String? profilePicture,
  }) async {
    return await remoteDataSource.updateProfile(
      userId: userId,
      name: name,
      taxId: taxId,
      phone: phone,
      profilePicture: profilePicture
    );
  }

  @override
  Future<void> updatePreferences({
    required int userId,
    required Map<String, dynamic> preferences,
  }) async {
    await remoteDataSource.updatePreferences(userId: userId, preferences: preferences);
  }

  @override
  Future<List<Map<String, dynamic>>> getNotifications() async {
    return await remoteDataSource.getNotifications();
  }

  @override
  Future<int> getUnreadNotificationCount() async {
    return await remoteDataSource.getUnreadNotificationCount();
  }

  @override
  Future<void> markNotificationRead(int notificationId) async {
    await remoteDataSource.markNotificationRead(notificationId);
  }

  @override
  Future<void> markAllNotificationsRead() async {
    await remoteDataSource.markAllNotificationsRead();
  }

}