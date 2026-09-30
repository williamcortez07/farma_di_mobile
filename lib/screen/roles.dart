import 'package:flutter/material.dart';

class AppUser {
  String name;
  String email;
  String role;
  bool active;

  AppUser({
    required this.name,
    required this.email,
    required this.role,
    required this.active,
  });
}

class RolesScreen extends StatefulWidget {
  const RolesScreen({super.key});

  @override
  State<RolesScreen> createState() => _RolesScreenState();
}

class _RolesScreenState extends State<RolesScreen> {
  String selectedFilter = 'Todos';

  final List<String> roles = ['Administrador', 'Supervisor', 'Vendedor'];

  final List<AppUser> users = [
    AppUser(
      name: 'Ana García',
      email: 'a.garcia@farmadi.com',
      role: 'Administrador',
      active: true,
    ),
    AppUser(
      name: 'Carlos Méndez',
      email: 'c.mendez@farmadi.com',
      role: 'Vendedor',
      active: true,
    ),
    AppUser(
      name: 'Sofía Reyes',
      email: 's.reyes@farmadi.com',
      role: 'Supervisor',
      active: true,
    ),
    AppUser(
      name: 'Diego López',
      email: 'd.lopez@farmadi.com',
      role: 'Vendedor',
      active: true,
    ),
    AppUser(
      name: 'Valentina Cruz',
      email: 'v.cruz@farmadi.com',
      role: 'Vendedor',
      active: false,
    ),
    AppUser(
      name: 'Luis Morales',
      email: 'l.morales@farmadi.com',
      role: 'Supervisor',
      active: true,
    ),
  ];

  List<AppUser> get filteredUsers {
    if (selectedFilter == 'Todos') {
      return users;
    }

    return users.where((user) => user.role == selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),

            const SizedBox(height: 16),

            _buildRoleFilters(),
            const SizedBox(height: 16),

            Expanded(child: _buildUserList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Roles y permisos',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),

        IconButton(
          onPressed: () {
            _showUserForm();
          },
          icon: const Icon(Icons.person_add_alt_1),
        ),
      ],
    );
  }

  Widget _buildRoleFilters() {
    final filters = ['Todos', 'Administrador', 'Supervisor', 'Vendedor'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final selected = selectedFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter),
              selected: selected,
              onSelected: (_) {
                setState(() {
                  selectedFilter = filter;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildUserList() {
    return ListView.builder(
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) {
        final user = filteredUsers[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _buildUserCard(user),
        );
      },
    );
  }

  Widget _buildUserCard(AppUser user) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            child: Text(
              _getInitials(user.name),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  user.email,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildRoleBadge(user.role),

              const SizedBox(height: 5),

              _buildStatusBadge(user.active),
            ],
          ),

          const SizedBox(width: 4),

          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            onPressed: () {
              _showUserForm(user: user);
            },
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');

    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }

    return name.substring(0, 1).toUpperCase();
  }

  Widget _buildRoleBadge(String role) {
    Color color;

    switch (role) {
      case 'Administrador':
        color = Colors.blue;
        break;

      case 'Supervisor':
        color = Colors.orange;
        break;

      case 'Vendedor':
        color = Colors.lightBlue;
        break;

      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        role,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool active) {
    final color = active ? Colors.green : Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),

          const SizedBox(width: 4),

          Text(
            active ? 'Activo' : 'Inactivo',
            style: TextStyle(fontSize: 10, color: color),
          ),
        ],
      ),
    );
  }

  void _showUserForm({AppUser? user}) {
    final isEditing = user != null;

    final nameController = TextEditingController(text: user?.name ?? '');

    final emailController = TextEditingController(text: user?.email ?? '');

    String selectedRole = user?.role ?? 'Vendedor';
    bool active = user?.active ?? true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEditing ? 'Modificar usuario' : 'Agregar usuario',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 14),

                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Correo electrónico',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 14),

                  DropdownButtonFormField<String>(
                    initialValue: selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'Rol',
                      border: OutlineInputBorder(),
                    ),
                    items: roles.map((role) {
                      return DropdownMenuItem(value: role, child: Text(role));
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setModalState(() {
                          selectedRole = value;
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 10),

                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Usuario activo'),
                    value: active,
                    onChanged: (value) {
                      setModalState(() {
                        active = value;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        if (isEditing) {
                          _updateUser(
                            user,
                            nameController.text,
                            emailController.text,
                            selectedRole,
                            active,
                          );
                        } else {
                          _addUser(
                            nameController.text,
                            emailController.text,
                            selectedRole,
                            active,
                          );
                        }

                        Navigator.pop(context);
                      },
                      child: Text(
                        isEditing ? 'Guardar cambios' : 'Agregar usuario',
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _addUser(String name, String email, String role, bool active) {
    setState(() {
      users.add(AppUser(name: name, email: email, role: role, active: active));
    });
  }

  void _updateUser(
    AppUser user,
    String name,
    String email,
    String role,
    bool active,
  ) {
    setState(() {
      user.name = name;
      user.email = email;
      user.role = role;
      user.active = active;
    });
  }
}
