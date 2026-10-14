import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:exploraec/main.dart';

void main() {
  testWidgets('Inicio muestra lugares y la barra cambia de pestaña', (WidgetTester tester) async {
    await tester.pumpWidget(const ExploraEcApp());

    // La lista de Inicio muestra los lugares de ejemplo.
    expect(find.text('Parque El Ejido'), findsOneWidget);

    // La barra inferior tiene las 3 secciones.
    expect(find.text('Inicio'), findsOneWidget);
    expect(find.text('Mapa'), findsOneWidget);
    expect(find.text('Favoritos'), findsOneWidget);

    // Tocar "Mapa" cambia el contenido.
    await tester.tap(find.text('Mapa'));
    await tester.pump();
    expect(find.text('Parque El Ejido'), findsNothing);
  });

  testWidgets('Tocar una tarjeta abre el Detalle', (WidgetTester tester) async {
    await tester.pumpWidget(const ExploraEcApp());

    await tester.tap(find.text('Parque El Ejido'));
    await tester.pumpAndSettle();

    expect(find.byType(BackButton), findsOneWidget);
  });

  testWidgets('El formulario vacío muestra errores y no se cierra', (WidgetTester tester) async {
    await tester.pumpWidget(const ExploraEcApp());

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guardar'));
    await tester.pump();

    expect(find.text('El nombre es obligatorio'), findsOneWidget);
    expect(find.text('La categoría es obligatoria'), findsOneWidget);
    expect(find.text('Escribe al menos 10 caracteres'), findsOneWidget);
  });
}
