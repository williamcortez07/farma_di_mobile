import 'package:flutter/material.dart';

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
            decoration: BoxDecoration(color: const Color(0xFF1E293F), borderRadius: BorderRadius.circular(18)),
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
                          style: TextStyle(color: Color(0xFF16A34A), fontSize: 11.5, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF2F6FE4),
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
                backgroundColor: const Color(0xFFFDEDEC),
                foregroundColor: const Color(0xFFE0645F),
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
      if (i > 0) withDividers.add(const Divider(height: 1, color: Color(0xFFEDEFF3)));
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