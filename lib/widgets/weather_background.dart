
import 'dart:math' as math;
import 'package:flutter/material.dart';

enum WeatherScene {
  sunny,
  cloudy,
  rainy,
  snowy,
  stormy,
  foggy,
}

WeatherScene sceneFromCode(int code) {
  if (code == 0) return WeatherScene.sunny;
  if (code <= 3) return WeatherScene.cloudy;
  if (code <= 48) return WeatherScene.foggy;
  if (code <= 67) return WeatherScene.rainy;
  if (code <= 77) return WeatherScene.snowy;
  if (code <= 82) return WeatherScene.rainy;
  if (code <= 86) return WeatherScene.snowy;
  if (code >= 95) return WeatherScene.stormy;
  return WeatherScene.cloudy;
}

class WeatherBackground extends StatefulWidget {
  final WeatherScene scene;

  const WeatherBackground({
    super.key,
    required this.scene,
  });

  @override
  State<WeatherBackground> createState() =>
      _WeatherBackgroundState();
}

class _WeatherBackgroundState extends State<WeatherBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Color> _colors(WeatherScene scene) {
    switch (scene) {
      case WeatherScene.sunny:
        return [
          const Color(0xFF0875DC),
          const Color(0xFF48B5F6),
          const Color(0xFFFFC47B),
        ];
      case WeatherScene.cloudy:
        return [
          const Color(0xFF345777),
          const Color(0xFF718FAE),
          const Color(0xFFB5C8D8),
        ];
      case WeatherScene.rainy:
        return [
          const Color(0xFF102A49),
          const Color(0xFF24547E),
          const Color(0xFF4686B4),
        ];
      case WeatherScene.snowy:
        return [
          const Color(0xFF426D9E),
          const Color(0xFF83B5E3),
          const Color(0xFFD6EAFF),
        ];
      case WeatherScene.stormy:
        return [
          const Color(0xFF171C40),
          const Color(0xFF393D75),
          const Color(0xFF665C9C),
        ];
      case WeatherScene.foggy:
        return [
          const Color(0xFF526B80),
          const Color(0xFF8BA5B7),
          const Color(0xFFC4D2DA),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _colors(widget.scene),
        ),
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: WeatherPainter(
              scene: widget.scene,
              progress: _controller.value,
            ),
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }
}

class WeatherPainter extends CustomPainter {
  final WeatherScene scene;
  final double progress;

  WeatherPainter({
    required this.scene,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    switch (scene) {
      case WeatherScene.sunny:
        _drawSun(canvas, size);
        _drawClouds(canvas, size, 0.65);
        break;

      case WeatherScene.cloudy:
        _drawClouds(canvas, size, 1);
        break;

      case WeatherScene.rainy:
        _drawClouds(canvas, size, 0.75);
        _drawRain(canvas, size);
        break;

      case WeatherScene.snowy:
        _drawClouds(canvas, size, 0.55);
        _drawSnow(canvas, size);
        break;

      case WeatherScene.stormy:
        _drawClouds(canvas, size, 0.9);
        _drawRain(canvas, size);
        _drawLightning(canvas, size);
        break;

      case WeatherScene.foggy:
        _drawFog(canvas, size);
        break;
    }
  }

  void _drawSun(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.52, size.height * 0.30);
    final pulse = math.sin(progress * math.pi * 2);

    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.75),
          const Color(0xFFFFE18B).withValues(alpha: 0.35),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: center,
          radius: 145 + pulse * 10,
        ),
      );

    canvas.drawCircle(center, 145 + pulse * 10, glow);

    final rays = Paint()
      ..color = const Color(0xFFFFF1B6)
          .withValues(alpha: 0.45 + pulse.abs() * 0.2)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 12; i++) {
      final angle = i * math.pi / 6 + progress * 0.12;
      final start = Offset(
        center.dx + math.cos(angle) * 62,
        center.dy + math.sin(angle) * 62,
      );
      final end = Offset(
        center.dx + math.cos(angle) * 84,
        center.dy + math.sin(angle) * 84,
      );

      canvas.drawLine(start, end, rays);
    }

    canvas.drawCircle(
      center,
      49 + pulse * 2,
      Paint()
        ..shader = const RadialGradient(
          colors: [
            Color(0xFFFFFCE0),
            Color(0xFFFFDE66),
            Color(0xFFFFB83D),
          ],
        ).createShader(
          Rect.fromCircle(center: center, radius: 55),
        ),
    );
  }

  void _drawCloud(
    Canvas canvas,
    Offset center,
    double scale,
    double opacity,
  ) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(scale);

    final shadow = Paint()
      ..color = const Color(0xFF203B60)
          .withValues(alpha: opacity * 0.22)
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        18,
      );

    final cloud = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: opacity),
          const Color(0xFFC1D7EA)
              .withValues(alpha: opacity * 0.85),
        ],
      ).createShader(
        const Rect.fromLTWH(-110, -75, 220, 140),
      );

    final path = Path()
      ..addOval(const Rect.fromLTWH(-95, -15, 190, 65))
      ..addOval(const Rect.fromLTWH(-65, -55, 95, 95))
      ..addOval(const Rect.fromLTWH(-5, -75, 105, 115))
      ..addOval(const Rect.fromLTWH(35, -25, 75, 65));

    canvas.drawPath(path.shift(const Offset(0, 12)), shadow);
    canvas.drawPath(path, cloud);

    canvas.restore();
  }

  void _drawClouds(Canvas canvas, Size size, double opacity) {
    final drift = math.sin(progress * math.pi * 2);

    _drawCloud(
      canvas,
      Offset(size.width * 0.16 + drift * 22, size.height * 0.19),
      0.75,
      opacity * 0.75,
    );

    _drawCloud(
      canvas,
      Offset(size.width * 0.85 - drift * 30, size.height * 0.38),
      1.05,
      opacity,
    );

    _drawCloud(
      canvas,
      Offset(size.width * 0.18 - drift * 18, size.height * 0.70),
      0.9,
      opacity * 0.65,
    );
  }

  void _drawRain(Canvas canvas, Size size) {
    final random = math.Random(42);

    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.42)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 110; i++) {
      final x = random.nextDouble() * size.width;
      final seedY = random.nextDouble();
      final speed = 1.5 + random.nextDouble() * 1.5;
      final y = ((seedY + progress * speed) % 1) * size.height;

      canvas.drawLine(
        Offset(x, y),
        Offset(x - 7, y + 22),
        paint,
      );
    }
  }

  void _drawSnow(Canvas canvas, Size size) {
    final random = math.Random(77);

    for (int i = 0; i < 85; i++) {
      final seedX = random.nextDouble();
      final seedY = random.nextDouble();
      final radius = 1.5 + random.nextDouble() * 3;
      final speed = 0.3 + random.nextDouble() * 0.7;

      final x = seedX * size.width +
          math.sin(progress * math.pi * 2 + i) * 12;

      final y = ((seedY + progress * speed) % 1) * size.height;

      canvas.drawCircle(
        Offset(x, y),
        radius,
        Paint()
          ..color = Colors.white.withValues(
            alpha: 0.45 + random.nextDouble() * 0.5,
          ),
      );
    }
  }

  void _drawLightning(Canvas canvas, Size size) {
    final phase = progress;

    if (!((phase > 0.16 && phase < 0.19) ||
        (phase > 0.22 && phase < 0.235))) {
      return;
    }

    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.13),
    );

    final path = Path()
      ..moveTo(size.width * 0.72, size.height * 0.10)
      ..lineTo(size.width * 0.60, size.height * 0.24)
      ..lineTo(size.width * 0.70, size.height * 0.24)
      ..lineTo(size.width * 0.52, size.height * 0.46)
      ..lineTo(size.width * 0.62, size.height * 0.29)
      ..lineTo(size.width * 0.54, size.height * 0.29);

    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFFFF5BD)
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round
        ..maskFilter = const MaskFilter.blur(
          BlurStyle.normal,
          3,
        ),
    );
  }

  void _drawFog(Canvas canvas, Size size) {
    final drift = math.sin(progress * math.pi * 2);

    for (int i = 0; i < 7; i++) {
      final y = size.height * (0.15 + i * 0.12);

      final paint = Paint()
        ..color = Colors.white.withValues(alpha: 0.07)
        ..maskFilter = const MaskFilter.blur(
          BlurStyle.normal,
          35,
        );

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(
            size.width * 0.5 + drift * 35 * (i.isEven ? 1 : -1),
            y,
          ),
          width: size.width * 1.5,
          height: 110,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant WeatherPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.scene != scene;
  }
}
