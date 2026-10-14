import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:exploraec/main.dart';
import 'package:exploraec/widgets/empty_view.dart';
import 'package:exploraec/widgets/error_view.dart';
import 'package:exploraec/widgets/loading_view.dart';

/// Arranca la app y espera a que termine la carga simulada (1 s).
Future<void> abrirApp(WidgetTester tester) async {
  await tester.pumpWidget(const ExploraEcApp());
  await tester.pump(const Duration(seconds: 1));
  await tester.pumpAndSettle();
}

Future<void> simular(WidgetTester tester, String opcion) async {
  await tester.tap(find.byType(PopupMenuButton<String>));
  await tester.pumpAndSettle();
  await tester.tap(find.text(opcion));
  await tester.pump(); // dibuja el frame para que FutureBuilder se suscriba
  await tester.pump(const Duration(seconds: 1));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Inicio muestra carga y luego los lugares', (WidgetTester tester) async {
    await tester.pumpWidget(const ExploraEcApp());
    expect(find.byType(LoadingView), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('Parque El Ejido'), findsOneWidget);
  });

  testWidgets('El menú ⋮ muestra los estados vacío, error y normal', (WidgetTester tester) async {
    await abrirApp(tester);

    await simular(tester, 'Simular: vacío');
    expect(find.byType(EmptyView), findsOneWidget);

    await simular(tester, 'Simular: error');
    expect(find.byType(ErrorView), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);

    // Reintentar con el modo error activo vuelve a fallar.
    await tester.tap(find.text('Reintentar'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.byType(ErrorView), findsOneWidget);

    await simular(tester, 'Simular: normal');
    expect(find.text('Parque El Ejido'), findsOneWidget);
  });

  testWidgets('Pantalla ancha usa GridView sin overflow', (WidgetTester tester) async {
    for (final ancho in [650.0, 950.0]) {
      tester.view.physicalSize = Size(ancho, 800);
      tester.view.devicePixelRatio = 1;
      await abrirApp(tester);
      expect(find.byType(GridView), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
    addTearDown(tester.view.reset);
  });

  testWidgets('PlaceCard expone un solo label semántico de botón', (WidgetTester tester) async {
    final semantics = tester.ensureSemantics();
    await abrirApp(tester);

    expect(
      find.bySemanticsLabel('Parque El Ejido, categoría Parques'),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('La barra inferior cambia de pestaña', (WidgetTester tester) async {
    await abrirApp(tester);

    await tester.tap(find.text('Mapa'));
    await tester.pumpAndSettle();
    expect(find.text('Parque El Ejido'), findsNothing);
  });

  testWidgets('Tocar una tarjeta abre el Detalle', (WidgetTester tester) async {
    await abrirApp(tester);

    await tester.tap(find.text('Parque El Ejido'));
    await tester.pumpAndSettle();
    expect(find.byType(BackButton), findsOneWidget);
  });

  testWidgets('El formulario vacío muestra errores y no se cierra', (WidgetTester tester) async {
    await abrirApp(tester);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guardar'));
    await tester.pump();

    expect(find.text('El nombre es obligatorio'), findsOneWidget);
    expect(find.text('La categoría es obligatoria'), findsOneWidget);
    expect(find.text('Escribe al menos 10 caracteres'), findsOneWidget);
  });
}
