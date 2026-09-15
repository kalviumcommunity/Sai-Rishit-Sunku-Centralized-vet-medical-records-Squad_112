import 'package:flutter/material.dart';

/// Whimsical Vector Pet Mascots matching the user reference design:
/// - MascotDogWidget: Playful running pup with floppy ears and happy smile
/// - MascotCatWidget: Cute orange cat with white chest and fluffy tail
/// - MascotBirdWidget: Round yellow canary on a wooden perch
class MascotDogWidget extends StatelessWidget {
  final double size;
  const MascotDogWidget({super.key, this.size = 180});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size * 0.75),
      painter: _DogPainter(bounce: 0.5),
    );
  }
}

class _DogPainter extends CustomPainter {
  final double bounce;
  _DogPainter({required this.bounce});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Body Paint
    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFE07A3B), Color(0xFFC45A22)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    final darkPaint = Paint()..color = const Color(0xFF8B3A14);
    final earPaint = Paint()..color = const Color(0xFFF39C72);
    final eyePaint = Paint()..color = const Color(0xFF1E293B);
    final shinePaint = Paint()..color = Colors.white;
    final nosePaint = Paint()..color = const Color(0xFF0F172A);
    final tonguePaint = Paint()..color = const Color(0xFFF87171);

    // 1. Curled Tail
    final tailPath = Path()
      ..moveTo(w * 0.82, h * 0.46)
      ..cubicTo(w * 0.90, h * 0.40, w * 0.92, h * 0.32, w * 0.88, h * 0.30)
      ..cubicTo(w * 0.85, h * 0.30, w * 0.80, h * 0.42, w * 0.78, h * 0.48);
    canvas.drawPath(
      tailPath,
      Paint()
        ..color = const Color(0xFFB34A1B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round,
    );

    // 2. Rear Leg (Extended Backwards Running)
    final backLeg = Path()
      ..moveTo(w * 0.75, h * 0.55)
      ..quadraticBezierTo(w * 0.92, h * 0.58, w * 0.96, h * 0.54)
      ..quadraticBezierTo(w * 0.88, h * 0.65, w * 0.72, h * 0.64)
      ..close();
    canvas.drawPath(backLeg, Paint()..color = const Color(0xFFB34A1B));

    // 3. Front Leg (Extended Forward Running)
    final frontLeg = Path()
      ..moveTo(w * 0.38, h * 0.65)
      ..quadraticBezierTo(w * 0.45, h * 0.80, w * 0.35, h * 0.82)
      ..quadraticBezierTo(w * 0.30, h * 0.70, w * 0.32, h * 0.64)
      ..close();
    canvas.drawPath(frontLeg, Paint()..color = const Color(0xFFB34A1B));

    // 4. Elongated Sausage Body (Snoopy / Milo)
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.28, h * 0.38, w * 0.54, h * 0.42),
      const Radius.circular(36),
    );
    canvas.save();
    canvas.rotate(-0.06);
    canvas.drawRRect(bodyRect, bodyPaint);
    canvas.restore();

    // Belly lighter soft curve
    final bellyPaint = Paint()
      ..color = const Color(0xFFF39C72).withValues(alpha: 0.5);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.55, h * 0.62), width: w * 0.42, height: h * 0.26),
      bellyPaint,
    );

    // 5. Head
    final headCenter = Offset(w * 0.26, h * 0.36);
    canvas.drawCircle(headCenter, w * 0.16, bodyPaint);

    // 6. Snout / Muzzle
    final snoutPath = Path()
      ..moveTo(headCenter.dx - w * 0.08, headCenter.dy + h * 0.02)
      ..quadraticBezierTo(headCenter.dx - w * 0.24, headCenter.dy - h * 0.04, headCenter.dx - w * 0.26, headCenter.dy - h * 0.08)
      ..quadraticBezierTo(headCenter.dx - w * 0.18, headCenter.dy - h * 0.14, headCenter.dx - w * 0.04, headCenter.dy - h * 0.06)
      ..close();
    canvas.drawPath(snoutPath, bodyPaint);

    // 7. Black Nose
    canvas.drawOval(
      Rect.fromCenter(center: Offset(headCenter.dx - w * 0.24, headCenter.dy - h * 0.08), width: 14, height: 16),
      nosePaint,
    );
    canvas.drawCircle(Offset(headCenter.dx - w * 0.25, headCenter.dy - h * 0.10), 3, shinePaint);

    // 8. Pink Tongue sticking out
    final tonguePath = Path()
      ..moveTo(headCenter.dx - w * 0.16, headCenter.dy + h * 0.04)
      ..quadraticBezierTo(headCenter.dx - w * 0.22, headCenter.dy + h * 0.10, headCenter.dx - w * 0.14, headCenter.dy + h * 0.11)
      ..quadraticBezierTo(headCenter.dx - w * 0.10, headCenter.dy + h * 0.06, headCenter.dx - w * 0.11, headCenter.dy + h * 0.02)
      ..close();
    canvas.drawPath(tonguePath, tonguePaint);

    // 9. Floppy Flying Ear
    final earPath = Path()
      ..moveTo(headCenter.dx + w * 0.04, headCenter.dy - h * 0.06)
      ..cubicTo(headCenter.dx + w * 0.18, headCenter.dy - h * 0.22, headCenter.dx + w * 0.28, headCenter.dy - h * 0.06, headCenter.dx + w * 0.14, headCenter.dy + h * 0.06)
      ..close();
    canvas.drawPath(earPath, darkPaint);
    // Inner ear pinkish
    canvas.drawOval(
      Rect.fromCenter(center: Offset(headCenter.dx + w * 0.16, headCenter.dy - h * 0.06), width: w * 0.14, height: h * 0.14),
      earPaint,
    );

    // 10. Eye with twinkle
    final eyePos = Offset(headCenter.dx - w * 0.06, headCenter.dy - h * 0.05);
    canvas.drawCircle(eyePos, 7.5, eyePaint);
    canvas.drawCircle(Offset(eyePos.dx - 2, eyePos.dy - 2), 2.5, shinePaint);
  }

  @override
  bool shouldRepaint(covariant _DogPainter oldDelegate) => false;
}

/// Mascot: Lucky the Cute Orange Cat with Fluffy Tail
class MascotCatWidget extends StatelessWidget {
  final double size;
  const MascotCatWidget({super.key, this.size = 180});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size * 0.95),
      painter: _CatPainter(tailWave: 0.05),
    );
  }
}

class _CatPainter extends CustomPainter {
  final double tailWave;
  _CatPainter({required this.tailWave});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final orangePaint = Paint()..color = const Color(0xFFF57D2C);
    final whitePaint = Paint()..color = Colors.white;
    final eyePaint = Paint()..color = const Color(0xFF0F172A);
    final innerEarPaint = Paint()..color = const Color(0xFFFCA5A5);

    // 1. High Fluffy Tail with White Tip
    canvas.save();
    canvas.translate(w * 0.65, h * 0.50);
    canvas.rotate(tailWave);
    final tailPath = Path()
      ..moveTo(0, 0)
      ..cubicTo(w * 0.12, -h * 0.20, w * 0.18, -h * 0.45, w * 0.05, -h * 0.50)
      ..cubicTo(-w * 0.08, -h * 0.52, -w * 0.06, -h * 0.35, -w * 0.08, -h * 0.15)
      ..close();
    canvas.drawPath(tailPath, orangePaint);
    // Tail white fluffy tip
    final tailTip = Path()
      ..moveTo(-w * 0.06, -h * 0.38)
      ..cubicTo(w * 0.02, -h * 0.42, w * 0.05, -h * 0.50, -w * 0.01, -h * 0.52)
      ..cubicTo(-w * 0.08, -h * 0.52, -w * 0.08, -h * 0.44, -w * 0.06, -h * 0.38)
      ..close();
    canvas.drawPath(tailTip, whitePaint);
    canvas.restore();

    // 2. Rounded Cat Body
    final bodyRect = Rect.fromCenter(center: Offset(w * 0.52, h * 0.60), width: w * 0.46, height: h * 0.44);
    canvas.drawOval(bodyRect, orangePaint);

    // 3. White Chest & Paws
    final chestPath = Path()
      ..moveTo(w * 0.32, h * 0.48)
      ..quadraticBezierTo(w * 0.46, h * 0.45, w * 0.52, h * 0.65)
      ..quadraticBezierTo(w * 0.42, h * 0.82, w * 0.30, h * 0.72)
      ..close();
    canvas.drawPath(chestPath, whitePaint);

    // Front little white paws
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.38, h * 0.76, 16, 22), const Radius.circular(8)),
      whitePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.48, h * 0.76, 16, 22), const Radius.circular(8)),
      whitePaint,
    );

    // 4. Head
    final headCenter = Offset(w * 0.36, h * 0.38);
    canvas.drawCircle(headCenter, w * 0.18, orangePaint);

    // White muzzle
    canvas.drawOval(
      Rect.fromCenter(center: Offset(headCenter.dx - w * 0.05, headCenter.dy + h * 0.04), width: w * 0.18, height: h * 0.14),
      whitePaint,
    );

    // 5. Ears (Pointy Cat Ears)
    final leftEar = Path()
      ..moveTo(headCenter.dx - w * 0.16, headCenter.dy - h * 0.04)
      ..lineTo(headCenter.dx - w * 0.14, headCenter.dy - h * 0.22)
      ..lineTo(headCenter.dx - w * 0.02, headCenter.dy - h * 0.12)
      ..close();
    canvas.drawPath(leftEar, orangePaint);
    final leftInner = Path()
      ..moveTo(headCenter.dx - w * 0.14, headCenter.dy - h * 0.05)
      ..lineTo(headCenter.dx - w * 0.13, headCenter.dy - h * 0.18)
      ..lineTo(headCenter.dx - w * 0.04, headCenter.dy - h * 0.11)
      ..close();
    canvas.drawPath(leftInner, innerEarPaint);

    final rightEar = Path()
      ..moveTo(headCenter.dx + w * 0.02, headCenter.dy - h * 0.14)
      ..lineTo(headCenter.dx + w * 0.12, headCenter.dy - h * 0.22)
      ..lineTo(headCenter.dx + w * 0.16, headCenter.dy - h * 0.04)
      ..close();
    canvas.drawPath(rightEar, orangePaint);
    final rightInner = Path()
      ..moveTo(headCenter.dx + w * 0.04, headCenter.dy - h * 0.12)
      ..lineTo(headCenter.dx + w * 0.11, headCenter.dy - h * 0.18)
      ..lineTo(headCenter.dx + w * 0.14, headCenter.dy - h * 0.05)
      ..close();
    canvas.drawPath(rightInner, innerEarPaint);

    // 6. Big Glossy Eyes
    final leftEye = Offset(headCenter.dx - w * 0.08, headCenter.dy - h * 0.01);
    final rightEye = Offset(headCenter.dx + w * 0.06, headCenter.dy - h * 0.01);
    canvas.drawCircle(leftEye, 8.5, eyePaint);
    canvas.drawCircle(Offset(leftEye.dx - 2.5, leftEye.dy - 2.5), 3, whitePaint);
    canvas.drawCircle(rightEye, 8.5, eyePaint);
    canvas.drawCircle(Offset(rightEye.dx - 2.5, rightEye.dy - 2.5), 3, whitePaint);

    // 7. Cute Nose
    final nosePaint = Paint()..color = const Color(0xFFE11D48);
    canvas.drawCircle(Offset(headCenter.dx - w * 0.01, headCenter.dy + h * 0.04), 3.5, nosePaint);
  }

  @override
  bool shouldRepaint(covariant _CatPainter oldDelegate) => false;
}

/// Mascot: Sunny the Yellow Canary on Wooden Perch
class MascotBirdWidget extends StatelessWidget {
  final double size;
  const MascotBirdWidget({super.key, this.size = 180});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size * 1.1),
      painter: _BirdPainter(swing: 0.02),
    );
  }
}

class _BirdPainter extends CustomPainter {
  final double swing;
  _BirdPainter({required this.swing});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final yellowPaint = Paint()..color = const Color(0xFFFFD13B);
    final orangePaint = Paint()..color = const Color(0xFFF97316);
    final perchPaint = Paint()..color = const Color(0xFF8D5B4C);
    final ropePaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 1.5;
    final eyePaint = Paint()..color = const Color(0xFF0F172A);

    // Hanging Ropes
    canvas.drawLine(Offset(w * 0.32, 0), Offset(w * 0.32, h * 0.85), ropePaint);
    canvas.drawLine(Offset(w * 0.68, 0), Offset(w * 0.68, h * 0.85), ropePaint);

    // Wooden Perch Bar
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.20, h * 0.84, w * 0.60, 10), const Radius.circular(5)),
      perchPaint,
    );

    // Head Crest Tuft
    final crest = Path()
      ..moveTo(w * 0.50, h * 0.20)
      ..quadraticBezierTo(w * 0.44, h * 0.12, w * 0.50, h * 0.10)
      ..quadraticBezierTo(w * 0.56, h * 0.15, w * 0.54, h * 0.22)
      ..close();
    canvas.drawPath(crest, orangePaint);

    // Plump Yellow Body
    final bodyRect = Rect.fromCenter(center: Offset(w * 0.50, h * 0.48), width: w * 0.48, height: h * 0.54);
    canvas.drawOval(bodyRect, yellowPaint);

    // Wing
    final wing = Path()
      ..moveTo(w * 0.58, h * 0.42)
      ..quadraticBezierTo(w * 0.75, h * 0.55, w * 0.68, h * 0.72)
      ..quadraticBezierTo(w * 0.54, h * 0.68, w * 0.58, h * 0.42)
      ..close();
    canvas.drawPath(wing, Paint()..color = const Color(0xFFF5BE1E));

    // Big Sweet Eyes
    final whitePaint = Paint()..color = Colors.white;
    final leftEye = Offset(w * 0.42, h * 0.35);
    final rightEye = Offset(w * 0.58, h * 0.35);
    canvas.drawCircle(leftEye, 8.5, eyePaint);
    canvas.drawCircle(Offset(leftEye.dx - 2.5, leftEye.dy - 2.5), 3, whitePaint);
    canvas.drawCircle(rightEye, 8.5, eyePaint);
    canvas.drawCircle(Offset(rightEye.dx - 2.5, rightEye.dy - 2.5), 3, whitePaint);

    // Cute Orange Beak
    final beak = Path()
      ..moveTo(w * 0.46, h * 0.37)
      ..lineTo(w * 0.54, h * 0.37)
      ..lineTo(w * 0.50, h * 0.47)
      ..close();
    canvas.drawPath(beak, orangePaint);

    // Feet clutching perch
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.42, h * 0.82, 10, 8), const Radius.circular(3)),
      orangePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.52, h * 0.82, 10, 8), const Radius.circular(3)),
      orangePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _BirdPainter oldDelegate) => false;
}
