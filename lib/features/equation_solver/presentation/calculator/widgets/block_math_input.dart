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

    return Container(
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
        return GestureDetector(
          key: Key('placeholder_${node.id}'),
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
        return GestureDetector(
          onTap: () => onSelectionChanged(owner.id, index + 1),
          child: Text(
            node.value,
            style: const TextStyle(fontSize: 18, height: 1.2),
          ),
        );
      case FractionNode():
        return _buildStructuredNode(
          key: const Key('fraction_node'),
          node: node,
          child: FractionView(
            numerator: _buildRow(node.numerator),
            denominator: _buildRow(node.denominator),
          ),
        );
      case RootNode():
        return _buildStructuredNode(
          key: const Key('root_node'),
          node: node,
          child: RootView(child: _buildRow(node.radicand)),
        );
      case PowerNode():
        return _buildStructuredNode(
          key: const Key('power_node'),
          node: node,
          child: PowerView(
            base: _buildRow(node.base),
            exponent: _buildRow(node.exponent),
          ),
        );
      case ParenthesesNode():
        return _buildStructuredNode(
          key: const Key('parentheses_node'),
          node: node,
          child: ParenthesesView(child: _buildRow(node.content)),
        );
      case AbsoluteNode():
        return _buildStructuredNode(
          key: const Key('absolute_node'),
          node: node,
          child: AbsoluteView(child: _buildRow(node.content)),
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
