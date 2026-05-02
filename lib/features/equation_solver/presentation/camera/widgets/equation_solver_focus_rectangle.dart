import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'equation_solver_focus_corner.dart';

class EquationSolverFocusRectangle extends StatelessWidget {
  const EquationSolverFocusRectangle({super.key});

  static const double topOffset = 225;
  static const double horizontalPadding = 20;
  static const double focusHeight = 110;

  static Rect rectFor(Size viewportSize) {
    final width = math.max(0.0, viewportSize.width - (horizontalPadding * 2));
    return Rect.fromLTWH(horizontalPadding, topOffset, width, focusHeight);
  }

  @override
  Widget build(BuildContext context) {
    final focusRect = rectFor(MediaQuery.sizeOf(context));

    return Positioned(
      top: focusRect.top,
      left: focusRect.left,
      right: horizontalPadding,
      child: SizedBox(
        key: const Key('camera_focus_rectangle'),
        width: focusRect.width,
        height: focusRect.height,
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
