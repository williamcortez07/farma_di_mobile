
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

import '../settings/app_preferences.dart';
import '../theme/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _checkingConnection = false;
  bool? _connectionOk;
  String _version = 'Consultando...';
  String _platform = 'Consultando...';

  bool get _isEnglish => AppPreferences.locale.value.languageCode == 'en';

  String _t(String es, String en) => _isEnglish ? en : es;

  @override
  void initState() {
    super.initState();
    _loadSystemInfo();
    _checkConnection();
  }

  Future<void> _loadSystemInfo() async {
    String version;
    String platform;

    try {
      final info = await PackageInfo.fromPlatform();
      version = '${info.version}+${info.buildNumber}';
    } catch (_) {
      version = '1.0.0+1';
    }

    if (kIsWeb) {
      platform = 'Web';
    } else {
      try {
        if (Platform.isAndroid) {
          platform = 'Android';
        } else if (Platform.isIOS) {
          platform = 'iOS';
        } else if (Platform.isWindows) {
          platform = 'Windows';
        } else if (Platform.isMacOS) {
          platform = 'macOS';
        } else if (Platform.isLinux) {
          platform = 'Linux';
        } else {
          platform = _t('Desconocida', 'Unknown');
        }
      } catch (_) {
        platform = _t('Desconocida', 'Unknown');
      }
    }

    if (!mounted) return;
    setState(() {
      _version = version;
      _platform = platform;
    });
  }

  String _getBaseUrl() {
    final configured = dotenv.env['API_BASE_URL'] ??
        dotenv.env['BASE_URL'] ??
        dotenv.env['API_URL'];

    final value = configured?.trim();

    if (value != null && value.isNotEmpty) {
      return value.replaceFirst(RegExp(r'/+$'), '');
    }

    return 'https://api-cloud-farmadi-gqancxgqhucfegfb.westus3-01.azurewebsites.net';
  }

  Future<void> _checkConnection() async {
    if (_checkingConnection) return;

    setState(() {
      _checkingConnection = true;
    });

    bool connected = false;

    try {
      final uri = Uri.parse(_getBaseUrl());
      final response = await http
          .get(uri)
          .timeout(const Duration(seconds: 8));

      // Una respuesta HTTP, incluso 404/405, confirma que el servidor responde.
      connected = response.statusCode < 500;
    } catch (_) {
      connected = false;
    }

    if (!mounted) return;

    setState(() {
      _connectionOk = connected;
      _checkingConnection = false;
    });
  }

  Future<void> _resetPreferences() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(_t('Restablecer preferencias', 'Reset preferences')),
        content: Text(
          _t(
            'Se restaurarán el tema claro, el idioma español y el tamaño de texto normal. Esta acción no eliminará tu sesión ni los datos de la cuenta.',
            'The light theme, Spanish language and normal text size will be restored. This will not delete your session or account data.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(_t('Cancelar', 'Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(_t('Restablecer', 'Reset')),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await AppPreferences.reset();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _t(
            'Las preferencias se restablecieron.',
            'Preferences have been reset.',
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          Text(
            _t('Ajustes', 'Settings'),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _t(
              'Personaliza tu experiencia en Farma-DI.',
              'Customize your Farma-DI experience.',
            ),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          _SectionHeader(
            title: _t('APARIENCIA', 'APPEARANCE'),
          ),
          _SettingsCard(
            children: [
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                secondary: Icon(
                  isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                  color: AppColors.primary,
                ),
                title: Text(_t('Tema oscuro', 'Dark theme')),
                subtitle: Text(
                  _t(
                    'Cambiar entre el tema claro y oscuro.',
                    'Switch between light and dark themes.',
                  ),
                ),
                value: isDark,
                onChanged: (value) => AppPreferences.setDarkMode(value),
              ),
              const _SettingsDivider(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.text_fields,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _t('Tamaño del texto', 'Text size'),
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ValueListenableBuilder<double>(
                      valueListenable: AppPreferences.textScale,
                      builder: (context, scale, _) {
                        final selected = scale < 0.95
                            ? 'small'
                            : scale > 1.05
                                ? 'large'
                                : 'normal';

                        return SegmentedButton<String>(
                          segments: [
                            ButtonSegment(
                              value: 'small',
                              label: Text(_t('Pequeño', 'Small')),
                            ),
                            ButtonSegment(
                              value: 'normal',
                              label: Text(_t('Normal', 'Normal')),
                            ),
                            ButtonSegment(
                              value: 'large',
                              label: Text(_t('Grande', 'Large')),
                            ),
                          ],
                          selected: {selected},
                          onSelectionChanged: (values) {
                            final value = values.first;
                            final size = value == 'small'
                                ? 0.90
                                : value == 'large'
                                    ? 1.12
                                    : 1.0;

                            AppPreferences.setTextScale(size);
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _t(
                        'El cambio se aplica a los textos de la aplicación.',
                        'The change applies to app text.',
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),
          _SectionHeader(
            title: _t('PREFERENCIAS', 'PREFERENCES'),
          ),
          _SettingsCard(
            children: [
              ListTile(
                leading: const Icon(
                  Icons.language,
                  color: AppColors.primary,
                ),
                title: Text(_t('Idioma', 'Language')),
                subtitle: Text(
                  _isEnglish ? 'English' : 'Español',
                ),
                trailing: SizedBox(
                  width: 125,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _isEnglish ? 'en' : 'es',
                      items: [
                        DropdownMenuItem(
                          value: 'es',
                          child: Text(
                            'Español',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'en',
                          child: Text(
                            'English',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          AppPreferences.setLanguage(value);
                        }
                      },
                    ),
                  ),
                ),
              ),
              const _SettingsDivider(),
              ListTile(
                leading: const Icon(
                  Icons.calendar_month_outlined,
                  color: AppColors.primary,
                ),
                title: Text(_t('Formato de fecha', 'Date format')),
                subtitle: Text(
                  _t(
                    'Formato fijo: dd/MM/yyyy',
                    'Fixed format: dd/MM/yyyy',
                  ),
                ),
                trailing: const Icon(Icons.lock_outline, size: 18),
              ),
            ],
          ),

          const SizedBox(height: 22),
          _SectionHeader(
            title: _t('ESTADO DEL SISTEMA', 'SYSTEM STATUS'),
          ),
          _SettingsCard(
            children: [
              ListTile(
                leading: Icon(
                  _connectionOk == null
                      ? Icons.cloud_outlined
                      : _connectionOk!
                          ? Icons.cloud_done_outlined
                          : Icons.cloud_off_outlined,
                  color: _connectionOk == true
                      ? Colors.green
                      : _connectionOk == false
                          ? theme.colorScheme.error
                          : AppColors.primary,
                ),
                title: Text(_t('Conexión con la API', 'API connection')),
                subtitle: Text(
                  _checkingConnection
                      ? _t('Comprobando conexión...', 'Checking connection...')
                      : _connectionOk == null
                          ? _t('Estado sin comprobar', 'Status not checked')
                          : _connectionOk!
                              ? _t('Servidor accesible', 'Server reachable')
                              : _t('Sin conexión con el servidor', 'Server unreachable'),
                ),
                trailing: IconButton(
                  tooltip: _t('Comprobar de nuevo', 'Check again'),
                  onPressed: _checkingConnection ? null : _checkConnection,
                  icon: _checkingConnection
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                ),
              ),
              const _SettingsDivider(),
              ListTile(
                leading: const Icon(
                  Icons.info_outline,
                  color: AppColors.primary,
                ),
                title: Text(_t('Versión de la aplicación', 'App version')),
                subtitle: Text(_version),
              ),
              const _SettingsDivider(),
              ListTile(
                leading: const Icon(
                  Icons.devices_outlined,
                  color: AppColors.primary,
                ),
                title: Text(_t('Plataforma', 'Platform')),
                subtitle: Text(_platform),
              ),
            ],
          ),

          const SizedBox(height: 22),
          _SectionHeader(
            title: _t('MANTENIMIENTO', 'MAINTENANCE'),
          ),
          _SettingsCard(
            children: [
              ListTile(
                leading: Icon(
                  Icons.restart_alt,
                  color: theme.colorScheme.error,
                ),
                title: Text(_t('Restablecer preferencias', 'Reset preferences')),
                subtitle: Text(
                  _t(
                    'Volver a los valores predeterminados.',
                    'Restore default preferences.',
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: _resetPreferences,
              ),
            ],
          ),

          const SizedBox(height: 24),
          Center(
            child: Text(
              'Farma-DI · $_version',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9, left: 2),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.55),
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 16,
      endIndent: 16,
      color: Theme.of(context).dividerColor,
    );
  }
}
