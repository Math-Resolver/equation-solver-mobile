import 'package:equation_solver_mobile/features/equation_solver/presentation/calculator/models/math_ast.dart';
import 'package:equation_solver_mobile/features/equation_solver/presentation/calculator/services/math_expression_serializer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('serializes basic structures', () {
    const row = RowNode(
      id: 'row_0',
      children: [
        FractionNode(
          id: 'f',
          numerator: RowNode(
            id: 'n',
            children: [TokenNode(id: 't1', value: '1')],
          ),
          denominator: RowNode(
            id: 'd',
            children: [TokenNode(id: 't2', value: '2')],
          ),
        ),
        RootNode(
          id: 'r',
          radicand: RowNode(
            id: 'rad',
            children: [TokenNode(id: 't3', value: '9')],
          ),
        ),
        PowerNode(
          id: 'p',
          base: RowNode(id: 'b', children: [TokenNode(id: 't4', value: 'x')]),
          exponent: RowNode(
            id: 'e',
            children: [TokenNode(id: 't5', value: '2')],
          ),
        ),
        AbsoluteNode(
          id: 'a',
          content: RowNode(
            id: 'c',
            children: [TokenNode(id: 't6', value: 'z')],
          ),
        ),
      ],
    );

    expect(MathExpressionSerializer.serializeRow(row), '(1)/(2)√(9)(x)^(2)|z|');
  });
}
