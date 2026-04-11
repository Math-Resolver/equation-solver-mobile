import 'package:flutter/material.dart';

import 'equation_solver_focus_corner.dart';

class EquationSolverFocusRectangle extends StatelessWidget {
  const EquationSolverFocusRectangle({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 225,
      left: 20,
      right: 20,
      child: SizedBox(
        width: 350,
        height: 110,
        child: Stack(
          children: [
            equationSolverFocusCorner(top: true, left: true),
            equationSolverFocusCorner(top: true, left: false),
            equationSolverFocusCorner(top: false, left: true),
            equationSolverFocusCorner(top: false, left: false),
          ],
        ),
      ),
    );
  }
}
