import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:farma_di_mobile/presentation/screen/roles_screen.dart';

Future<void> _scrollToModalAction(WidgetTester tester, Finder target) {
  final modalScrollable = find.descendant(
    of: find.byType(ListView).at(1),
    matching: find.byType(Scrollable),
  );
  return tester.scrollUntilVisible(
    target,
    200,
    scrollable: modalScrollable.first,
  );
}

void _usePortraitViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  testWidgets('guardar muestra éxito sin una excepción Flutter', (
    WidgetTester tester,
  ) async {
    _usePortraitViewport(tester);
    await tester.pumpWidget(const MaterialApp(home: RolesScreen()));
    await tester.tap(find.text('Carlos Méndez'));
    await tester.pumpAndSettle();

    final saveButton = find.text('Guardar Cambios');
    await _scrollToModalAction(tester, saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(find.text('Cambios guardados correctamente.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cancelar muestra aviso sin una excepción Flutter', (
    WidgetTester tester,
  ) async {
    _usePortraitViewport(tester);
    await tester.pumpWidget(const MaterialApp(home: RolesScreen()));
    await tester.tap(find.text('Carlos Méndez'));
    await tester.pumpAndSettle();

    final cancelButton = find.text('Cancelar');
    await _scrollToModalAction(tester, cancelButton);
    await tester.tap(cancelButton);
    await tester.pumpAndSettle();

    expect(find.text('Operación cancelada.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('formulario inválido muestra una alerta sin cerrarse', (
    WidgetTester tester,
  ) async {
    _usePortraitViewport(tester);
    await tester.pumpWidget(const MaterialApp(home: RolesScreen()));
    await tester.tap(find.text('Agregar'));
    await tester.pumpAndSettle();

    final saveButton = find.text('Agregar usuario');
    await _scrollToModalAction(tester, saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(
      find.text('Revisa los campos marcados antes de guardar.'),
      findsOneWidget,
    );
    expect(find.text('Nuevo usuario'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
