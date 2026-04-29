import 'package:equation_solver_mobile/features/equation_solver/presentation/calculator/equation_solver_calculator_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late EquationSolverCalculatorController controller;

  setUp(() {
    controller = EquationSolverCalculatorController();
  });

  group('Keyboard contracts', () {
    test('basic keyboard includes required symbols and semantic structures', () {
      controller.switchKeyboard('basic');

      expect(controller.activeKeyboard.symbols, containsAll(['7', '+', '×']));
      expect(
        controller.activeKeyboard.structures.map((item) => item.label),
        containsAll(['( )', '□/□', '|□|', '√', '□²']),
      );
    });

    test('available keyboards include all expected ids', () {
      expect(
        controller.availableKeyboards,
        containsAll(['basic', 'functions', 'trig', 'calculus', 'abc']),
      );
    });
  });

  group('Structured editing', () {
    test('inserting root then token serializes as root expression', () {
      controller.switchKeyboard('basic');
      controller.insertStructure('√');
      controller.insertSymbol('5');

      expect(controller.expression, '√(5)');
    });

    test('inserting power from □² keeps placeholder for exponent', () {
      controller.switchKeyboard('basic');
      controller.insertStructure('□²');
      controller.insertSymbol('x');

      expect(controller.expression, '(x)^(□)');
    });

    test('inserting absolute from |□| wraps content with pipes', () {
      controller.switchKeyboard('basic');
      controller.insertStructure('|□|');
      controller.insertSymbol('x');

      expect(controller.expression, '|x|');
    });

    test('left and right cursor navigation reaches denominator in fraction', () {
      controller.switchKeyboard('functions');
      controller.insertStructure('□/□');
      controller.insertSymbol('e');
      controller.moveCursorRight();
      controller.insertSymbol('z');

      expect(controller.expression, '(e)/(z)');
    });

    test('delete in empty structured slot removes parent block', () {
      controller.switchKeyboard('basic');
      controller.insertStructure('( )');
      controller.deleteCharacter();

      expect(controller.expression, '');
    });

    test('undo restores previous AST snapshot', () {
      controller.switchKeyboard('basic');
      controller.insertStructure('√');
      controller.insertSymbol('9');

      expect(controller.expression, '√(9)');
      controller.undo();
      expect(controller.expression, '√(□)');
    });

    test('loadExpression parses and keeps expression compatible', () {
      controller.loadExpression('√(9)+(1)/(2)');

      expect(controller.expression, '√(9)+(1)/(2)');
    });
  });
}
