import 'package:equation_solver_mobile/drawables/app_colors.dart';
import 'package:flutter/material.dart';

class PlaceholderView extends StatelessWidget {
  final bool isActive;

  const PlaceholderView({required this.isActive, super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      width: 26,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.selected.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isActive ? AppColors.selected : const Color(0xFF9AA3AB),
          width: 1.2,
          style: BorderStyle.solid,
        ),
      ),
      child: Text(
        '□',
        style: TextStyle(
          color: isActive ? AppColors.selected : const Color(0xFF737B82),
          fontSize: 15,
        ),
      ),
    );
  }
}
