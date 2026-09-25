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
            // _buildHeader(),

            const SizedBox(height: 16),

            //  _buildRoleFilters(),
            const SizedBox(height: 16),

            //Expanded(
            //   child: _buildUserList(),
            //),
          ],
        ),
      ),
    );
  }
}
