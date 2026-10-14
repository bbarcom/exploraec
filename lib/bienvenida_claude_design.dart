import 'package:flutter/material.dart';

/// Pantalla de bienvenida de ExploraEC, según el diseño "Bienvenida ExploraEC"
/// (artefacto de Claude Design, 390×844).
class BienvenidaScreenClaudeDesign extends StatelessWidget {
  const BienvenidaScreenClaudeDesign({
    super.key,
    this.onEmpezar,
    this.accent = const Color(0xFF0F766E),
  });

  /// Acción del botón "Empezar". Sin navegación por ahora: puede ser null.
  final VoidCallback? onEmpezar;

  /// Color de marca (ícono y botón).
  final Color accent;

  static const _background = Color(0xFFFFF8EC);
  static const _title = Color(0xFF1F2937);
  static const _subtitle = Color(0xFF4B5563);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 48),
              child: Column(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Semantics(
                          label: 'Pin de mapa con brújula',
                          child: CustomPaint(
                            size: const Size(104, 104),
                            painter: _PinBrujulaPainter(accent),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'ExploraEC',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 44,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.88,
                            color: _title,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Descubre lugares cerca de ti',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            height: 1.4,
                            color: _subtitle,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onEmpezar ?? () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(60),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 18,
                        ),
                        shape: const StadiumBorder(),
                        elevation: 6,
                        shadowColor: accent.withValues(alpha: 0.3),
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: const Text('Empezar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Dibuja el ícono del diseño (viewBox 64×64): pin de mapa con una aguja
/// de brújula dentro de un círculo blanco.
class _PinBrujulaPainter extends CustomPainter {
  const _PinBrujulaPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 64, size.height / 64);

    final fill = Paint()..color = color;

    final pin = Path()
      ..moveTo(32, 4)
      ..cubicTo(20.4, 4, 11, 13.2, 11, 24.6)
      ..cubicTo(11, 40, 32, 60, 32, 60)
      ..cubicTo(32, 60, 53, 40, 53, 24.6)
      ..cubicTo(53, 13.2, 43.6, 4, 32, 4)
      ..close();
    canvas.drawPath(pin, fill);

    canvas.drawCircle(const Offset(32, 24), 12, Paint()..color = Colors.white);

    final aguja = Path()
      ..moveTo(32, 15)
      ..lineTo(36.5, 26)
      ..lineTo(32, 33)
      ..lineTo(27.5, 26)
      ..close();
    canvas.drawPath(aguja, fill);
  }

  @override
  bool shouldRepaint(_PinBrujulaPainter oldDelegate) =>
      oldDelegate.color != color;
}
