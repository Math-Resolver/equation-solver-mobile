import '../models/math_ast.dart';

class MathExpressionSerializer {
  static String serializeRow(RowNode row) {
    final buffer = StringBuffer();
    for (final child in row.children) {
      buffer.write(serializeNode(child));
    }
    return buffer.toString();
  }

  static String serializeNode(MathNode node) {
    if (node is PlaceholderNode) {
      return '□';
    }

    if (node is TokenNode) {
      return node.value;
    }

    if (node is FractionNode) {
      final numerator = serializeRow(node.numerator);
      final denominator = serializeRow(node.denominator);
      return '($numerator)/($denominator)';
    }

    if (node is RootNode) {
      final radicand = serializeRow(node.radicand);
      return '√($radicand)';
    }

    if (node is PowerNode) {
      final base = serializeRow(node.base);
      final exponent = serializeRow(node.exponent);
      return '($base)^($exponent)';
    }

    if (node is ParenthesesNode) {
      final content = serializeRow(node.content);
      return '($content)';
    }

    if (node is AbsoluteNode) {
      final content = serializeRow(node.content);
      return '|$content|';
    }

    if (node is RowNode) {
      return serializeRow(node);
    }

    return '';
  }
}
