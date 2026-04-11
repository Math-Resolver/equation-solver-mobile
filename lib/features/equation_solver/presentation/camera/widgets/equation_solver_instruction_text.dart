import 'package:flutter/material.dart';

class EquationSolverInstructionText extends StatelessWidget {
  const EquationSolverInstructionText({super.key});

  @override
  Widget build(BuildContext context) {
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
          child: const Text(
            'Fotografa um problema de matemática',
            style: TextStyle(
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
