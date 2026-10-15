import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Modo de tema elegido dentro de la app (sistema / claro / oscuro).
/// El botón escucha este valor para mostrar su ícono; `Get.changeThemeMode`
/// aplica el cambio a toda la app sin tocar los ajustes del teléfono.
final ValueNotifier<ThemeMode> modoTema = ValueNotifier(ThemeMode.system);

/// Pasa al siguiente modo: sistema → claro → oscuro → sistema.
void alternarModoTema() {
  modoTema.value = switch (modoTema.value) {
    ThemeMode.system => ThemeMode.light,
    ThemeMode.light => ThemeMode.dark,
    ThemeMode.dark => ThemeMode.system,
  };
  Get.changeThemeMode(modoTema.value);
}

/// Botón para la AppBar que muestra el modo actual y lo alterna al tocarlo.
class BotonModoTema extends StatelessWidget {
  const BotonModoTema({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: modoTema,
      builder: (context, modo, _) {
        final (icono, nombre) = switch (modo) {
          ThemeMode.system => (Icons.brightness_auto, 'automático'),
          ThemeMode.light => (Icons.light_mode, 'claro'),
          ThemeMode.dark => (Icons.dark_mode, 'oscuro'),
        };
        return IconButton(
          icon: Icon(icono),
          tooltip: 'Tema: $nombre (toca para cambiar)',
          onPressed: alternarModoTema,
        );
      },
    );
  }
}
