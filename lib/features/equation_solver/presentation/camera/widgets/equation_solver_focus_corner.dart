import 'package:flutter/material.dart';

Widget equationSolverFocusCorner({required bool top, required bool left}) {
  return Positioned(
    top: top ? 0 : null,
    bottom: top ? null : 0,
    left: left ? 0 : null,
    right: left ? null : 0,
    child: SizedBox(
      width: 30,
      height: 30,
      child: Stack(
        children: [
          // linha horizontal
          if (top)
            Align(
              alignment: Alignment.topCenter,
              child: Container(height: 5, width: 30, color: Colors.white),
            ),
          if (!top)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(height: 5, width: 30, color: Colors.white),
            ),

          // linha vertical
          if (left)
            Align(
              alignment: Alignment.centerLeft,
              child: Container(width: 5, height: 30, color: Colors.white),
            ),
          if (!left)
            Align(
              alignment: Alignment.centerRight,
              child: Container(width: 5, height: 30, color: Colors.white),
            ),
        ],
      ),
    ),
  );
}
