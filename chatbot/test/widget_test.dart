// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chatbot/main.dart';

void main() {
  void configureTestView(WidgetTester tester) {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<void> sendMessage(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextField), text);
    await tester.tap(find.byTooltip('Enviar mensaje'));
    await tester.pump(const Duration(milliseconds: 500));
  }

  testWidgets('calcula y muestra el IMC', (WidgetTester tester) async {
    configureTestView(tester);
    await tester.pumpWidget(const NutriApp());

    await tester.tap(find.text('Calcular mi IMC'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.textContaining('¿Quieres calcular tu IMC?'), findsOneWidget);

    await sendMessage(tester, 'sí');
    expect(find.textContaining('¿Cuál es tu peso'), findsOneWidget);
    await sendMessage(tester, '65');
    expect(find.textContaining('dime tu altura'), findsOneWidget);
    await sendMessage(tester, '1.70');
    expect(find.textContaining('Tu IMC es 22.5'), findsOneWidget);
  });

  testWidgets('calcula y muestra el GET', (WidgetTester tester) async {
    configureTestView(tester);
    await tester.pumpWidget(const NutriApp());

    await tester.tap(find.text('Calcular mi GET'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.textContaining('¿Quieres calcular el tuyo?'), findsOneWidget);

    await sendMessage(tester, 'sí');
    expect(find.textContaining('dime tu sexo'), findsOneWidget);
    await sendMessage(tester, 'hombre');
    await sendMessage(tester, '70');
    await sendMessage(tester, '1.70');
    await sendMessage(tester, '25');
    await sendMessage(tester, '1');
    await sendMessage(tester, '2');
    await sendMessage(tester, 'no');
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tu Gasto Energético Total (GET)'),
      findsOneWidget,
    );
  });
}
