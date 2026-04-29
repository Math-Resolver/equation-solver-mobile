import 'package:flutter/material.dart';

import 'package:equation_solver_mobile/drawables/app_colors.dart';
import '../models/math_ast.dart';
import 'math_nodes/absolute_view.dart';
import 'math_nodes/fraction_view.dart';
import 'math_nodes/parentheses_view.dart';
import 'math_nodes/placeholder_view.dart';
import 'math_nodes/power_view.dart';
import 'math_nodes/root_view.dart';

class BlockMathInput extends StatelessWidget {
  static const double _inactiveCursorSlotWidth = 1;
  static const double _activeCursorSlotWidth = 8;

  final MathEditorState state;
  final void Function(String rowNodeId, int offset) onSelectionChanged;

  const BlockMathInput({
    required this.state,
    required this.onSelectionChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isEmpty = state.root.children.isEmpty;

    return CustomPaint(
      painter: _DashedBottomBorderPainter(),
      child: Container(
        key: const Key('expression_display'),
        width: double.infinity,
        alignment: Alignment.topLeft,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: isEmpty
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildCursorSlot(state.root.id, 0),
                    Text(
                      'Digite um problema matematico..',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.placeholderText,
                      ),
                    ),
                  ],
                )
              : _buildRow(state.root),
        ),
      ),
    );
  }

  Widget _buildRow(RowNode row) {
    final children = <Widget>[];

    for (var i = 0; i <= row.children.length; i++) {
      children.add(_buildCursorSlot(row.id, i));
      if (i < row.children.length) {
        children.add(_buildNode(row, i, row.children[i]));
      }
    }

    return Row(mainAxisSize: MainAxisSize.min, children: children);
  }

  Widget _buildCursorSlot(String rowId, int offset) {
    final isActive =
        state.selection.rowNodeId == rowId && state.selection.offset == offset;

    return GestureDetector(
      onTap: () => onSelectionChanged(rowId, offset),
      behavior: HitTestBehavior.translucent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: isActive ? _activeCursorSlotWidth : _inactiveCursorSlotWidth,
        height: 28,
        alignment: Alignment.center,
        child: isActive
            ? Container(
                key: const Key('cursor_indicator'),
                width: 2,
                height: 22,
                color: AppColors.selected,
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildNode(RowNode owner, int index, MathNode node) {
    switch (node) {
      case PlaceholderNode():
        final placeholder = node as PlaceholderNode;
        return GestureDetector(
          key: Key('placeholder_${placeholder.id}'),
          onTap: () => onSelectionChanged(owner.id, index),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: PlaceholderView(
              isActive: state.selection.rowNodeId == owner.id &&
                  state.selection.offset == index,
            ),
          ),
        );
      case TokenNode():
        final token = node as TokenNode;
        return GestureDetector(
          onTap: () => onSelectionChanged(owner.id, index + 1),
          child: Text(
            token.value,
            style: const TextStyle(fontSize: 18, height: 1.2),
          ),
        );
      case FractionNode():
        final fraction = node as FractionNode;
        return _buildStructuredNode(
          key: const Key('fraction_node'),
          node: fraction,
          child: FractionView(
            numerator: _buildRow(fraction.numerator),
            denominator: _buildRow(fraction.denominator),
          ),
        );
      case RootNode():
        final root = node as RootNode;
        return _buildStructuredNode(
          key: const Key('root_node'),
          node: root,
          child: RootView(child: _buildRow(root.radicand)),
        );
      case PowerNode():
        final power = node as PowerNode;
        return _buildStructuredNode(
          key: const Key('power_node'),
          node: power,
          child: PowerView(
            base: _buildRow(power.base),
            exponent: _buildRow(power.exponent),
          ),
        );
      case ParenthesesNode():
        final parentheses = node as ParenthesesNode;
        return _buildStructuredNode(
          key: const Key('parentheses_node'),
          node: parentheses,
          child: ParenthesesView(child: _buildRow(parentheses.content)),
        );
      case AbsoluteNode():
        final absolute = node as AbsoluteNode;
        return _buildStructuredNode(
          key: const Key('absolute_node'),
          node: absolute,
          child: AbsoluteView(child: _buildRow(absolute.content)),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStructuredNode({
    required Key key,
    required StructuredMathNode node,
    required Widget child,
  }) {
    return GestureDetector(
      key: key,
      onTap: () => _focusNodePrimarySlot(node),
      child: child,
    );
  }

  void _focusNodePrimarySlot(StructuredMathNode node) {
    final primaryRow = node.rowForSlot(node.primarySlotName);
    if (primaryRow != null) {
      onSelectionChanged(primaryRow.id, 0);
    }
  }
}

class _DashedBottomBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFBBBBBB)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const dashWidth = 5.0;
    const dashSpace = 4.0;
    double startX = 0;
    final y = size.height;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, y),
        Offset((startX + dashWidth).clamp(0, size.width), y),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(_DashedBottomBorderPainter oldDelegate) => false;
}
