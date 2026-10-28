
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:farma_di_mobile/presentation/widgets/routes.dart';
import 'package:farma_di_mobile/core/di/injection.dart';
import 'package:farma_di_mobile/presentation/controllers/auth_controler.dart';

import '../settings/app_preferences.dart';
import '../theme/app_colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _user = TextEditingController();
  final _password = TextEditingController();
  late final AuthController _auth = getIt<AuthController>();

  bool get _isEnglish =>
      AppPreferences.locale.value.languageCode == 'en';

  String _t(String es, String en) => _isEnglish ? en : es;

  @override
  void dispose() {
    _user.dispose();
    _password.dispose();
    _auth.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_auth.status == AuthStatus.loading) return;

    FocusScope.of(context).unfocus();

    final user = _user.text.trim();
    final password = _password.text;

    if (user.isEmpty || password.isEmpty) {
      _showError(
        _t(
          'Ingresa tu nombre de usuario y contraseña.',
          'Enter your username and password.',
        ),
      );
      return;
    }

    final ok = await _auth.login(user, password);

    if (!mounted) return;

    if (ok) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    } else {
      _showError(
        _auth.errorMessage ??
            _t(
              'Ocurrió un error inesperado.',
              'An unexpected error occurred.',
            ),
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final isDark = theme.brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      _Brand(isEnglish: _isEnglish),
                      Expanded(
                        child: _FormSheet(
                          bottomInset: bottomInset,
                          user: _user,
                          password: _password,
                          onSubmit: _submit,
                          loading: _auth.status == AuthStatus.loading,
                          isEnglish: _isEnglish,
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
  const _Brand({required this.isEnglish});

  final bool isEnglish;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 56, 24, 32),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.add_circle_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Farma-Di',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: scheme.onSurface,
              fontSize: 26,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isEnglish
                ? 'Pharmacy Management System'
                : 'Sistema de Gestión Farmacéutica',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
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
    required this.user,
    required this.password,
    required this.onSubmit,
    required this.loading,
    required this.isEnglish,
  });

  final double bottomInset;
  final TextEditingController user;
  final TextEditingController password;
  final VoidCallback onSubmit;
  final bool loading;
  final bool isEnglish;

  String _t(String es, String en) => isEnglish ? en : es;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final fieldFill = isDark
        ? scheme.surfaceContainerHighest
        : Colors.white;

    final fieldBorder = theme.dividerColor;
    final textColor = scheme.onSurface;
    final mutedColor = scheme.onSurfaceVariant;

    OutlineInputBorder border(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    InputDecoration decoration(String hint) {
      return InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: mutedColor,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: fieldFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),
        enabledBorder: border(fieldBorder),
        focusedBorder: border(AppColors.primary, 1.5),
      );
    }

    final inputStyle = TextStyle(
      color: textColor,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20,
        24,
        20,
        24 + bottomInset,
      ),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _t('ACCEDER', 'SIGN IN'),
            style: theme.textTheme.labelLarge?.copyWith(
              color: mutedColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.9,
            ),
          ),
          const SizedBox(height: 22),
          _FieldLabel(
            _t('Nombre de usuario', 'Username'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: user,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.username],
            cursorColor: AppColors.primary,
            style: inputStyle,
            decoration: decoration(
              _t('nombre_de_usuario', 'username'),
            ),
          ),
          const SizedBox(height: 18),
          _FieldLabel(
            _t('Contraseña', 'Password'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: password,
            obscureText: true,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            onSubmitted: (_) => onSubmit(),
            cursorColor: AppColors.primary,
            style: inputStyle,
            decoration: decoration('••••••••'),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: loading ? null : onSubmit,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor:
                    AppColors.primary.withValues(alpha: 0.65),
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
                    : Text(
                        _t('Iniciar sesión', 'Sign in'),
                        key: const ValueKey('label'),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 22),
          Center(
            child: Text(
              _t(
                '¿Problemas para acceder? Contacta al administrador.',
                'Having trouble signing in? Contact your administrator.',
              ),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: mutedColor,
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

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
    );
  }
}
