import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/notification_widget.dart';
import '../widgets/routes.dart';
import '../widgets/app_navbar.dart';

enum _UserFormStatus { saved, cancelled }

class _UserFormResult {
  const _UserFormResult({
    required this.status,
    required this.name,
    required this.email,
    required this.role,
    required this.phone,
    required this.isActive,
  });

  const _UserFormResult.saved({
    required String name,
    required String email,
    required String role,
    required String phone,
    required bool isActive,
  }) : this(
         status: _UserFormStatus.saved,
         name: name,
         email: email,
         role: role,
         phone: phone,
         isActive: isActive,
       );

  const _UserFormResult.cancelled()
    : this(
        status: _UserFormStatus.cancelled,
        name: '',
        email: '',
        role: '',
        phone: '',
        isActive: false,
      );

  final _UserFormStatus status;
  final String name;
  final String email;
  final String role;
  final String phone;
  final bool isActive;
}

class AppUser {
  String name;
  String email;
  String role;
  String phone;
  String lastSession;
  bool active;

  AppUser({
    required this.name,
    required this.email,
    required this.role,
    required this.phone,
    required this.lastSession,
    required this.active,
  });
}

class RolesScreen extends StatefulWidget {
  const RolesScreen({super.key});

  @override
  State<RolesScreen> createState() => _RolesScreenState();
}

class _RolesScreenState extends State<RolesScreen> {
  static const List<String> _roles = [
    'Administrador',
    'Supervisor',
    'Vendedor',
  ];
  static const Map<String, List<String>> _permissionsByRole = {
    'Administrador': [
      'Ventas y Facturación',
      'Catálogo de Productos',
      'Métricas analíticas',
      'Logs del sistema',
      'Configuración global',
    ],
    'Supervisor': [
      'Ventas y Facturación',
      'Catálogo de Productos',
      'Métricas analíticas',
    ],
    'Vendedor': ['Ventas y Facturación', 'Catálogo de Productos'],
  };

  String _selectedFilter = 'Todos';

  final List<AppUser> _users = [
    AppUser(
      name: 'Ana García',
      email: 'a.garcia@farmadi.com',
      role: 'Administrador',
      phone: '+505 8881-2401',
      lastSession: 'Hoy a las 08:42 AM (Administración)',
      active: true,
    ),
    AppUser(
      name: 'Carlos Méndez',
      email: 'c.mendez@farmadi.com',
      role: 'Vendedor',
      phone: '+505 8744-1290',
      lastSession: 'Hoy a las 09:15 AM (Caja Mostrador #2)',
      active: true,
    ),
    AppUser(
      name: 'Sofía Reyes',
      email: 's.reyes@farmadi.com',
      role: 'Supervisor',
      phone: '+505 8881-3472',
      lastSession: 'Hoy a las 08:30 AM (Sucursal Central)',
      active: true,
    ),
    AppUser(
      name: 'Diego López',
      email: 'd.lopez@farmadi.com',
      role: 'Vendedor',
      phone: '+505 8744-2618',
      lastSession: 'Ayer a las 06:12 PM (Caja Mostrador #1)',
      active: true,
    ),
    AppUser(
      name: 'Valentina Cruz',
      email: 'v.cruz@farmadi.com',
      role: 'Vendedor',
      phone: '+505 8744-3027',
      lastSession: 'Ayer a las 04:50 PM (Caja Mostrador #3)',
      active: false,
    ),
    AppUser(
      name: 'Luis Morales',
      email: 'l.morales@farmadi.com',
      role: 'Supervisor',
      phone: '+505 8881-0954',
      lastSession: 'Hoy a las 07:55 AM (Sucursal Norte)',
      active: true,
    ),
  ];

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
        TextButton.icon(
          onPressed: _showUserForm,
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
      ],
    );
  }

  Widget _buildUserList() {
    return ListView.separated(
      itemCount: _filteredUsers.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) => _buildUserCard(_filteredUsers[index]),
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
        return AppColors.primaryDark;
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
    final formKey = GlobalKey<FormState>();
    var selectedRole = user?.role ?? 'Vendedor';
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
            final assignedPermissions =
                _permissionsByRole[selectedRole] ?? const <String>[];

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
                    DropdownButtonFormField<String>(
                      initialValue: selectedRole,
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
                      onChanged: (value) {
                        if (value != null) {
                          setModalState(() => selectedRole = value);
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildAccountStatus(isActive, (value) {
                      setModalState(() => isActive = value);
                    }),
                    const SizedBox(height: 10),
                    _buildPermissions(assignedPermissions),
                    if (user != null) ...[
                      const SizedBox(height: 10),
                      _buildLastSession(user.lastSession),
                    ],
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
                              role: selectedRole,
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

    if (!mounted) {
      return;
    }

    if (result?.status == _UserFormStatus.saved) {
      try {
        if (user != null) {
          _updateUser(
            user,
            result!.name,
            result.email,
            result.role,
            result.phone,
            result.isActive,
          );
        } else {
          _addUser(
            result!.name,
            result.email,
            result.role,
            result.phone,
            result.isActive,
          );
        }
      } catch (_) {
        NotificationWidget.show(
          context,
          type: NotificationType.error,
          message: 'No se pudieron guardar los cambios. Inténtalo de nuevo.',
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
    final userIndex = user == null ? -1 : _users.indexOf(user);

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
                    if (userIndex >= 0)
                      _buildCompactTag(
                        'USR-${(userIndex + 2).toString().padLeft(3, '0')}',
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

  Widget _buildPermissions(List<String> assignedPermissions) {
    const permissions = [
      'Ventas y Facturación',
      'Catálogo de Productos',
      'Métricas analíticas',
      'Logs del sistema',
      'Configuración global',
    ];
    final restrictedPermissions = permissions
        .where((permission) => !assignedPermissions.contains(permission))
        .toList();

    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.verified_user_outlined,
                size: 16,
                color: AppColors.link,
              ),
              SizedBox(width: 6),
              Text(
                'Permisos asignados',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            'Acceso asignado: ${assignedPermissions.join(', ')}. '
            'Restringido: ${restrictedPermissions.isEmpty ? 'Ninguno' : restrictedPermissions.join(', ')}.',
            style: const TextStyle(
              fontSize: 10,
              height: 1.4,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 5,
            runSpacing: 5,
            children: permissions.map((permission) {
              final isAssigned = assignedPermissions.contains(permission);
              return _buildPermissionTag(permission, isAssigned);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionTag(String permission, bool isAssigned) {
    final isRestrictedLog = permission == 'Logs del sistema' && !isAssigned;
    final background = isAssigned
        ? AppColors.infoBackground
        : isRestrictedLog
        ? AppColors.redSoft
        : AppColors.trackBackground;
    final foreground = isAssigned
        ? AppColors.primaryDark
        : isRestrictedLog
        ? AppColors.red
        : AppColors.textSecondary;
    final icon = isAssigned
        ? Icons.check_circle_outline
        : isRestrictedLog
        ? Icons.block
        : Icons.remove_circle_outline;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: foreground),
          const SizedBox(width: 4),
          Text(
            permission,
            style: TextStyle(
              fontSize: 9,
              color: foreground,
              fontWeight: FontWeight.w600,
              decoration: permission == 'Configuración global' && !isAssigned
                  ? TextDecoration.lineThrough
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastSession(String lastSession) {
    return Container(
      padding: const EdgeInsets.all(10),
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
              color: AppColors.infoBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.history,
              size: 16,
              color: AppColors.chartBlue,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ÚLTIMA SESIÓN',
                  style: TextStyle(fontSize: 9, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 2),
                Text(
                  lastSession,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addUser(
    String name,
    String email,
    String role,
    String phone,
    bool isActive,
  ) {
    setState(() {
      _users.add(
        AppUser(
          name: name,
          email: email,
          role: role,
          phone: phone,
          lastSession: 'Sin sesiones registradas',
          active: isActive,
        ),
      );
    });
  }

  void _updateUser(
    AppUser user,
    String name,
    String email,
    String role,
    String phone,
    bool isActive,
  ) {
    setState(() {
      user.name = name;
      user.email = email;
      user.role = role;
      user.phone = phone;
      user.active = isActive;
    });
  }
}
