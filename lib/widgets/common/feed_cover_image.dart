import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class FeedCoverImage extends StatelessWidget {
  const FeedCoverImage({
    super.key,
    required this.imagePath,
    this.height,
    this.width,
    this.borderRadius,
    this.icon = Icons.event_rounded,
    this.iconSize = 48,
  });

  final String imagePath;
  final double? height;
  final double? width;
  final BorderRadius? borderRadius;
  final IconData icon;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.zero;
    final hasFile = imagePath.isNotEmpty && File(imagePath).existsSync();

    if (hasFile) {
      return ClipRRect(
        borderRadius: radius,
        child: Image.file(
          File(imagePath),
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder(radius),
        ),
      );
    }

    return _placeholder(radius);
  }

  Widget _placeholder(BorderRadius radius) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          colors: [
            AppColors.gold.withValues(alpha: 0.15),
            AppColors.background,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(icon, size: iconSize, color: AppColors.gold),
      ),
    );
  }
}
