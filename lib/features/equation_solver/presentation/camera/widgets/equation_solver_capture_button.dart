import 'package:flutter/material.dart';

class EquationSolverCaptureButton extends StatelessWidget {
  const EquationSolverCaptureButton({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const Key('capture_button'),
      onTap: onTap,
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.red, width: 4),
        ),
        child: const Center(
          child: CircleAvatar(radius: 25, backgroundColor: Colors.red),
        ),
      ),
    );
  }
}
