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
      child: CustomPaint(
        painter: _CornerPainter(top: top, left: left),
      ),
    ),
  );
}

class _CornerPainter extends CustomPainter {
  final bool top;
  final bool left;

  _CornerPainter({required this.top, required this.left});

  static const _strokeWidth = 5.0;
  static const _cornerSize = 30.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = _strokeWidth
      ..style = PaintingStyle.fill;

    _drawHorizontalLine(canvas, paint);
    _drawVerticalLine(canvas, paint);
  }

  void _drawHorizontalLine(Canvas canvas, Paint paint) {
    final y = top ? 0.0 : _cornerSize - _strokeWidth;
    canvas.drawRect(
      Rect.fromLTWH(0, y, _cornerSize, _strokeWidth),
      paint,
    );
  }

  void _drawVerticalLine(Canvas canvas, Paint paint) {
    final x = left ? 0.0 : _cornerSize - _strokeWidth;
    canvas.drawRect(
      Rect.fromLTWH(x, 0, _strokeWidth, _cornerSize),
      paint,
    );
  }

  @override
  bool shouldRepaint(_CornerPainter oldDelegate) {
    return oldDelegate.top != top || oldDelegate.left != left;
  }
}
