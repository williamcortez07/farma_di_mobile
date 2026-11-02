import 'package:flutter/material.dart';
import 'package:farma_di_mobile/core/di/injection.dart';
import 'package:farma_di_mobile/data/models/auth_model/user_model.dart';
import 'package:farma_di_mobile/presentation/controllers/user_controller.dart';

import '../theme/app_colors.dart';
import '../widgets/logout_button.dart';
import '../widgets/notification_widget.dart';
import '../widgets/routes.dart';

enum _UserFormStatus { saved, cancelled }

class _UserFormResult {
  const _UserFormResult({
    required this.status,
    required this.name,
    required this.email,
    required this.roleId,
    required this.password,
    required this.phone,
    required this.isActive,
  });

  const _UserFormResult.saved({
    required String name,
    required String email,
    required int? roleId,
    required String password,
    required String phone,
    required bool isActive,
  }) : this(
         status: _UserFormStatus.saved,
         name: name,
         email: email,
         roleId: roleId,
         password: password,
         phone: phone,
         isActive: isActive,
       );

  const _UserFormResult.cancelled()
    : this(
        status: _UserFormStatus.cancelled,
        name: '',
        email: '',
        roleId: null,
        password: '',
        phone: '',
        isActive: false,
      );

  final _UserFormStatus status;
  final String name;
  final String email;
  final int? roleId;
  final String password;
  final String phone;
  final bool isActive;
}

class AppUser {
  AppUser(this.model);

  final AppUserModel model;
  String get name => model.fullName;
  String get email => model.email;
  String get role => model.roleLabel;
  String get phone => model.phone;
  bool get active => model.isActive;
}

class RolesScreen extends StatefulWidget {
  const RolesScreen({super.key});

  @override
  State<RolesScreen> createState() => _RolesScreenState();
}

class _RolesScreenState extends State<RolesScreen> {
  late final UserController _userController;
  String _selectedFilter = 'Todos';

  List<AppUser> get _users =>
      _userController.users.map(AppUser.new).toList(growable: false);

  @override
  void initState() {
    super.initState();
    _userController = getIt<UserController>()..addListener(_onUsersChanged);
    _userController.fetchUsers();
  }

  void _onUsersChanged() {
    if (!mounted) return;
    if (_userController.status == UserStatus.success &&
        _selectedFilter != 'Todos' &&
        !_userController.users.any(
          (user) => user.roleLabel == _selectedFilter,
        )) {
      _selectedFilter = 'Todos';
    }
    setState(() {});
  }

  @override
  void dispose() {
    _userController.removeListener(_onUsersChanged);
    _userController.dispose();
    super.dispose();
  }

  List<AppUser> get _filteredUsers {
    if (_selectedFilter == 'Todos') {
      return _users;
    }
    return _users.where((user) => user.role == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 16),
              _buildRoleFilters(),
              const SizedBox(height: 12),
              _buildPeopleHeading(),
              const SizedBox(height: 8),
              Expanded(child: _buildUserList()),
              _buildPaginationControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LUNES, 28 DE SEPTIEMBRE',
                style: TextStyle(fontSize: 11, color: AppColors.mutedText),
              ),
              SizedBox(height: 4),
              Text(
                'Roles y permisos',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
              ),
              Text(
                'Gestión de accesos del personal',
                style: TextStyle(fontSize: 12, color: AppColors.mutedText),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        LogoutButton(
          onPressed: () =>
              Navigator.of(context).pushReplacementNamed(AppRoutes.login),
        ),
      ],
    );
  }

  Widget _buildRoleFilters() {
    final filters = ['Todos', ..._users.map((user) => user.role).toSet()];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (_) => setState(() => _selectedFilter = filter),
              labelStyle: TextStyle(
                fontSize: 11,
                color: isSelected ? AppColors.surface : AppColors.primaryDark,
                fontWeight: FontWeight.w600,
              ),
              selectedColor: AppColors.primaryDark,
              backgroundColor: AppColors.surface,
              side: BorderSide(
                color: isSelected
                    ? AppColors.primaryDark
                    : AppColors.trackBackground,
              ),
              showCheckmark: false,
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPeopleHeading() {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Personal (${_filteredUsers.length})',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
        ),
        Tooltip(
          message: _userController.availableRoles.isEmpty
              ? 'La API no devolvió roles disponibles para asignar.'
              : 'Agregar usuario',
          child: TextButton.icon(
            onPressed: _userController.availableRoles.isEmpty
                ? null
                : () => _showUserForm(),
            icon: const Icon(Icons.person_add_alt_1, size: 16),
            label: const Text('Agregar'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              visualDensity: VisualDensity.compact,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserList() {
    if (_users.isEmpty && _userController.status == UserStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_users.isEmpty && _userController.status == UserStatus.error) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _userController.errorMessage ?? 'No se pudo cargar el personal.',
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _userController.fetchUsers(),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }
    if (_users.isEmpty) {
      return const Center(child: Text('No hay usuarios registrados.'));
    }
    return Column(
      children: [
        if (_userController.status == UserStatus.loading)
          const LinearProgressIndicator(),
        if (_userController.status == UserStatus.error)
          TextButton.icon(
            onPressed: () =>
                _userController.fetchUsers(page: _userController.currentPage),
            icon: const Icon(Icons.refresh, size: 16),
            label: Text(_userController.errorMessage ?? 'Error al actualizar.'),
          ),
        Expanded(
          child: _filteredUsers.isEmpty
              ? const Center(
                  child: Text('No hay usuarios con este rol en esta página.'),
                )
              : ListView.separated(
                  itemCount: _filteredUsers.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) =>
                      _buildUserCard(_filteredUsers[index]),
                ),
        ),
      ],
    );
  }

  Widget _buildUserCard(AppUser user) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => _showUserForm(user: user),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.trackBackground),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 21,
                backgroundColor: _roleColor(user.role),
                child: Text(
                  _getInitials(user.name),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.surface,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      user.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildRoleBadge(user.role),
                  const SizedBox(height: 5),
                  _buildStatusBadge(user.active),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final nameParts = name.trim().split(RegExp(r'\s+'));
    if (nameParts.length >= 2) {
      return '${nameParts.first[0]}${nameParts[1][0]}'.toUpperCase();
    }
    return name.isEmpty ? '?' : name[0].toUpperCase();
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'Administrador':
      case 'Admin':
        return AppColors.primaryDark;
      case 'Supervisor':
        return AppColors.warning;
      case 'Vendedor':
        return AppColors.chartBlue;
      default:
        return AppColors.textSecondary;
    }
  }

  Widget _buildPaginationControls() {
    final isLoading = _userController.status == UserStatus.loading;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Página ${_userController.currentPage} de ${_userController.totalPages} · '
          '${_userController.totalItems} usuarios',
          style: const TextStyle(fontSize: 11, color: AppColors.mutedText),
        ),
        Row(
          children: [
            IconButton(
              onPressed: !isLoading && _userController.hasPreviousPage
                  ? _userController.previousPage
                  : null,
              icon: const Icon(Icons.chevron_left),
              tooltip: 'Página anterior',
            ),
            IconButton(
              onPressed: !isLoading && _userController.hasNextPage
                  ? _userController.nextPage
                  : null,
              icon: const Icon(Icons.chevron_right),
              tooltip: 'Página siguiente',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRoleBadge(String role) {
    final color = _roleColor(role);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        role,
        style: TextStyle(
          fontSize: 9,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    final color = isActive ? AppColors.success : AppColors.textMuted;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          isActive ? 'Activo' : 'Inactivo',
          style: TextStyle(fontSize: 9, color: color),
        ),
      ],
    );
  }

  Future<void> _showUserForm({AppUser? user}) async {
    final isEditing = user != null;
    final nameParts = (user?.name ?? '').trim().split(RegExp(r'\s+'));
    final firstNameController = TextEditingController(
      text: nameParts.isEmpty ? '' : nameParts.first,
    );
    final lastNameController = TextEditingController(
      text: nameParts.length < 2 ? '' : nameParts.skip(1).join(' '),
    );
    final emailController = TextEditingController(text: user?.email ?? '');
    final phoneController = TextEditingController(text: user?.phone ?? '');
    final passwordController = TextEditingController();
    final availableRoles = _userController.availableRoles;
    final formKey = GlobalKey<FormState>();
    int? selectedRoleId;
    if (user != null && user.model.roles.isNotEmpty) {
      selectedRoleId = user.model.roles.first.id;
    } else if (user == null && availableRoles.isNotEmpty) {
      selectedRoleId = availableRoles.first.id;
    }
    var isActive = user?.active ?? true;
    String? formAlertMessage;

    final result = await showModalBottomSheet<_UserFormResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.primaryDark.withValues(alpha: 0.42),
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.62,
        minChildSize: 0.48,
        maxChildSize: 0.94,
        expand: false,
        builder: (context, scrollController) => StatefulBuilder(
          builder: (context, setModalState) {
            final matchingRoles = availableRoles
                .where((role) => role.id == selectedRoleId)
                .toList();
            final selectedRole = matchingRoles.isNotEmpty
                ? matchingRoles.first.name
                : user?.role ?? 'Sin rol';
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
              ),
              child: Form(
                key: formKey,
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.fromLTRB(
                    20,
                    10,
                    20,
                    MediaQuery.viewInsetsOf(context).bottom +
                        MediaQuery.viewPaddingOf(context).bottom +
                        36,
                  ),
                  children: [
                    Center(
                      child: Container(
                        width: 38,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.neutralGray,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.circle,
                          size: 8,
                          color: AppColors.chartBlue,
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            isEditing ? 'Detalle de usuario' : 'Nuevo usuario',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Cerrar',
                          onPressed: () => Navigator.pop(
                            sheetContext,
                            const _UserFormResult.cancelled(),
                          ),
                          icon: const Icon(Icons.close, size: 20),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _buildProfileSummary(user, selectedRole, isActive),
                    if (formAlertMessage != null) ...[
                      const SizedBox(height: 10),
                      NotificationWidget(
                        type: NotificationType.alert,
                        message: formAlertMessage!,
                      ),
                    ],
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildFormField(
                            label: 'Nombre',
                            controller: firstNameController,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildFormField(
                            label: 'Apellido',
                            controller: lastNameController,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildFormField(
                      label: 'Correo',
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      icon: Icons.mail_outline,
                      isEmail: true,
                      originalValue: user?.email,
                    ),
                    const SizedBox(height: 10),
                    _buildFormField(
                      label: 'Teléfono',
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      icon: Icons.phone_outlined,
                    ),
                    const SizedBox(height: 10),
                    _buildFormField(
                      label: isEditing
                          ? 'Nueva contraseña (opcional)'
                          : 'Contraseña',
                      controller: passwordController,
                      isRequired: !isEditing,
                      obscureText: true,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Rol en farmacia',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 5),
                    if (isEditing)
                      InputDecorator(
                        decoration: _formDecoration(
                          prefixIcon: Icons.badge_outlined,
                        ),
                        child: Text(selectedRole),
                      )
                    else
                      DropdownButtonFormField<int>(
                        initialValue: selectedRoleId,
                        decoration: _formDecoration(
                          prefixIcon: Icons.badge_outlined,
                        ),
                        validator: (value) =>
                            value == null ? 'Selecciona un rol' : null,
                        items: availableRoles
                            .map(
                              (role) => DropdownMenuItem<int>(
                                value: role.id,
                                child: Text(role.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setModalState(() => selectedRoleId = value);
                          }
                        },
                      ),
                    const Padding(
                      padding: EdgeInsets.only(top: 5),
                      child: Text(
                        'El cambio de rol requiere confirmar el payload de asignación de la API.',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    if (isEditing) ...[
                      const SizedBox(height: 10),
                      _buildAccountStatus(isActive, (value) {
                        setModalState(() => isActive = value);
                      }),
                    ],
                    const SizedBox(height: 10),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 46,
                      child: FilledButton.icon(
                        onPressed: () {
                          if (!formKey.currentState!.validate()) {
                            setModalState(() {
                              formAlertMessage = 'Revisa los campos marcados antes de guardar :)';
                            });
                            return;
                          }
                          setModalState(() => formAlertMessage = null);
                          final name =
                              '${firstNameController.text.trim()} '
                                      '${lastNameController.text.trim()}'
                                  .trim();
                          Navigator.pop(
                            sheetContext,
                            _UserFormResult.saved(
                              name: name,
                              email: emailController.text.trim(),
                              roleId: selectedRoleId,
                              password: passwordController.text,
                              phone: phoneController.text.trim(),
                              isActive: isActive,
                            ),
                          );
                        },
                        icon: const Icon(Icons.save_outlined, size: 17),
                        label: Text(
                          isEditing ? 'Guardar Cambios' : 'Agregar usuario',
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primaryDark,
                          foregroundColor: AppColors.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pop(
                          sheetContext,
                          const _UserFormResult.cancelled(),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );

    await WidgetsBinding.instance.endOfFrame;
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();

    if (!mounted) {
      return;
    }

    if (result?.status == _UserFormStatus.saved) {
      try {
        final nameParts = result!.name.trim().split(RegExp(r'\s+'));
        if (user != null) {
          await _userController.updateUser(
            user.model,
            name: nameParts.first,
            lastName: nameParts.length < 2 ? '' : nameParts.skip(1).join(' '),
            email: result.email,
            phone: result.phone,
            isActive: result.isActive,
            password: result.password.isEmpty ? null : result.password,
          );
        } else {
          final roleId = result.roleId;
          if (roleId == null) return;
          await _userController.createUser(
            name: nameParts.first,
            lastName: nameParts.length < 2 ? '' : nameParts.skip(1).join(' '),
            password: result.password,
            email: result.email,
            phone: result.phone,
            roleId: roleId,
          );
        }
      } catch (error) {
        if (!mounted) return;
        NotificationWidget.show(
          context,
          type: NotificationType.error,
          message: error.toString().replaceFirst('Exception: ', ''),
        );
        return;
      }
      if (!mounted) return;
      NotificationWidget.show(
        context,
        type: NotificationType.success,
        message: isEditing
            ? 'Cambios guardados correctamente.'
            : 'Usuario agregado correctamente.',
      );
    } else {
      NotificationWidget.show(
        context,
        type: NotificationType.cancellation,
        message: 'Operación cancelada.',
      );
    }
  }

  Widget _buildProfileSummary(AppUser? user, String role, bool isActive) {
    final displayName = user?.name ?? 'Nuevo integrante';
    final initials = user == null ? '?' : _getInitials(user.name);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.infoBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.link,
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: AppColors.surface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (isActive)
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.surface, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 5,
                  runSpacing: 4,
                  children: [
                    _buildCompactTag(
                      isActive ? 'Activo' : 'Inactivo',
                      isActive
                          ? AppColors.successSoft
                          : AppColors.trackBackground,
                      isActive ? AppColors.success : AppColors.textSecondary,
                    ),
                    if (user != null)
                      _buildCompactTag(
                        'USR-${user.model.id.toString().padLeft(3, '0')}',
                        AppColors.trackBackground,
                        AppColors.textSecondary,
                      ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                    if (role == 'Administrador') ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.verified,
                        size: 14,
                        color: AppColors.chartBlue,
                      ),
                    ],
                  ],
                ),
                if (user != null) ...[
                  const SizedBox(height: 3),
                  const Text(
                    'Miembro desde: Feb 2023',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactTag(String label, Color background, Color foreground) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: foreground,
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    IconData? icon,
    bool isEmail = false,
    String? originalValue,
    bool isRequired = true,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
            children: isRequired
                ? const [
                    TextSpan(
                      text: ' *',
                      style: TextStyle(color: AppColors.red),
                    ),
                  ]
                : const [],
          ),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          style: const TextStyle(fontSize: 12, color: AppColors.primaryDark),
          decoration: _formDecoration(prefixIcon: icon),
          validator: (value) {
            final fieldValue = value?.trim() ?? '';
            if (isRequired && fieldValue.isEmpty) {
              return 'Campo obligatorio';
            }
            if (isEmail &&
                !fieldValue.contains('@') &&
                fieldValue != originalValue) {
              return 'Correo no válido';
            }
            return null;
          },
        ),
      ],
    );
  }

  InputDecoration _formDecoration({IconData? prefixIcon}) {
    return InputDecoration(
      prefixIcon: prefixIcon == null
          ? null
          : Icon(prefixIcon, size: 16, color: AppColors.textSecondary),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      filled: true,
      fillColor: AppColors.surface,
      isDense: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: AppColors.trackBackground),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: AppColors.trackBackground),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: AppColors.chartBlue),
      ),
      errorStyle: const TextStyle(fontSize: 10),
    );
  }

  Widget _buildAccountStatus(bool isActive, ValueChanged<bool> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.trackBackground),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.successSoft,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.toggle_on_outlined,
              color: AppColors.success,
              size: 19,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Estado de cuenta',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
                Text(
                  isActive
                      ? 'Activo · Acceso permitido'
                      : 'Inactivo · Sin acceso',
                  style: TextStyle(
                    fontSize: 10,
                    color: isActive ? AppColors.success : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: isActive,
            onChanged: onChanged,
            activeTrackColor: AppColors.link,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}
