import 'package:flutter/material.dart';

import '../theme/app_colors.dart';


const Color _dividerColor = Color(0xFFEDEFF3);

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          const Text('Preferencias', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Personaliza tu experiencia en Farma-Di', style: TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.profileCard, borderRadius: BorderRadius.circular(18)),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                  child: const Text('AG', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ana García', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.5)),
                      SizedBox(height: 2),
                      Text('a.garcia@farmadi.com', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      SizedBox(height: 2),
                      Text('Administrador · Activo',
                          style: TextStyle(color: AppColors.success, fontSize: 11.5, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => _openEditProfileModal(context),
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Editar', style: TextStyle(fontSize: 12.5)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const _SectionHeader('NOTIFICACIONES'),
          _SettingsCard(children: [
            _SwitchRow('Notificaciones push', 'Alertas en tiempo real en la app', true),
            _SwitchRow('Alertas de stock bajo', 'Avisar cuando el stock caiga por debajo del mínimo', true),
            _SwitchRow('Reportes por correo', 'Resumen diario enviado a tu email', false),
          ]),
          const SizedBox(height: 18),
          const _SectionHeader('APARIENCIA'),
          _SettingsCard(children: [
            _SwitchRow('Modo oscuro', 'Cambiar al tema oscuro del sistema', false),
            _SwitchRow('Vista compacta', 'Reducir espaciado en listas y tablas', false),
          ]),
          const SizedBox(height: 18),
          const _SectionHeader('SISTEMA'),
          _SettingsCard(children: [
            _SwitchRow('Backup automático', 'Respaldo diario a las 01:00 a.m.', true),
            _SwitchRow('Telemetría de uso', 'Enviar datos de uso para mejorar el sistema', true),
          ]),
          const SizedBox(height: 18),
          const _SectionHeader('SEGURIDAD'),
          _SettingsCard(children: [
            _SwitchRow('Autenticación en 2 pasos', 'Requiere código por SMS al iniciar sesión', false),
            _SwitchRow('Cierre de sesión automático', 'Tras 30 min de inactividad', true),
          ]),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Farma-Di v2.4.1', style: TextStyle(fontSize: 11, color: Colors.grey)),
              Text('build 20250823', style: TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                backgroundColor: AppColors.redSoft,
                foregroundColor: AppColors.red,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Cerrar sesión', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  void _openEditProfileModal(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _EditProfileModal(),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(title,
          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Colors.grey, letterSpacing: 0.5)),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final withDividers = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) {
        withDividers.add(const Divider(height: 1, color: _dividerColor));
      }
      withDividers.add(children[i]);
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Column(children: withDividers),
    );
  }
}

class _SwitchRow extends StatefulWidget {
  final String title;
  final String subtitle;
  final bool initialValue;
  const _SwitchRow(this.title, this.subtitle, this.initialValue);

  @override
  State<_SwitchRow> createState() => _SwitchRowState();
}

class _SwitchRowState extends State<_SwitchRow> {
  late bool _value = widget.initialValue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.title, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(widget.subtitle, style: const TextStyle(fontSize: 12.5, color: Colors.grey)),
              ],
            ),
          ),
          Switch(value: _value, onChanged: (v) => setState(() => _value = v)),
        ],
      ),
    );
  }
}

// ============================================================
// MODAL "DETALLE Y EDICIÓN DE USUARIO"
// ============================================================

const Color _modalMuted = Color(0xFF7A858D);
const Color _modalBorder = Color(0xFFE3E8EC);
const Color _modalInfoBg = Color(0xFFEAF4FB);

class _EditProfileModal extends StatefulWidget {
  const _EditProfileModal();

  @override
  State<_EditProfileModal> createState() => _EditProfileModalState();
}

class _EditProfileModalState extends State<_EditProfileModal> {
  final _nombreCtrl = TextEditingController(text: 'Ana');
  final _apellidoCtrl = TextEditingController(text: 'García');
  final _correoCtrl = TextEditingController(text: 'a.garcia@farmadi.com');
  final _telefonoCtrl = TextEditingController(text: '+505 8890-4321');
  String _rol = 'Administrador';
  bool _cuentaActiva = true;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _apellidoCtrl.dispose();
    _correoCtrl.dispose();
    _telefonoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _modalBorder,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.circle, size: 8, color: AppColors.primary),
                              SizedBox(width: 8),
                              Text('Detalle log',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _Pill(text: 'Activo', color: AppColors.success),
                          const SizedBox(width: 8),
                          const _Pill(text: 'USR-001', color: _modalMuted),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 26,
                            backgroundColor: AppColors.profileCard,
                            child: Text('AG',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Ana García',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              SizedBox(height: 3),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today, size: 11, color: _modalMuted),
                                  SizedBox(width: 4),
                                  Text('Miembro desde: Ene 2023',
                                      style: TextStyle(fontSize: 11.5, color: _modalMuted)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Expanded(child: _FieldLabel('Nombre', required: true)),
                          const SizedBox(width: 12),
                          Expanded(child: _FieldLabel('Apellido', required: true)),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(child: _TextField(controller: _nombreCtrl)),
                          const SizedBox(width: 12),
                          Expanded(child: _TextField(controller: _apellidoCtrl)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const _FieldLabel('Correo institucional', required: true),
                      _TextField(controller: _correoCtrl, icon: Icons.mail_outline),
                      const SizedBox(height: 16),
                      const _FieldLabel('Teléfono corporativo'),
                      _TextField(controller: _telefonoCtrl, icon: Icons.phone_outlined),
                      const SizedBox(height: 16),
                      const _FieldLabel('Rol en farmacia', required: true),
                      _RoleDropdown(
                        value: _rol,
                        onChanged: (v) => setState(() => _rol = v),
                      ),
                      const SizedBox(height: 18),
                      _AccountStatusRow(
                        active: _cuentaActiva,
                        onChanged: (v) => setState(() => _cuentaActiva = v),
                      ),
                      const SizedBox(height: 14),
                      const _PermissionsInfo(),
                      const SizedBox(height: 12),
                      const Row(
                        children: [
                          Icon(Icons.access_time, size: 13, color: _modalMuted),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Última sesión: Hoy a las 08:30 AM (Mostrador Principal)',
                              style: TextStyle(fontSize: 11.5, color: _modalMuted),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: _modalMuted,
                                side: const BorderSide(color: _modalBorder),
                                padding: const EdgeInsets.symmetric(vertical: 13),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('Cancelar'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.check, size: 16),
                              label: const Text('Guardar Cambios'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.profileCard,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 13),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
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
        },
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final Color color;
  const _Pill({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  final bool required;
  const _FieldLabel(this.text, {this.required = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Colors.black87),
          children: [
            TextSpan(text: text),
            if (required) const TextSpan(text: ' *', style: TextStyle(color: AppColors.red)),
          ],
        ),
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final IconData? icon;
  const _TextField({required this.controller, this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 13.5),
        decoration: InputDecoration(
          prefixIcon: icon != null ? Icon(icon, size: 18, color: _modalMuted) : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _modalBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
          ),
        ),
      ),
    );
  }
}

class _RoleDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const _RoleDropdown({required this.value, required this.onChanged});

  static const _roles = ['Administrador', 'Vendedor', 'Farmacéutico'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: _modalBorder),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: _modalMuted),
          items: _roles
              .map((r) => DropdownMenuItem(
                    value: r,
                    child: Row(
                      children: [
                        const Icon(Icons.badge_outlined, size: 16, color: _modalMuted),
                        const SizedBox(width: 8),
                        Text(r, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ))
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

class _AccountStatusRow extends StatelessWidget {
  final bool active;
  final ValueChanged<bool> onChanged;
  const _AccountStatusRow({required this.active, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.toggle_on_outlined, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Estado de cuenta',
                    style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                Text(
                  active ? 'Activo - Acceso permitido' : 'Inactivo - Acceso bloqueado',
                  style: const TextStyle(fontSize: 11.5, color: _modalMuted),
                ),
              ],
            ),
          ),
          Switch(value: active, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _PermissionsInfo extends StatelessWidget {
  const _PermissionsInfo();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _modalInfoBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_outlined, size: 16, color: AppColors.primary),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Permisos asignados',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.primary)),
                SizedBox(height: 3),
                Text(
                  'Acceso total: Ventas, Compras, Catálogo, Métricas, Logs y Configuración.',
                  style: TextStyle(fontSize: 11.5, color: Color(0xFF3A6E8F)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}