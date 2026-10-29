import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// Card hero con imagen, badges "Triaje Clínico IA" / "Guardia Médica"
/// y degradado inferior con el slogan.
class HeroBanner extends StatelessWidget {
  const HeroBanner({super.key});

  static const _imageUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuB4rSqHwJtkHV5Yt1vGrh1JfeeLNyoFVLOp00dPvooWpE6tTPTVd-LXa9I39Il7dsZzc5hHN9eadWB3ncqmos-X2U3-ozMpnQ3hNd52GSndiwVy19jRin7nYq7rkiCgb3dDC8mozf9Q1O6ZquTEmNq_mxOZmKP0UmTfoF6XzEiuXt8BOKo3FtQgLCvb5_xXquMbPAZh3cWW0TxWdGCvJ3ZQ6Cs0TDQnOL43-vf8J1f3znPobTRzpqW1';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 256,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            _imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return const ColoredBox(color: AppColors.surfaceContainerLow);
            },
            errorBuilder: (context, error, stackTrace) => const ColoredBox(
              color: AppColors.surfaceContainer,
              child: Icon(
                Icons.pets,
                size: 64,
                color: AppColors.primaryContainer,
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.onBackground.withValues(alpha: 0),
                  AppColors.onBackground.withValues(alpha: 0.15),
                  AppColors.onBackground.withValues(alpha: 0.8),
                ],
              ),
            ),
          ),
          Positioned(
            left: AppSpacing.md,
            right: AppSpacing.md,
            bottom: AppSpacing.md,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: [
                    _PillBadge(
                      backgroundColor: AppColors.primaryContainer,
                      foregroundColor: AppColors.surfaceContainerLowest,
                      icon: Icons.verified,
                      label: 'Triaje Clínico IA',
                    ),
                    _PillBadge(
                      backgroundColor: AppColors.surfaceContainerLowest
                          .withValues(alpha: 0.9),
                      foregroundColor: AppColors.onSurface,
                      label: 'Guardia Médica',
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Cuidado compasivo con respuesta inmediata',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.surfaceContainerLowest,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PillBadge extends StatelessWidget {
  const _PillBadge({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.label,
    this.icon,
  });

  final Color backgroundColor;
  final Color foregroundColor;
  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: foregroundColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(color: foregroundColor),
          ),
        ],
      ),
    );
  }
}
