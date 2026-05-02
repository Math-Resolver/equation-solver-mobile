import '../models/math_ast.dart';
import '../services/math_expression_serializer.dart';

class SerializedCursorPositionCalculator {
  static const int _groupOpenLength = 1;
  static const int _fractionMiddleLength = 3; // )/(
  static const int _powerMiddleLength = 3; // )^(
  static const int _rootPrefixLength = 2; // √(

  static int find(MathEditorState state) {
    final result = _findInRow(
      state.root,
      state.selection.rowNodeId,
      state.selection.offset,
      0,
    );
    return result ?? MathExpressionSerializer.serializeRow(state.root).length;
  }

  static int? _findInRow(
    RowNode row,
    String targetRowId,
    int targetOffset,
    int start,
  ) {
    if (row.id == targetRowId) {
      var length = start;
      for (var i = 0; i < row.children.length; i++) {
        if (i == targetOffset) {
          return length;
        }
        length += MathExpressionSerializer.serializeNode(row.children[i]).length;
      }
      if (targetOffset == row.children.length) {
        return length;
      }
      return null;
    }

    var length = start;
    for (final child in row.children) {
      final childSize = MathExpressionSerializer.serializeNode(child).length;
      final found = _findInNode(child, targetRowId, targetOffset, length);
      if (found != null) {
        return found;
      }
      length += childSize;
    }
    return null;
  }

  static int? _findInNode(
    MathNode node,
    String targetRowId,
    int targetOffset,
    int start,
  ) {
    return switch (node) {
      FractionNode(:final numerator, :final denominator) => _findInDualGroupNode(
          first: numerator,
          second: denominator,
          targetRowId: targetRowId,
          targetOffset: targetOffset,
          start: start,
          middleLength: _fractionMiddleLength,
        ),
      RootNode(:final radicand) => _findInSingleGroupNode(
          row: radicand,
          targetRowId: targetRowId,
          targetOffset: targetOffset,
          start: start,
          prefixLength: _rootPrefixLength,
        ),
      PowerNode(:final base, :final exponent) => _findInDualGroupNode(
          first: base,
          second: exponent,
          targetRowId: targetRowId,
          targetOffset: targetOffset,
          start: start,
          middleLength: _powerMiddleLength,
        ),
      ParenthesesNode(:final content) => _findInSingleGroupNode(
          row: content,
          targetRowId: targetRowId,
          targetOffset: targetOffset,
          start: start,
        ),
      AbsoluteNode(:final content) => _findInSingleGroupNode(
          row: content,
          targetRowId: targetRowId,
          targetOffset: targetOffset,
          start: start,
        ),
      _ => null,
    };
  }

  static int? _findInSingleGroupNode({
    required RowNode row,
    required String targetRowId,
    required int targetOffset,
    required int start,
    int prefixLength = _groupOpenLength,
  }) {
    return _findInRow(
      row,
      targetRowId,
      targetOffset,
      start + prefixLength,
    );
  }

  static int? _findInDualGroupNode({
    required RowNode first,
    required RowNode second,
    required String targetRowId,
    required int targetOffset,
    required int start,
    required int middleLength,
  }) {
    final firstStart = start + _groupOpenLength;
    final firstResult = _findInRow(
      first,
      targetRowId,
      targetOffset,
      firstStart,
    );
    if (firstResult != null) {
      return firstResult;
    }

    final secondStart = firstStart +
        MathExpressionSerializer.serializeRow(first).length +
        middleLength;
    return _findInRow(
      second,
      targetRowId,
      targetOffset,
      secondStart,
    );
  }
}
