import 'package:flutter/material.dart';
import 'package:equation_solver_mobile/core/localization/app_localization_scope.dart';
import 'package:equation_solver_mobile/core/localization/app_text_key.dart';

class EquationSolverInstructionText extends StatelessWidget {
  const EquationSolverInstructionText({super.key});

  @override
  Widget build(BuildContext context) {
    final localeController = AppLocalizationScope.of(context);

    return Positioned(
      bottom: 210,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            localeController.text(AppTextKey.cameraInstruction),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
