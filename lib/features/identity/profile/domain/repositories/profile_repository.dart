import '../entities/user_profile.dart';

abstract class ProfileRepository {
  /// Devuelve el perfil del usuario autenticado.
  Future<UserProfile> getMe();

  /// Actualiza nombre, taxId, phone y/o profilePicture.
  Future<UserProfile> updateProfile({
    required int userId,
    String? name,
    String? taxId,
    String? phone,
    String? profilePicture,
  });

  /// Actualiza preferencias del usuario (idioma, notificaciones, etc).
  Future<void> updatePreferences({
    required int userId,
    required Map<String, dynamic> preferences,
  });

  /// Lista de notificaciones del usuario autenticado.
  Future<List<Map<String, dynamic>>> getNotifications();

  Future<int> getUnreadNotificationCount();

  Future<void> markNotificationRead(int notificationId);

  Future<void> markAllNotificationsRead();
}