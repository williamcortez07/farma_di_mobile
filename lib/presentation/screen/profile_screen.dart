import 'package:flutter/material.dart';
import 'package:farma_di_mobile/core/di/injection.dart';
import 'package:farma_di_mobile/data/models/auth_model/user_model.dart';
import 'package:farma_di_mobile/presentation/controllers/profile_controller.dart';
import 'package:farma_di_mobile/presentation/theme/app_colors.dart';
import 'package:farma_di_mobile/presentation/widgets/notification_widget.dart';
import 'package:farma_di_mobile/presentation/widgets/profile/change_password_sheet.dart';
import 'package:farma_di_mobile/presentation/widgets/profile/edit_profile_sheet.dart';
import 'package:farma_di_mobile/presentation/widgets/profile/profile_header_card.dart';
import 'package:farma_di_mobile/presentation/widgets/profile/profile_info_card.dart';
import 'package:farma_di_mobile/presentation/widgets/profile/profile_logout_card.dart';
import 'package:farma_di_mobile/presentation/widgets/profile/profile_role_card.dart';
import 'package:farma_di_mobile/presentation/widgets/profile/profile_security_card.dart';
import 'package:farma_di_mobile/presentation/widgets/routes.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileController _controller;

  @override
  void initState() {
    super.initState();
    _controller = getIt<ProfileController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadProfile();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Cerrar sesión',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryDark,
          ),
        ),
        content: const Text(
          '¿Estás seguro de que deseas salir de tu cuenta? Se cerrará la sesión actual.',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    await _controller.logout();
    if (!mounted) return;

    NotificationWidget.show(
      context,
      type: NotificationType.cancellation,
      message: 'Sesión finalizada correctamente.',
    );

    Navigator.of(context)
        .pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
  }

  void _showEditProfileModal(UserModel user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) =>
          EditProfileSheet(user: user, profileController: _controller),
    );
  }

  void _showChangePasswordModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ChangePasswordSheet(profileController: _controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryDark),
          tooltip: 'Regresar',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Mi Perfil',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryDark,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            tooltip: 'Actualizar perfil',
            onPressed: () => _controller.loadProfile(forceRefresh: true),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isLoading && _controller.user == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16),
                  Text(
                    'Cargando perfil...',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          final user = _controller.user;

          if (user == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.person_off_outlined,
                      size: 60,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _controller.errorMessage ??
                          'No se pudo cargar la información del usuario.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () =>
                          _controller.loadProfile(forceRefresh: true),
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Reintentar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => _controller.loadProfile(forceRefresh: true),
            color: AppColors.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ProfileHeaderCard(user: user),
                  const SizedBox(height: 16),
                  ProfileInfoCard(
                    user: user,
                    onEdit: () => _showEditProfileModal(user),
                  ),
                  const SizedBox(height: 16),
                  ProfileRoleCard(user: user),
                  const SizedBox(height: 16),
                  ProfileSecurityCard(
                    onChangePassword: _showChangePasswordModal,
                  ),
                  const SizedBox(height: 24),
                  ProfileLogoutCard(onLogout: _handleLogout),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
