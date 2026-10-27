import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:farma_di_mobile/core/di/injection.dart';
import 'package:farma_di_mobile/data/models/auth_model/user_model.dart';
import 'package:farma_di_mobile/presentation/providers/user_provider.dart';
import 'package:farma_di_mobile/presentation/theme/app_colors.dart';
import 'package:farma_di_mobile/presentation/widgets/logout_button.dart';
import 'package:farma_di_mobile/presentation/widgets/notification_widget.dart';
import 'package:farma_di_mobile/presentation/widgets/routes.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final UserProvider _userProvider;

  @override
  void initState() {
    super.initState();
    _userProvider = getIt<UserProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _userProvider.loadProfile();
    });
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
            child: const Text('Cancelar', style: TextStyle(color: AppColors.textMuted)),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    await _userProvider.logout();
    if (!mounted) return;

    NotificationWidget.show(
      context,
      type: NotificationType.cancellation,
      message: 'Sesión finalizada correctamente.',
    );

    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
  }

  void _showEditProfileModal(UserModel user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => _EditProfileSheet(
        user: user,
        userProvider: _userProvider,
      ),
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
      builder: (sheetContext) => _ChangePasswordSheet(
        userProvider: _userProvider,
      ),
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
            onPressed: () => _userProvider.loadProfile(forceRefresh: true),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListenableBuilder(
        listenable: _userProvider,
        builder: (context, _) {
          if (_userProvider.isLoading && _userProvider.user == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16),
                  Text(
                    'Cargando perfil...',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                ],
              ),
            );
          }

          final user = _userProvider.user;

          if (user == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.person_off_outlined, size: 60, color: AppColors.textMuted),
                    const SizedBox(height: 16),
                    Text(
                      _userProvider.errorMessage ?? 'No se pudo cargar la información del usuario.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => _userProvider.loadProfile(forceRefresh: true),
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Reintentar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => _userProvider.loadProfile(forceRefresh: true),
            color: AppColors.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeaderCard(user),
                  const SizedBox(height: 16),
                  _buildPersonalInfoCard(user),
                  const SizedBox(height: 16),
                  _buildRoleCard(user),
                  const SizedBox(height: 16),
                  _buildSecurityCard(),
                  const SizedBox(height: 24),
                  _buildLogoutCard(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard(UserModel user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: AppColors.primarySoft,
            child: Text(
              user.initials,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.mail,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: user.isActive ? AppColors.successSoft : AppColors.redSoft,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            size: 7,
                            color: user.isActive ? AppColors.success : AppColors.red,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            user.isActive ? 'Cuenta Activa' : 'Cuenta Inactiva',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: user.isActive ? AppColors.success : AppColors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoCard(UserModel user) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'INFORMACIÓN PERSONAL',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: AppColors.textMuted,
                ),
              ),
              TextButton.icon(
                onPressed: () => _showEditProfileModal(user),
                icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.primary),
                label: const Text(
                  'Editar',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const Divider(height: 20, color: AppColors.trackBackground),
          _buildInfoRow(
            icon: Icons.person_outline,
            label: 'Nombres',
            value: user.userName,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            icon: Icons.badge_outlined,
            label: 'Apellidos',
            value: user.userLastName ?? 'No especificado',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            icon: Icons.mail_outline,
            label: 'Correo electrónico',
            value: user.mail,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            icon: Icons.phone_outlined,
            label: 'Número telefónico',
            value: (user.userPhone != null && user.userPhone!.isNotEmpty)
                ? user.userPhone!
                : 'No especificado',
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard(UserModel user) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield_outlined, size: 18, color: AppColors.primaryDark),
              const SizedBox(width: 8),
              const Text(
                'ROL ASIGNADO',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: AppColors.textMuted,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.trackBackground,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Solo lectura',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 20, color: AppColors.trackBackground),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.admin_panel_settings, size: 18, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      user.primaryRole,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'El rol y los privilegios de acceso son asignados exclusivamente por la administración y no pueden ser modificados desde este perfil.',
            style: TextStyle(
              fontSize: 11.5,
              color: AppColors.textMuted,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SEGURIDAD',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: AppColors.textMuted,
            ),
          ),
          const Divider(height: 20, color: AppColors.trackBackground),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.amberSoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.lock_reset, color: AppColors.amber, size: 22),
            ),
            title: const Text(
              'Cambiar contraseña',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryDark,
              ),
            ),
            subtitle: const Text(
              'Actualiza tu clave de acceso de forma segura',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
            onTap: _showChangePasswordModal,
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cerrar sesión',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Finalizar la sesión en este dispositivo',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          LogoutButton(onPressed: _handleLogout),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textMuted),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Modal para editar datos personales permitidos
class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet({
    required this.user,
    required this.userProvider,
  });

  final UserModel user;
  final UserProvider userProvider;

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  bool _submitting = false;
  String? _modalError;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.user.userName);
    _lastNameCtrl = TextEditingController(text: widget.user.userLastName ?? '');
    _emailCtrl = TextEditingController(text: widget.user.mail);
    _phoneCtrl = TextEditingController(text: widget.user.userPhone ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _submitting) return;

    setState(() {
      _submitting = true;
      _modalError = null;
    });

    final success = await widget.userProvider.updateProfile(
      userName: _nameCtrl.text,
      userLastName: _lastNameCtrl.text,
      mail: _emailCtrl.text,
      userPhone: _phoneCtrl.text,
    );

    if (!mounted) return;

    setState(() => _submitting = false);

    if (success) {
      Navigator.of(context).pop();
      NotificationWidget.show(
        context,
        type: NotificationType.success,
        message: 'Datos personales actualizados correctamente.',
      );
    } else {
      setState(() {
        _modalError = widget.userProvider.errorMessage ?? 'Error al actualizar el perfil.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 24, 20, 24 + bottomInset),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Editar datos personales',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20, color: AppColors.textMuted),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(color: AppColors.trackBackground),
              const SizedBox(height: 12),

              if (_modalError != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.redSoft,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.red.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, size: 18, color: AppColors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _modalError!,
                          style: const TextStyle(fontSize: 12.5, color: AppColors.red),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              _buildFieldLabel('Nombres *'),
              TextFormField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: _inputDecoration('Ej. William Roberto', Icons.person_outline),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'El nombre es obligatorio';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              _buildFieldLabel('Apellidos *'),
              TextFormField(
                controller: _lastNameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: _inputDecoration('Ej. Cortez', Icons.badge_outlined),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'El apellido es obligatorio';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              _buildFieldLabel('Correo electrónico *'),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDecoration('correo@farmadi.com', Icons.mail_outline),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'El correo es obligatorio';
                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(val.trim())) return 'Correo electrónico inválido';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              _buildFieldLabel('Número telefónico *'),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(8),
                ],
                decoration: _inputDecoration('84532072', Icons.phone_outlined),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'El teléfono es obligatorio';
                  if (val.trim().length < 8) return 'Debe tener 8 dígitos';
                  return null;
                },
              ),
              const SizedBox(height: 22),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _submitting ? null : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _submitting ? null : _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _submitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Guardar', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryDark,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 20, color: AppColors.textMuted),
      filled: true,
      fillColor: AppColors.background,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }
}

/// Modal para cambiar contraseña
class _ChangePasswordSheet extends StatefulWidget {
  const _ChangePasswordSheet({
    required this.userProvider,
  });

  final UserProvider userProvider;

  @override
  State<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<_ChangePasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _submitting = false;
  String? _modalError;

  @override
  void dispose() {
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _submitting) return;

    setState(() {
      _submitting = true;
      _modalError = null;
    });

    final success = await widget.userProvider.changePassword(
      newPassword: _newPasswordCtrl.text,
      confirmPassword: _confirmPasswordCtrl.text,
    );

    if (!mounted) return;

    setState(() => _submitting = false);

    if (success) {
      Navigator.of(context).pop();
      NotificationWidget.show(
        context,
        type: NotificationType.success,
        message: 'Contraseña actualizada con éxito.',
      );
    } else {
      setState(() {
        _modalError = widget.userProvider.errorMessage ?? 'Error al actualizar contraseña.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 24, 20, 24 + bottomInset),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Cambiar contraseña',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20, color: AppColors.textMuted),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(color: AppColors.trackBackground),
              const SizedBox(height: 12),

              if (_modalError != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.redSoft,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.red.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, size: 18, color: AppColors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _modalError!,
                          style: const TextStyle(fontSize: 12.5, color: AppColors.red),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              const Text(
                'La contraseña debe incluir al menos 6 caracteres, una letra mayúscula, una minúscula, un número y un caracter especial.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 16),

              _buildFieldLabel('Nueva contraseña *'),
              TextFormField(
                controller: _newPasswordCtrl,
                obscureText: _obscureNew,
                decoration: _passwordDecoration(
                  hint: '••••••••',
                  obscure: _obscureNew,
                  onToggle: () => setState(() => _obscureNew = !_obscureNew),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Ingresa la nueva contraseña';
                  final passRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^a-zA-Z\d]).{6,100}$');
                  if (!passRegex.hasMatch(val)) {
                    return 'Debe tener mayúscula, minúscula, número y símbolo (mín. 6)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              _buildFieldLabel('Confirmar nueva contraseña *'),
              TextFormField(
                controller: _confirmPasswordCtrl,
                obscureText: _obscureConfirm,
                decoration: _passwordDecoration(
                  hint: '••••••••',
                  obscure: _obscureConfirm,
                  onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Confirma la nueva contraseña';
                  if (val != _newPasswordCtrl.text) return 'Las contraseñas no coinciden';
                  return null;
                },
              ),
              const SizedBox(height: 22),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _submitting ? null : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _submitting ? null : _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _submitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Actualizar', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryDark,
        ),
      ),
    );
  }

  InputDecoration _passwordDecoration({
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: const Icon(Icons.lock_outline, size: 20, color: AppColors.textMuted),
      suffixIcon: IconButton(
        icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, size: 20, color: AppColors.textMuted),
        onPressed: onToggle,
      ),
      filled: true,
      fillColor: AppColors.background,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }
}
