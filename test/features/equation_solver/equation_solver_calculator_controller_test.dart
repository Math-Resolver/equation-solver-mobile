import 'package:equation_solver_mobile/features/equation_solver/presentation/calculator/equation_solver_calculator_controller.dart';
import 'package:equation_solver_mobile/features/equation_solver/repository/equation_solver_repository_interface.dart';
import 'package:equation_solver_mobile/features/equation_solver/repository/models/equation_solution.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockEquationRepository extends Mock
    implements IEquationSolverRepositoryInterface {}

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

  group('Solve via API', () {
    late MockEquationRepository repository;
    late EquationSolverCalculatorController controllerWithRepo;

    setUp(() {
      repository = MockEquationRepository();
      controllerWithRepo = EquationSolverCalculatorController(
        repository: repository,
      );
    });

    test('solve calls repository with current expression and showSteps true', () async {
      controllerWithRepo.loadExpression('2*x+5=15');
      when(
        () => repository.solveEquation(
          equation: '2*x+5=15',
          showSteps: true,
        ),
      ).thenAnswer(
        (_) async => const EquationSolution(result: 'x = 5', steps: []),
      );

      await controllerWithRepo.solve();

      verify(
        () => repository.solveEquation(equation: '2*x+5=15', showSteps: true),
      ).called(1);
      expect(controllerWithRepo.solution?.result, 'x = 5');
    });

    test('solve sets isLoading to true then false around the call', () async {
      controllerWithRepo.loadExpression('x=1');
      when(
        () => repository.solveEquation(equation: any(named: 'equation'), showSteps: any(named: 'showSteps')),
      ).thenAnswer((_) async {
        expect(controllerWithRepo.isLoading, isTrue);
        return const EquationSolution(result: 'x = 1', steps: []);
      });

      await controllerWithRepo.solve();

      expect(controllerWithRepo.isLoading, isFalse);
    });

    test('solve sets solveError when repository throws', () async {
      controllerWithRepo.loadExpression('bad');
      when(
        () => repository.solveEquation(equation: any(named: 'equation'), showSteps: any(named: 'showSteps')),
      ).thenThrow(Exception('network error'));

      await controllerWithRepo.solve();

      expect(controllerWithRepo.solveError, isNotNull);
      expect(controllerWithRepo.solution, isNull);
    });
  });
}
