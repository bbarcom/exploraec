import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:exploraec/main.dart';
import 'package:exploraec/models/place.dart';
import 'package:exploraec/theme/theme_controller.dart';
import 'package:exploraec/widgets/empty_view.dart';
import 'package:exploraec/widgets/error_view.dart';
import 'package:exploraec/widgets/loading_view.dart';

/// Arranca la app y espera a que termine la carga simulada (1 s).
Future<void> abrirApp(WidgetTester tester) async {
  await tester.pumpWidget(const ExploraEcApp());
  await tester.pump(const Duration(seconds: 1));
  await tester.pumpAndSettle();
}

/// Deja pasar los Get.snackbar (duran 3 s) para no dejar timers pendientes.
Future<void> cerrarAvisos(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 4));
  await tester.pumpAndSettle();
}

Future<void> simular(WidgetTester tester, String opcion) async {
  await tester.tap(find.byType(PopupMenuButton<String>));
  await tester.pumpAndSettle();
  await tester.tap(find.text(opcion));
  await tester.pump(); // dibuja el frame para que Obx se suscriba
  await tester.pump(const Duration(seconds: 1));
  await tester.pump();
}

void main() {
  late List<Place> lugaresOriginales;

  setUp(() => lugaresOriginales = List.of(lugaresEjemplo));

  tearDown(() {
    // GetX y lugaresEjemplo son globales: se limpian entre pruebas.
    Get.reset();
    lugaresEjemplo
      ..clear()
      ..addAll(lugaresOriginales);
    modoTema.value = ThemeMode.system;
  });

  testWidgets('Inicio muestra carga y luego los lugares con el contador', (WidgetTester tester) async {
    await tester.pumpWidget(const ExploraEcApp());
    expect(find.byType(LoadingView), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('Parque El Ejido'), findsOneWidget);
    expect(find.text('ExploraEC (6)'), findsOneWidget);
  });

  testWidgets('El menú ⋮ muestra vacío, error (con aviso) y normal', (WidgetTester tester) async {
    await abrirApp(tester);

    await simular(tester, 'Simular: vacío');
    expect(find.byType(EmptyView), findsOneWidget);

    await simular(tester, 'Simular: error');
    expect(find.byType(ErrorView), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
    expect(find.text('Error'), findsOneWidget); // aviso del worker ever
    await cerrarAvisos(tester);

    await simular(tester, 'Simular: normal');
    await tester.pumpAndSettle();
    expect(find.text('Parque El Ejido'), findsOneWidget);
  });

  testWidgets('Agregar un lugar lo muestra sin recargar, sube el contador y avisa', (WidgetTester tester) async {
    await abrirApp(tester);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Nombre del lugar'), 'Teleférico');
    await tester.enterText(find.widgetWithText(TextFormField, 'Categoría'), 'Miradores');
    await tester.enterText(find.widgetWithText(TextFormField, 'Descripción'), 'Vista de Quito desde el Pichincha.');
    await tester.tap(find.text('Guardar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(LoadingView), findsNothing); // no recargó la lista
    expect(find.text('ExploraEC (7)'), findsOneWidget);
    expect(find.text('Lugar agregado'), findsOneWidget);
    await cerrarAvisos(tester);
  });

  testWidgets('Pantalla ancha usa GridView sin overflow', (WidgetTester tester) async {
    addTearDown(tester.view.reset);
    tester.view.physicalSize = const Size(950, 800);
    tester.view.devicePixelRatio = 1;
    await abrirApp(tester);
    expect(find.byType(GridView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('PlaceCard expone un label semántico', (WidgetTester tester) async {
    final semantics = tester.ensureSemantics();
    await abrirApp(tester);
    expect(find.bySemanticsLabel('Parque El Ejido, categoría Parques'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('Tocar una tarjeta abre el Detalle con Get.to', (WidgetTester tester) async {
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

  testWidgets('Favoritos: el corazón se marca y la pestaña cuenta', (WidgetTester tester) async {
    await abrirApp(tester);

    await tester.tap(find.byIcon(Icons.favorite_border).first);
    await tester.pump();
    await tester.tap(find.byIcon(Icons.favorite_border).first);
    await tester.pump();

    await tester.tap(find.text('Favoritos'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Favoritos marcados: 2'), findsOneWidget);
  });

  testWidgets('Las traducciones de la barra y el menú existen en inglés', (WidgetTester tester) async {
    // Get.updateLocale fuerza un reassemble que el entorno de pruebas no
    // permite; el botón se verifica en el emulador. Aquí se comprueban las
    // claves que usa .tr.
    await abrirApp(tester);
    expect(find.byIcon(Icons.translate), findsOneWidget);

    Get.locale = const Locale('en', 'US');
    expect('inicio'.tr, 'Home');
    expect('mapa'.tr, 'Map');
    expect('favoritos'.tr, 'Favorites');
    expect('sim_vacio'.tr, 'Simulate: empty');

    Get.locale = const Locale('es', 'EC');
    expect('inicio'.tr, 'Inicio');
  });

  testWidgets('El botón de tema alterna automático → claro → oscuro', (WidgetTester tester) async {
    await abrirApp(tester);

    Brightness brillo() => Theme.of(tester.element(find.text('Parque El Ejido'))).brightness;

    await tester.tap(find.byIcon(Icons.brightness_auto));
    await tester.pumpAndSettle();
    expect(brillo(), Brightness.light);

    await tester.tap(find.byIcon(Icons.light_mode));
    await tester.pumpAndSettle();
    expect(brillo(), Brightness.dark);

    await tester.tap(find.byIcon(Icons.dark_mode));
    await tester.pumpAndSettle();
    expect(modoTema.value, ThemeMode.system);
  });
}
