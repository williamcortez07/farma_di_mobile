import 'package:flutter/material.dart';
import 'package:farma_di_mobile/core/di/injection.dart';
import 'package:farma_di_mobile/core/errors/app_exception.dart';
import 'package:farma_di_mobile/data/models/auth_model/user_model.dart';
import 'package:farma_di_mobile/presentation/controllers/roles_controller.dart';

import '../theme/app_colors.dart';
import '../widgets/notification_widget.dart';

enum _UserFormStatus { saved, cancelled }

class _UserFormResult {
  const _UserFormResult({
    required this.status,
    required this.name,
    required this.lastName,
    required this.email,
    required this.roleId,
    required this.password,
    required this.phone,
    required this.isActive,
  });

  const _UserFormResult.saved({
    required String name,
    required String lastName,
    required String email,
    required int? roleId,
    required String password,
    required String phone,
    required bool isActive,
  }) : this(
         status: _UserFormStatus.saved,
         name: name,
         lastName: lastName,
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
        lastName: '',
        email: '',
        roleId: null,
        password: '',
        phone: '',
        isActive: false,
      );

  final _UserFormStatus status;
  final String name;
  final String lastName;
  final String email;
  final int? roleId;
  final String password;
  final String phone;
  final bool isActive;
}

class AppUser {
  const AppUser({required this.model, required this.role});

  final UserModel model;
  final String role;
  String get name => model.fullName;
  String get email => model.mail;
  String get phone => model.userPhone ?? '';
  bool get active => model.isActive;
}

class RolesScreen extends StatefulWidget {
  const RolesScreen({super.key});

  @override
  State<RolesScreen> createState() => _RolesScreenState();
}

class _RolesScreenState extends State<RolesScreen> {
  late final RolesController _rolesController;
  List<String> get _roles =>
      _rolesController.roles.map((role) => role.rolName).toList();

  String _selectedFilter = 'Todos';

  List<AppUser> get _users => _rolesController.users.map((model) {
    final matchingRole = _rolesController.roles.where(
      (role) => role.rolId == model.rolId,
    );
    final assignedRoleNames = model.roles
        .map((role) => role.rolName.trim())
        .where((name) => name.isNotEmpty)
        .toList();
    final roleName = assignedRoleNames.isNotEmpty
        ? assignedRoleNames.join(', ')
        : matchingRole.isNotEmpty
        ? matchingRole.first.rolName
        : model.rolId == null || model.rolId == 0
        ? 'Sin rol'
        : 'Rol ${model.rolId}';
    return AppUser(model: model, role: roleName);
  }).toList(growable: false);

  @override
  void initState() {
    super.initState();
    _rolesController = getIt<RolesController>()..addListener(_onControllerChanged);
    _rolesController.fetchUsers();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _rolesController.removeListener(_onControllerChanged);
    _rolesController.dispose();
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      /* appBar: AppNavbar(
        profileImageUrl: null,
        onProfileTap: () {
          Navigator.of(context).pushNamed(AppRoutes.profile);
        },
      ),

      */
      // comentariado porque  esto lo maneja home_screen con el IdexedStack, line 58
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
                'Roles y permisos',
                style: TextStyle(
                  fontSize: 28,
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
      ],
    );
  }

  Widget _buildRoleFilters() {
    final filters = ['Todos', ..._roles];

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
              backgroundColor: Theme.of(context).colorScheme.surface,
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
            'Personal (${_selectedFilter == 'Todos' ? _rolesController.totalItems : _filteredUsers.length})',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
        ),
        Tooltip(
          message: _rolesController.roles.isEmpty
              ? (_rolesController.rolesErrorMessage ?? 'No hay roles activos disponibles.')
              : 'Agregar usuario',
          child: TextButton.icon(
            onPressed: _rolesController.roles.isEmpty
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
    if (_rolesController.status == RolesStatus.loading && _users.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_rolesController.status == RolesStatus.error && _users.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_rolesController.errorMessage ?? 'No se pudo cargar el personal.'),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _rolesController.fetchUsers(),
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
        if (_rolesController.status == RolesStatus.error)
          TextButton.icon(
            onPressed: () => _rolesController.fetchUsers(
              page: _rolesController.currentPage,
            ),
            icon: const Icon(Icons.refresh, size: 16),
            label: Text(_rolesController.errorMessage ?? 'Error al actualizar.'),
          ),
        if (_rolesController.status == RolesStatus.loading)
          const LinearProgressIndicator(),
        Expanded(
          child: _filteredUsers.isEmpty
              ? const Center(
                  child: Text('No hay usuarios de este rol en esta página.'),
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

  Widget _buildPaginationControls() {
    final isLoading = _rolesController.status == RolesStatus.loading;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Página ${_rolesController.currentPage} de ${_rolesController.totalPages} · ${_rolesController.totalItems} usuarios',
          style: const TextStyle(fontSize: 11, color: AppColors.mutedText),
        ),
        Row(
          children: [
            IconButton(
              tooltip: 'Página anterior',
              onPressed: !isLoading && _rolesController.hasPreviousPage
                  ? _rolesController.previousPage
                  : null,
              icon: const Icon(Icons.chevron_left),
            ),
            IconButton(
              tooltip: 'Página siguiente',
              onPressed: !isLoading && _rolesController.hasNextPage
                  ? _rolesController.nextPage
                  : null,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
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
      case 'Admin':
      case 'Administrador':
        return AppColors.primaryDark;
      case 'Empleado':
        return AppColors.chartBlue;
      case 'Supervisor':
        return AppColors.warning;
      case 'Vendedor':
        return AppColors.chartBlue;
      default:
        return AppColors.textSecondary;
    }
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
    final formKey = GlobalKey<FormState>();
    var selectedRole = user?.role ?? (_roles.isNotEmpty ? _roles.first : '');
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
                            isEditing
                                ? 'Detalle Rol ${selectedRole.toLowerCase()}'
                                : 'Nuevo usuario',
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
                    ),
                    const SizedBox(height: 10),
                    _buildFormField(
                      label: 'Teléfono',
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      icon: Icons.phone_outlined,
                    ),
                    if (!isEditing) ...[
                      const SizedBox(height: 10),
                      _buildFormField(
                        label: 'Contraseña',
                        controller: passwordController,
                        icon: Icons.lock_outline,
                        obscureText: true,
                      ),
                    ],
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
                        child: Text(
                          user.role,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      )
                    else
                      DropdownButtonFormField<String>(
                        initialValue: _roles.contains(selectedRole)
                            ? selectedRole
                            : (_roles.isEmpty ? null : _roles.first),
                        key: ValueKey('role-${_roles.join('-')}-$selectedRole'),
                        validator: (value) => value == null
                            ? 'Selecciona un rol'
                            : null,
                        onChanged: (value) {
                          if (value != null) {
                            setModalState(() => selectedRole = value);
                          }
                        },
                        decoration: _formDecoration(
                          prefixIcon: Icons.badge_outlined,
                        ),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.primaryDark,
                        ),
                        items: _roles
                            .map(
                              (role) => DropdownMenuItem(
                                value: role,
                                child: Text(role),
                              ),
                            )
                            .toList(),
                      ),
                    const SizedBox(height: 10),
                    if (isEditing)
                      _buildAccountStatus(isActive, (value) {
                        setModalState(() => isActive = value);
                      }),
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
                          final name = firstNameController.text.trim();
                          final matchingRoles = _rolesController.roles
                              .where((role) => role.rolName == selectedRole)
                              .toList();
                          Navigator.pop(
                            sheetContext,
                            _UserFormResult.saved(
                              name: name,
                              lastName: lastNameController.text.trim(),
                              email: emailController.text.trim(),
                              roleId: matchingRoles.isEmpty
                                  ? null
                                  : matchingRoles.first.rolId,
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
        if (user != null) {
          await _updateUser(
            user,
            result!.name,
            result!.lastName,
            result.email,
            result.phone,
            result.isActive,
          );
        } else {
          await _addUser(
            result!.name,
            result!.lastName,
            result.email,
            result.roleId,
            result.password,
            result.phone,
          );
        }
      } catch (error) {
        NotificationWidget.show(
          context,
          type: NotificationType.error,
          message: error is AppException
              ? error.message
              : 'No se pudieron guardar los cambios. Inténtalo de nuevo.',
        );
        return;
      }
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
    final userIndex = user?.model.id ?? 0;

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
                    if (userIndex > 0)
                      _buildCompactTag(
                        'USR-${userIndex.toString().padLeft(3, '0')}',
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
                    if (role == 'Administrador' || role == 'Admin') ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.verified,
                        size: 14,
                        color: AppColors.chartBlue,
                      ),
                    ],
                  ],
                ),
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
            children: const [
              TextSpan(
                text: ' *',
                style: TextStyle(color: AppColors.red),
              ),
            ],
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
            if (fieldValue.isEmpty) {
              return 'Campo obligatorio';
            }
            if (isEmail && !fieldValue.contains('@')) {
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

  Future<void> _addUser(
    String name,
    String lastName,
    String email,
    int? roleId,
    String password,
    String phone,
  ) async {
    if (roleId == null) throw const ParsingException('Selecciona un rol.');
    if (password.isEmpty) throw const ParsingException('La contraseña es obligatoria.');
    await _rolesController.createUser(
      userName: name,
      userLastName: lastName,
      password: password,
      mail: email,
      userPhone: phone,
      roleId: roleId,
    );
  }

  Future<void> _updateUser(
    AppUser user,
    String name,
    String lastName,
    String email,
    String phone,
    bool isActive,
  ) => _rolesController.updateUser(
    user: user.model,
    userName: name,
    userLastName: lastName,
    mail: email,
    userPhone: phone,
    isActive: isActive,
  );
}
