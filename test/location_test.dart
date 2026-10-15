import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';

import 'package:exploraec/controllers/places_controller.dart';
import 'package:exploraec/models/place.dart';
import 'package:exploraec/services/location_service.dart';

Position posicionEn(double lat, double lng) => Position(
      latitude: lat,
      longitude: lng,
      timestamp: DateTime(2026),
      accuracy: 0,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );

void main() {
  test('formatearDistancia usa m bajo 1 km y km desde 1 km', () {
    expect(formatearDistancia(0), '0 m');
    expect(formatearDistancia(850.4), '850 m');
    expect(formatearDistancia(2345), '2.3 km');
  });

  test('distanciaA es null sin posición y coherente con ella', () {
    final controller = PlacesController();
    final galletti = lugaresEjemplo.firstWhere((p) => p.nombre == 'Café Galletti');
    final alabado = lugaresEjemplo.firstWhere((p) => p.nombre == 'Museo Casa del Alabado');

    expect(controller.distanciaA(galletti), isNull);

    // Ubicación simulada del instructivo: junto a Café Galletti.
    controller.posicion.value = posicionEn(-0.1938, -78.4869);
    expect(controller.distanciaA(galletti), lessThan(1));
    expect(controller.distanciaA(alabado)!, greaterThan(2000));
  });
}
