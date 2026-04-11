import 'package:equation_solver_mobile/features/equation_solver/presentation/calculator/equation_solver_calculator_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late EquationSolverCalculatorController controller;

  setUp(() {
    controller = EquationSolverCalculatorController();
  });

  group('Basic Keyboard Symbols', () {
    test('should include digits 0–9 in basic keyboard symbols', () {
      controller.switchKeyboard('basic');
      for (final digit in ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']) {
        expect(
          controller.activeKeyboard.symbols.contains(digit),
          isTrue,
          reason: 'Expected digit $digit to be in basic keyboard symbols',
        );
      }
    });

    test('should include standard operators in basic keyboard symbols', () {
      controller.switchKeyboard('basic');
      for (final op in ['+', '-', '×', '÷', '=']) {
        expect(
          controller.activeKeyboard.symbols.contains(op),
          isTrue,
          reason: 'Expected operator $op to be in basic keyboard symbols',
        );
      }
    });

    test('should have √ and □² as structures in basic keyboard', () {
      controller.switchKeyboard('basic');
      expect(controller.activeKeyboard.structures, containsAll(['√', '□²']));
    });

    test('( ) should be a structure (not a symbol) in basic keyboard', () {
      controller.switchKeyboard('basic');
      expect(controller.activeKeyboard.structures.contains('( )'), isTrue);
      expect(controller.activeKeyboard.symbols.contains('( )'), isFalse);
    });
  });

  group('Structure Insertion Placeholders', () {
    test('inserting √ produces √□ and positions cursor at □', () {
      controller.switchKeyboard('basic');
      controller.insertStructure('√');
      expect(controller.expression, equals('√□'));
      expect(controller.cursorPosition, equals(1));
    });

    test('inserting □² produces □² and positions cursor at □ (before ²)', () {
      controller.switchKeyboard('basic');
      controller.insertStructure('□²');
      expect(controller.expression, equals('□²'));
      expect(controller.cursorPosition, equals(0));
    });

    test('inserting ( ) produces (□) and positions cursor at □', () {
      controller.switchKeyboard('basic');
      controller.insertStructure('( )');
      expect(controller.expression, equals('(□)'));
      expect(controller.cursorPosition, equals(1));
    });
  });

  group('Placeholder Replacement on Typing', () {
    test('typing after √ replaces □ in √□', () {
      controller.switchKeyboard('basic');
      controller.insertStructure('√');
      controller.insertSymbol('5');
      expect(controller.expression, equals('√5'));
      expect(controller.cursorPosition, equals(2));
    });

    test('typing after □² replaces □ in □²', () {
      controller.switchKeyboard('basic');
      controller.insertStructure('□²');
      controller.insertSymbol('x');
      expect(controller.expression, equals('x²'));
      expect(controller.cursorPosition, equals(1));
    });

    test('typing after ( ) replaces □ in (□)', () {
      controller.switchKeyboard('basic');
      controller.insertStructure('( )');
      controller.insertSymbol('3');
      expect(controller.expression, equals('(3)'));
      expect(controller.cursorPosition, equals(2));
    });

    test('typing when cursor is NOT before □ inserts normally', () {
      controller.switchKeyboard('basic');
      controller.insertSymbol('2');
      controller.insertSymbol('+');
      expect(controller.expression, equals('2+'));
      expect(controller.cursorPosition, equals(2));
    });
  });

  group('Basic Keyboard Symbols continued', () {

    test('should have orderedLayout with 24 entries in basic keyboard', () {
      controller.switchKeyboard('basic');
      expect(controller.activeKeyboard.orderedLayout, isNotNull);
      expect(controller.activeKeyboard.orderedLayout!.length, equals(24));
    });

    test('isSymbolAllowed returns true for digit 7 in basic mode', () {
      controller.switchKeyboard('basic');
      expect(controller.isSymbolAllowed('7'), isTrue);
    });
  });

  group('Functions Keyboard', () {
    test('should include log in functions keyboard', () {
      controller.switchKeyboard('functions');
      expect(controller.activeKeyboard.symbols.contains('log'), isTrue);
    });

    test('should include ln in functions keyboard', () {
      controller.switchKeyboard('functions');
      expect(controller.activeKeyboard.symbols.contains('ln'), isTrue);
    });

    test('should NOT include sin in functions keyboard', () {
      controller.switchKeyboard('functions');
      expect(controller.activeKeyboard.symbols.contains('sin'), isFalse);
    });
  });

  group('Trig Keyboard', () {
    test('switchKeyboard changes activeKeyboardType to trig', () {
      controller.switchKeyboard('trig');
      expect(controller.activeKeyboardType, equals('trig'));
    });

    test('should include sin, cos, tan, cot in trig keyboard', () {
      controller.switchKeyboard('trig');
      for (final s in ['sin', 'cos', 'tan', 'cot']) {
        expect(
          controller.activeKeyboard.symbols.contains(s),
          isTrue,
          reason: 'Expected $s in trig keyboard',
        );
      }
    });

    test('isSymbolAllowed returns true for sin in trig mode', () {
      controller.switchKeyboard('trig');
      expect(controller.isSymbolAllowed('sin'), isTrue);
    });
  });

  group('Calculus Keyboard', () {
    test('switchKeyboard changes activeKeyboardType to calculus', () {
      controller.switchKeyboard('calculus');
      expect(controller.activeKeyboardType, equals('calculus'));
    });

    test('should include lim, dx, Σ, ∫, ∞ in calculus keyboard', () {
      controller.switchKeyboard('calculus');
      for (final s in ['lim', 'dx', 'Σ', '∫', '∞']) {
        expect(
          controller.activeKeyboard.symbols.contains(s),
          isTrue,
          reason: 'Expected $s in calculus keyboard',
        );
      }
    });

    test('isSymbolAllowed returns true for Σ in calculus mode', () {
      controller.switchKeyboard('calculus');
      expect(controller.isSymbolAllowed('Σ'), isTrue);
    });
  });

  group('Keyboard Order', () {
    test('availableKeyboards should include basic, functions, trig, calculus, abc', () {
      expect(
        controller.availableKeyboards,
        containsAll(['basic', 'functions', 'trig', 'calculus', 'abc']),
      );
    });

    test('getKeyboard returns the correct KeyboardType', () {
      final trig = controller.getKeyboard('trig');
      expect(trig.id, equals('trig'));
    });
  });
}
