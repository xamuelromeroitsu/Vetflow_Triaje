// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vetflow_triaje/app/app.dart';
import 'package:vetflow_triaje/app/router/app_router.dart';

void main() {
  testWidgets('smoke test renders app shell', (WidgetTester tester) async {
    final router = createAppRouter(hasSession: () => false);
    addTearDown(router.dispose);

    await tester.pumpWidget(VetFlowApp(router: router));

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(
      find.text('Atención médica y triaje rápido para tu mascota'),
      findsOneWidget,
    );
  });

  testWidgets('pet registration route opens the pets feature form', (
    WidgetTester tester,
  ) async {
    final router = createAppRouter(hasSession: () => true);
    addTearDown(router.dispose);

    await tester.pumpWidget(VetFlowApp(router: router));
    router.go('/pets/register');
    await tester.pumpAndSettle();

    expect(find.text('Registrar Nueva Mascota'), findsOneWidget);
  });
}
