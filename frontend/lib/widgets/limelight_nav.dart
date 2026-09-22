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

/// Premium floating navigation bar with a subtle spotlight indicator.
/// Frosted glass surface with a sliding pill highlight.
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
        final totalWidth = constraints.maxWidth > 460 ? 420.0 : constraints.maxWidth - 40;
        final itemWidth = totalWidth / items.length;

        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: totalWidth,
              height: 68,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.5),
                  width: 1,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x10000000),
                    blurRadius: 32,
                    offset: Offset(0, 12),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Color(0x06000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Animated pill indicator behind active item
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutCubic,
                    left: activeIndex * itemWidth + 6,
                    top: 6,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOutCubic,
                      width: itemWidth - 12,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),

                  // Top accent line for active tab
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutCubic,
                    left: activeIndex * itemWidth + (itemWidth / 2) - 14,
                    top: 0,
                    child: Container(
                      width: 28,
                      height: 3,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
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
                          borderRadius: BorderRadius.circular(16),
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          child: Center(
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                                color: isActive ? AppColors.primary : AppColors.textMuted,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AnimatedScale(
                                    scale: isActive ? 1.0 : 0.92,
                                    duration: const Duration(milliseconds: 200),
                                    child: Icon(
                                      item.icon,
                                      size: 22,
                                      color: isActive ? AppColors.primary : AppColors.textMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(item.label),
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
