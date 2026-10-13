import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppNavbar extends StatelessWidget implements PreferredSizeWidget {
  const AppNavbar({super.key, this.onProfileTap, this.profileImageUrl});
  final VoidCallback? onProfileTap;
  final String? profileImageUrl;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('dd MM yyyy', 'es').format(DateTime.now());
    return AppBar(
      automaticallyImplyLeading: false,
      titleSpacing: 16,
      title: Text(
        date,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: IconButton(
            tooltip: 'perfil',
            onPressed: onProfileTap,
            icon: CircleAvatar(
              radius: 16,
              backgroundImage: profileImageUrl != null
                  ? NetworkImage(profileImageUrl!)
                  : null,
              child: profileImageUrl == null
                  ? const Icon(Icons.person, size: 18)
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
