// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chatbot/main.dart';
import 'package:chatbot/nutri_calculator_service.dart';

void main() {
  test('acepta varias unidades al ingresar la altura para el IMC', () {
    for (final altura in ['180 cm', '180cm', '1.80m', '1.80 m']) {
      final service = NutriCalculatorService();
      service.procesarMensaje('IMC');
      service.procesarMensaje('sí');
      service.procesarMensaje('65');

      expect(
        service.procesarMensaje(altura),
        contains('Tu IMC es 20.1'),
        reason: 'La altura "$altura" debe convertirse correctamente.',
      );
    }
  });

  test('acepta el peso en kg con distintas mayúsculas y espacios', () {
    for (final peso in ['55Kg', '55kg', '44 Kg', '44 kg']) {
      final service = NutriCalculatorService();
      service.procesarMensaje('IMC');
      service.procesarMensaje('sí');

      expect(
        service.procesarMensaje(peso),
        contains('Ahora dime tu altura'),
        reason: 'El peso "$peso" debe aceptarse como kilogramos.',
      );
    }
  });

  test('acepta el peso en libras con distintas abreviaturas', () {
    for (final peso in ['150 lb', '150lbs', '150 libras']) {
      final service = NutriCalculatorService();
      service.procesarMensaje('IMC');
      service.procesarMensaje('sí');

      expect(
        service.procesarMensaje(peso),
        contains('Ahora dime tu altura'),
        reason: 'El peso "$peso" debe aceptarse como libras.',
      );
    }
  });

  test('muestra el peso convertido a kg si se ingresó en libras', () {
    for (final altura in ["5'10\"", '5 pies 10 pulgadas']) {
      final service = NutriCalculatorService();
      service.procesarMensaje('IMC');
      service.procesarMensaje('sí');
      service.procesarMensaje('150 lb');

      expect(
        service.procesarMensaje(altura),
        contains('El peso convertido es 68.0 kg. Tu IMC es 21.5'),
        reason: 'La altura "$altura" debe convertirse correctamente.',
      );
    }
  });

  test('no agrega conversión de peso si se ingresó en kg', () {
    final service = NutriCalculatorService();
    service.procesarMensaje('IMC');
    service.procesarMensaje('sí');
    service.procesarMensaje('68 kg');

    final resultado = service.procesarMensaje('1.78 m');

    expect(resultado, contains('Tu IMC es 21.5'));
    expect(resultado, isNot(contains('peso convertido')));
  });

  test('acepta la edad con o sin espacio y no muestra el nombre de la fórmula',
      () {
    for (final edad in ['25años', '25 años']) {
      final service = NutriCalculatorService();
      service.procesarMensaje('GET');
      service.procesarMensaje('sí');
      service.procesarMensaje('hombre');
      service.procesarMensaje('70 kg');
      service.procesarMensaje('1.70 m');

      expect(
        service.procesarMensaje(edad),
        contains('nivel de actividad'),
        reason: 'La edad "$edad" debe aceptarse.',
      );

      final resultado = service.procesarMensaje('1');
      expect(resultado, contains('2300 kcal/día'));
      expect(resultado, isNot(contains('Mifflin-St Jeor')));
    }
  });

  void configureTestView(WidgetTester tester) {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<void> sendMessage(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextField), text);
    await tester.tap(find.byTooltip('Enviar mensaje'));
    await tester.pumpAndSettle();
  }

  testWidgets('calcula y muestra el IMC', (WidgetTester tester) async {
    configureTestView(tester);
    await tester.pumpWidget(const NutriApp());
    expect(find.byTooltip('Recordatorio de agua'), findsNothing);

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
    await sendMessage(tester, 'no');
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tu Gasto Energético Total (GET)'),
      findsOneWidget,
    );
  });
}
