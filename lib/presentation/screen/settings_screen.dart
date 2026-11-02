import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/di/injection.dart';
import '../../core/services/settings_controller.dart';
import '../providers/user_provider.dart';
import '../widgets/routes.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final UserProvider _userProvider;

  @override
  void initState() {
    super.initState();
    _userProvider = getIt<UserProvider>();
  }

  @override
  Widget build(BuildContext context) {
    final settings = SettingsController.instance;

    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        final theme = Theme.of(context);
        final colors = theme.colorScheme;

        return ListenableBuilder(
          listenable: _userProvider,
          builder: (context, _) {
            final user = _userProvider.user;

            return SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                children: [
                  Text(
                    'Ajustes',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Personaliza tu experiencia en Farma-DI',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Perfil del usuario cargado por la aplicación.
                  Card(
                    clipBehavior: Clip.antiAlias,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: colors.primary,
                            foregroundColor: colors.onPrimary,
                            child: Text(
                              user?.initials ?? 'U',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.fullName ?? 'Usuario Farma-DI',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  user?.mail ?? 'Correo no disponible',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user?.primaryRole ?? 'Usuario',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: colors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Ver perfil',
                            onPressed: () {
                              Navigator.of(context)
                                  .pushNamed(AppRoutes.profile);
                            },
                            icon: const Icon(Icons.open_in_new),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  const _SectionTitle('APARIENCIA'),
                  Card(
                    child: Column(
                      children: [
                        SwitchListTile(
                          secondary: const Icon(Icons.dark_mode_outlined),
                          title: const Text('Modo oscuro'),
                          subtitle: const Text(
                            'Usar colores oscuros en la aplicación',
                          ),
                          value: settings.isDarkMode,
                          onChanged: settings.setDarkMode,
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.text_fields),
                          title: const Text('Tamaño del texto'),
                          subtitle: Text(_textSizeLabel(settings.textSize)),
                          trailing: DropdownButton<String>(
                            value: settings.textSize,
                            underline: const SizedBox.shrink(),
                            items: const [
                              DropdownMenuItem(
                                value: 'small',
                                child: Text('Pequeño'),
                              ),
                              DropdownMenuItem(
                                value: 'normal',
                                child: Text('Normal'),
                              ),
                              DropdownMenuItem(
                                value: 'large',
                                child: Text('Grande'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                settings.setTextSize(value);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  const _SectionTitle('NOTIFICACIONES'),
                  Card(
                    child: SwitchListTile(
                      secondary: const Icon(
                        Icons.notifications_active_outlined,
                      ),
                      title: const Text('Notificaciones'),
                      subtitle: Text(
                        settings.notificationsEnabled
                            ? 'Preferencia activada en este dispositivo'
                            : 'Preferencia desactivada',
                      ),
                      value: settings.notificationsEnabled,
                      onChanged: settings.setNotificationsEnabled,
                    ),
                  ),

                  const SizedBox(height: 20),
                  const _SectionTitle('INFORMACIÓN DE LA APLICACIÓN'),
                  Card(
                    child: Column(
                      children: [
                        const ListTile(
                          leading: Icon(Icons.info_outline),
                          title: Text('Aplicación'),
                          subtitle: Text('Farma-DI'),
                        ),
                        const Divider(height: 1),
                        const ListTile(
                          leading: Icon(Icons.numbers),
                          title: Text('Versión'),
                          subtitle: Text('1.0.0+1'),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.devices_outlined),
                          title: const Text('Plataforma'),
                          subtitle: Text(_platformName()),
                        ),
                        const Divider(height: 1),
                        const ListTile(
                          leading: Icon(Icons.cloud_outlined),
                          title: Text('Conexión con la API'),
                          subtitle: Text(
                            'El estado se verifica al consultar los módulos',
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  const _SectionTitle('RESTABLECER'),
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.restart_alt, color: colors.error),
                      title: const Text('Restablecer preferencias'),
                      subtitle: const Text(
                        'Volver al tema claro y al texto normal',
                      ),
                      onTap: _confirmReset,
                    ),
                  ),

                  const SizedBox(height: 28),
                  SizedBox(
                    height: 50,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: colors.error,
                        foregroundColor: colors.onError,
                      ),
                      onPressed: _logout,
                      icon: const Icon(Icons.logout),
                      label: const Text('Cerrar sesión'),
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

  String _textSizeLabel(String value) {
    switch (value) {
      case 'small':
        return 'Pequeño';
      case 'large':
        return 'Grande';
      default:
        return 'Normal';
    }
  }

  String _platformName() {
    if (kIsWeb) return 'Web';

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'Android';
      case TargetPlatform.iOS:
        return 'iOS';
      case TargetPlatform.windows:
        return 'Windows';
      case TargetPlatform.macOS:
        return 'macOS';
      case TargetPlatform.linux:
        return 'Linux';
      case TargetPlatform.fuchsia:
        return 'Fuchsia';
    }
  }

  Future<void> _confirmReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Restablecer preferencias'),
          content: const Text(
            'Se restaurarán el tema claro, el texto normal y las '
            'notificaciones activadas. No se eliminarán los datos '
            'de la farmacia ni se cerrará la sesión.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Restablecer'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    await SettingsController.instance.reset();

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Preferencias restablecidas')));
  }

  Future<void> _logout() async {
    try {
      await _userProvider.logout();

      if (!mounted) return;

      Navigator.of(context)
          .pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo cerrar la sesión')),
      );
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
          color: colors.primary,
        ),
      ),
    );
  }
}
