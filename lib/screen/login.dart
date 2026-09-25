import 'package:flutter/material.dart';
import 'package:farma_di_mobile/widgets/routes.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';


abstract final class _Palette {
  static const ink = AppColors.ink;
  static const sheet = AppColors.sheet;
  static const accent = AppColors.accent;
  static const border = AppColors.border;
  static const muted = AppColors.muted; 
  static const hint = AppColors.hint;
  static const onInkMuted = AppColors.onInkMuted;
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  

  Future<void> _submit() async {
    if (_loading) return;
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);

    // Simulación visual: aquí irá la autenticación real.
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _Palette.ink,
        body: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const _Brand(),
                      Expanded(
                        child: _FormSheet(
                          bottomInset: bottomInset,
                          email: _email,
                          password: _password,
                          onSubmit: _submit,
                          loading: _loading,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 56, 24, 32),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _Palette.accent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.add_circle_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Farma-Di',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Sistema de Gestión Farmacéutica',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _Palette.onInkMuted,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _FormSheet extends StatelessWidget {
  const _FormSheet({
    required this.bottomInset,
    required this.email,
    required this.password,
    required this.onSubmit,
    required this.loading,
  });

  final double bottomInset;
  final TextEditingController email;
  final TextEditingController password;
  final VoidCallback onSubmit;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, 24, 20, 24 + bottomInset),
      decoration: const BoxDecoration(
        color: _Palette.sheet,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ACCEDER',
            style: TextStyle(
              color: _Palette.muted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.9,
            ),
          ),
          const SizedBox(height: 22),

          const _FieldLabel('Correo electrónico'),
          const SizedBox(height: 8),
          TextField(
            controller: email,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.username],
            cursorColor: _Palette.ink,
            style: _inputTextStyle,
            decoration: _inputDecoration('usuario@farmadi.com'),
          ),
          const SizedBox(height: 18),

          const _FieldLabel('Contraseña'),
          const SizedBox(height: 8),
          TextField(
            controller: password,
            obscureText: true,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            onSubmitted: (_) => onSubmit(),
            cursorColor: _Palette.ink,
            style: _inputTextStyle,
            decoration: _inputDecoration('••••••••'),
          ),

          
          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: loading ? null : onSubmit,
              style: FilledButton.styleFrom(
                backgroundColor: _Palette.ink,
                disabledBackgroundColor: _Palette.ink.withValues(alpha: 0.85),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: loading
                    ? const SizedBox(
                        key: ValueKey('loading'),
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Iniciar sesión', key: ValueKey('label')),
              ),
            ),
          ),
          const SizedBox(height: 22),

          const Center(
            child: Text(
              '¿Problemas para acceder? Contacta al administrador.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _Palette.muted,
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


const _inputTextStyle = TextStyle(
  color: _Palette.ink,
  fontSize: 14,
  fontWeight: FontWeight.w500,
);

InputDecoration _inputDecoration(String hint) {
  OutlineInputBorder border(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: width),
      );

  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(
      color: _Palette.hint,
      fontSize: 14,
      fontWeight: FontWeight.w400,
    ),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
    enabledBorder: border(_Palette.border),
    focusedBorder: border(_Palette.ink, 1.5),
  );
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: _Palette.ink,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

