import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppNavbar extends StatelessWidget implements PreferredSizeWidget {
  const AppNavbar({
    super.key,
    this.onProfileTap,
    this.profileImageUrl,
    this.userInitials,
    this.userName,
  });

  final VoidCallback? onProfileTap;
  final String? profileImageUrl;
  final String? userInitials;
  final String? userName;

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
            tooltip: userName != null && userName!.isNotEmpty
                ? 'Perfil de $userName'
                : 'Perfil',
            onPressed: onProfileTap,
            icon: CircleAvatar(
              radius: 16,
              backgroundImage: profileImageUrl != null
                  ? NetworkImage(profileImageUrl!)
                  : null,
              child: profileImageUrl != null
                  ? null
                  : (userInitials != null && userInitials!.isNotEmpty
                      ? Text(
                          userInitials!,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      : const Icon(Icons.person, size: 18)),
            ),
          ),
        ),
      ],
    );
  }
}
