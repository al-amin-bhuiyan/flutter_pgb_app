import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/dimensions.dart';

class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;
  final double? size;

  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        icon,
        color: color ?? AppColors.textSecondary,
        size: size ?? AppDimensions.iconL,
      ),
      onPressed: onPressed,
    );
  }
}
