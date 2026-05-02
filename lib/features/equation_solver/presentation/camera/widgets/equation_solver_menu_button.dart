import 'package:flutter/material.dart';

class EquationSolverMenuButton extends StatelessWidget {
  const EquationSolverMenuButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 40,
      left: 10,
      child: IconButton(
        icon: const Icon(Icons.menu, color: Colors.white, size: 30),
        onPressed: onPressed,
      ),
    );
  }
}
