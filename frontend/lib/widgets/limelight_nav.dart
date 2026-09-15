import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Item definition for [LimelightNavBar]
class LimelightItem {
  final String id;
  final IconData icon;
  final String label;
  final VoidCallback? onClick;

  const LimelightItem({
    required this.id,
    required this.icon,
    required this.label,
    this.onClick,
  });
}

/// An adaptive-width navigation bar with a "limelight" spotlight effect that highlights the active item.
/// Replicates the React/Tailwind [LimelightNav] component in Flutter.
class LimelightNavBar extends StatelessWidget {
  final List<LimelightItem> items;
  final int activeIndex;
  final ValueChanged<int>? onTabChange;

  const LimelightNavBar({
    super.key,
    required this.items,
    this.activeIndex = 0,
    this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth > 460 ? 440.0 : constraints.maxWidth - 32;
        final itemWidth = totalWidth / items.length;
        final activeCenter = (activeIndex * itemWidth) + (itemWidth / 2);

        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: totalWidth,
              height: 64,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: AppColors.border, width: 1.2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x18000000),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Animated Limelight Spotlight Beam & Top Bar
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  left: activeCenter - 26,
                  top: 0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Top pill indicator
                      Container(
                        width: 52,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.8),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                      // Spotlight Beam (Trapezoid Gradient Cone)
                      CustomPaint(
                        size: const Size(64, 52),
                        painter: _SpotlightBeamPainter(
                          color: AppColors.primary.withValues(alpha: 0.22),
                        ),
                      ),
                    ],
                  ),
                ),

                // Navigation Items Row
                Row(
                  children: List.generate(items.length, (index) {
                    final item = items[index];
                    final isActive = activeIndex == index;

                    return Expanded(
                      child: InkWell(
                        onTap: () {
                          onTabChange?.call(index);
                          item.onClick?.call();
                        },
                        borderRadius: BorderRadius.circular(AppRadius.card),
                        child: Center(
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 150),
                            opacity: isActive ? 1.0 : 0.4,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  item.icon,
                                  size: 22,
                                  color: isActive ? AppColors.primary : AppColors.textSecondary,
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  item.label,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                                    color: isActive ? AppColors.primary : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      );
      },
    );
  }
}

/// Custom painter for the Limelight spotlight beam cone
class _SpotlightBeamPainter extends CustomPainter {
  final Color color;

  _SpotlightBeamPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    // Polygon cone: (top: 25% to 75%, bottom: 5% to 95%)
    path.moveTo(size.width * 0.30, 0);
    path.lineTo(size.width * 0.70, 0);
    path.lineTo(size.width * 0.95, size.height);
    path.lineTo(size.width * 0.05, size.height);
    path.close();

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color,
          color.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
