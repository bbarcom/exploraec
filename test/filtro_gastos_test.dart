import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:exploraec/controllers/auth_controller.dart';
import 'package:exploraec/controllers/gastos_controller.dart';
import 'package:exploraec/models/gasto.dart';
import 'package:exploraec/models/usuario.dart';
import 'package:exploraec/screens/gastos_screen.dart';
import 'package:exploraec/services/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// Servidor falso: la prueba no necesita red, solo la pantalla y el controller.
class _ServidorMudo implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(RequestOptions o, Stream<Uint8List>? cuerpo, Future<void>? cancelar) async =>
      ResponseBody.fromString(jsonEncode({'detail': 'no previsto'}), 404,
          headers: {Headers.contentTypeHeader: ['application/json']});

  @override
  void close({bool force = false}) {}
}

/// Igual que el controller real, pero sin pedir datos al arrancar: la prueba
/// carga los gastos a mano.
class _GastosSinRed extends GastosController {
  @override
  // ignore: must_call_super
  void onInit() {}
}

const _gastos = [
  Gasto(id: 1, descripcion: 'Almuerzo en el Mercado Central', monto: 6.5, categoria: 'comida', fecha: '2026-10-05'),
  Gasto(id: 2, descripcion: 'Taxi al terminal', monto: 3.25, categoria: 'transporte', fecha: '2026-10-05'),
  Gasto(id: 3, descripcion: 'Cena en La Ronda', monto: 12, categoria: 'comida', fecha: '2026-10-06'),
];

void main() {
  testWidgets('Filtro: al elegir «comida» solo se ven los gastos de comida', (tester) async {
    Get.reset();
    Get.testMode = true;
    FlutterSecureStorage.setMockInitialValues({});
    Get.put(ApiClient(dio: Dio(BaseOptions(baseUrl: 'http://prueba'))..httpClientAdapter = _ServidorMudo()));
    final auth = Get.put(AuthController());
    auth.usuario.value = const Usuario(id: 1, email: 'prueba@ejemplo.com');
    final controller = Get.put<GastosController>(_GastosSinRed());
    controller.gastos.assignAll(_gastos);

    await tester.pumpWidget(const GetMaterialApp(home: GastosScreen()));
    await tester.pump();

    // Sin filtro: se ven los tres gastos y los chips «Todas», «comida» y «transporte».
    expect(find.text('Almuerzo en el Mercado Central'), findsOneWidget);
    expect(find.text('Taxi al terminal'), findsOneWidget);
    expect(find.text('Cena en La Ronda'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Todas'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'transporte'), findsOneWidget);

    // «comida»: solo los gastos de comida.
    await tester.tap(find.widgetWithText(ChoiceChip, 'comida'));
    await tester.pump();
    expect(find.text('Almuerzo en el Mercado Central'), findsOneWidget);
    expect(find.text('Cena en La Ronda'), findsOneWidget);
    expect(find.text('Taxi al terminal'), findsNothing);

    // «Todas»: vuelve la lista completa.
    await tester.tap(find.widgetWithText(ChoiceChip, 'Todas'));
    await tester.pump();
    expect(find.text('Taxi al terminal'), findsOneWidget);
  });
}
