import 'package:equation_solver_mobile/features/equation_solver/presentation/calculator/services/math_expression_parser.dart';
import 'package:equation_solver_mobile/features/equation_solver/presentation/calculator/services/math_expression_serializer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses expression with root, fraction and power', () {
    final state = MathExpressionParser.parseToState('√(9)+(1)/(2)+(x)^(2)');
    final serialized = MathExpressionSerializer.serializeRow(state.root);

    expect(serialized, '√(9)+(1)/(2)+(x)^(2)');
  });

  test('parses expression with absolute value structure', () {
    final state = MathExpressionParser.parseToState('|x+1|');
    final serialized = MathExpressionSerializer.serializeRow(state.root);

    expect(serialized, '|x+1|');
  });

  test('falls back to token row for unsupported content', () {
    final state = MathExpressionParser.parseToState('a+b');
    final serialized = MathExpressionSerializer.serializeRow(state.root);

    expect(serialized, 'a+b');
  });
}
