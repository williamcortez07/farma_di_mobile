import 'package:flutter/material.dart';
import 'package:farma_di_mobile/presentation/theme/app_colors.dart';

/// Campo de búsqueda para filtrar logs en tiempo real por texto
class LogSearchField extends StatelessWidget {
  const LogSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(
        fontSize: 14.0,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: 'Buscar por ID, ruta, IP, usuario o mensaje...',
        hintStyle: const TextStyle(
          color: AppColors.hint,
          fontSize: 13.5,
        ),
        prefixIcon: const Icon(
          Icons.search,
          color: AppColors.hint,
          size: 20.0,
        ),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(
                  Icons.clear,
                  color: AppColors.hint,
                  size: 18.0,
                ),
                onPressed: () {
                  controller.clear();
                  onClear();
                },
              )
            : null,
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14.0,
          horizontal: 14.0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}
