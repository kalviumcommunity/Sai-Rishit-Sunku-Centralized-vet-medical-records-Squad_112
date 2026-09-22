import 'dart:convert';
import 'package:flutter/material.dart';

import 'pet_mascots.dart';

/// Universal Pet Avatar & Image View:
/// Correctly resolves and displays:
/// 1. Base64 Data URI (`data:image/...;base64,...`) from user device upload
/// 2. Remote HTTPS/HTTP Network Images
/// 3. Bundled Asset Images (`assets/...`)
/// 4. Graceful fallback to whimsical vector Mascots (Dog, Cat, Bird) based on species.
class PetAvatarView extends StatelessWidget {
  final String? photoUrl;
  final String species;
  final double size;
  final bool isCircle;
  final BorderRadius? borderRadius;
  final BoxFit fit;

  const PetAvatarView({
    super.key,
    required this.photoUrl,
    required this.species,
    this.size = 60,
    this.isCircle = true,
    this.borderRadius,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (photoUrl != null && photoUrl!.trim().isNotEmpty) {
      final url = photoUrl!.trim();

      // 1. Base64 Data URI (from device/gallery upload)
      if (url.startsWith('data:image') || url.startsWith('base64:')) {
        try {
          final comma = url.indexOf(',');
          final b64 = comma != -1 ? url.substring(comma + 1) : url.replaceFirst('base64:', '');
          final bytes = base64Decode(b64);
          return _clip(
            Image.memory(
              bytes,
              width: size,
              height: size,
              fit: fit,
              errorBuilder: (_, __, ___) => _fallbackMascot(),
            ),
          );
        } catch (_) {
          return _fallbackMascot();
        }
      }

      // 2. Web Network Image (Unsplash presets or Firebase Storage URLs)
      if (url.startsWith('http://') || url.startsWith('https://')) {
        return _clip(
          Image.network(
            url,
            width: size,
            height: size,
            fit: fit,
            errorBuilder: (_, __, ___) => _fallbackMascot(),
          ),
        );
      }

      // 3. Local Bundled Asset Image
      if (url.startsWith('assets/')) {
        return _clip(
          Image.asset(
            url,
            width: size,
            height: size,
            fit: fit,
            errorBuilder: (_, __, ___) => _fallbackMascot(),
          ),
        );
      }
    }

    return _fallbackMascot();
  }

  Widget _clip(Widget child) {
    if (isCircle) {
      return ClipOval(child: child);
    }
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(16),
      child: child,
    );
  }

  Widget _fallbackMascot() {
    final sp = species.toLowerCase();
    Color bgColor = const Color(0xFFFED7AA);
    Widget mascot;
    if (sp.contains('cat')) {
      bgColor = const Color(0xFFFDE68A);
      mascot = MascotCatWidget(size: size);
    } else if (sp.contains('bird')) {
      bgColor = const Color(0xFFFEF08A);
      mascot = MascotBirdWidget(size: size);
    } else {
      mascot = MascotDogWidget(size: size);
    }
    return _clip(
      Container(
        width: size,
        height: size,
        color: bgColor,
        child: Center(child: mascot),
      ),
    );
  }
}
