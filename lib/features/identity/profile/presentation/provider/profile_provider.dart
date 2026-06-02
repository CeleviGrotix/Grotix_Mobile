import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:grotix/common/theme/app_colors.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../domain/entities/association.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/association_repository.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _repository;
  final AssociationRepository _associationRepository;

  ProfileProvider({
    required ProfileRepository repository,
    required AssociationRepository associationRepository,
  })  : _repository = repository,
        _associationRepository = associationRepository;

  // ── Estado ───────────────────────────────────────────────────────────────

  Association? _association;
  Association? get association => _association;
  String get associationName => _association?.name ?? '—';
  UserProfile? _user;
  List<Map<String, dynamic>> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  bool _isEditing = false;
  String? _errorMessage;

  // Controllers para edición de perfil
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final taxIdController = TextEditingController();

  // ── Getters ──────────────────────────────────────────────────────────────

  UserProfile? get user => _user;
  List<Map<String, dynamic>> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  bool get isEditing => _isEditing;
  String? get errorMessage => _errorMessage;

  // ── Carga inicial ─────────────────────────────────────────────────────────

  Future<void> loadProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _repository.getMe();
      _fillControllers();

      // cargamos la asociación
      if (_user?.associationId != null) {
        await _loadAssociation();
      }
    } catch (e) {
      debugPrint('🔴 [ProfileProvider] loadProfile error: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadAssociation() async {
    try {
      final association = await _associationRepository.getMyAssociation();
      notifyListeners();
    } catch (e) {
      debugPrint('🔴 [ProfileProvider] loadAssociation error: $e');
    }
  }

  void _fillControllers() {
    if (_user == null) return;
    nameController.text = _user!.name ?? '';
    phoneController.text = _user!.phone ?? '';
    taxIdController.text = _user!.taxId ?? '';
  }

  // ── Edición ───────────────────────────────────────────────────────────────

  Future<bool> saveProfileChanges(BuildContext context) async {
    if (_user == null) return false;
    final l10n = AppLocalizations.of(context)!;

    _isLoading = true;
    notifyListeners();

    try {
      _user = await _repository.updateProfile(
        userId: _user!.id,
        name: nameController.text.trim().isEmpty ? null : nameController.text.trim(),
        phone: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
        taxId: taxIdController.text.trim().isEmpty ? null : taxIdController.text.trim(),
      );

      _isEditing = false;

      if (context.mounted) {
        _showSnackBar(context, l10n.profileUpdatedSuccess);
      }

      return true;
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, '${l10n.errorUpdatingProfile}: $e', isError: true);
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleEditing() {
    _isEditing = !_isEditing;
    if (!_isEditing) _fillControllers(); // descarta cambios al cancelar
    notifyListeners();
  }

  // ── Foto de perfil ────────────────────────────────────────────────────────

  Future<void> pickAndUploadProfilePicture(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 60,
      );

      if (image == null || _user == null) return;

      _isLoading = true;
      notifyListeners();

      final bytes = await File(image.path).readAsBytes();
      final base64String = 'data:image/jpeg;base64,${base64Encode(bytes)}';

      _user = await _repository.updateProfile(
        userId: _user!.id,
        profilePicture: base64String,
      );

      if (context.mounted) {
        _showSnackBar(context, l10n.profilePictureUpdated);
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, l10n.errorUpdatingPicture, isError: true);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Preferencias ──────────────────────────────────────────────────────────

  Future<void> updatePreferences(Map<String, dynamic> preferences) async {
    if (_user == null) return;

    try {
      // Quitamos el "_user =" porque el repo devuelve void
      await _repository.updatePreferences(
        userId: _user!.id,
        preferences: preferences,
      );

      // Actualizamos el estado localmente para que la UI reaccione
      _user = _user!.copyWith(preferences: preferences);
      notifyListeners();
    } catch (e) {
      debugPrint('🔴 [ProfileProvider] updatePreferences error: $e');
    }
  }

  // ── Helper para SnackBar ──────────────────────────────────────────────────

  void _showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : AppColors.greenEmerald,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── Notificaciones ────────────────────────────────────────────────────────

  Future<void> loadNotifications() async {
    try {
      _notifications = await _repository.getNotifications();
      notifyListeners();
    } catch (e) {
      debugPrint('🔴 [ProfileProvider] loadNotifications error: $e');
    }
  }

  Future<void> loadUnreadCount() async {
    try {
      _unreadCount = await _repository.getUnreadNotificationCount();
      notifyListeners();
    } catch (e) {
      debugPrint('🔴 [ProfileProvider] getUnreadCount error: $e');
    }
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      await _repository.markNotificationRead(notificationId);
      // Actualiza localmente sin hacer otro GET
      _notifications = _notifications.map((n) {
        if (n['id'] == notificationId) {
          return {...n, 'read': true};
        }
        return n;
      }).toList();
      if (_unreadCount > 0) _unreadCount--;
      notifyListeners();
    } catch (e) {
      debugPrint('🔴 [ProfileProvider] markAsRead error: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllNotificationsRead();
      _notifications = _notifications
          .map((n) => {...n, 'read': true})
          .toList();
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      debugPrint('🔴 [ProfileProvider] markAllAsRead error: $e');
    }
  }

  // ── Limpieza ──────────────────────────────────────────────────────────────

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    taxIdController.dispose();
    super.dispose();
  }
}