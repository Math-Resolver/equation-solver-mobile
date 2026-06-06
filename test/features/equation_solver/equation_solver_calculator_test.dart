import 'package:equation_solver_mobile/features/equation_solver/presentation/calculator/equation_solver_calculator_page.dart';
import 'package:equation_solver_mobile/features/equation_solver/repository/equation_solver_repository_interface.dart';
import 'package:equation_solver_mobile/features/equation_solver/repository/models/equation_solution.dart';
import 'package:equation_solver_mobile/core/http/http_exception.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeEquationRepository implements IEquationSolverRepositoryInterface {
  FakeEquationRepository({this.solution, this.solveError});

  final EquationSolution? solution;
  final Object? solveError;
  int solveCallCount = 0;

  @override
  Future<String> getRecognizedText(String path) async => '';

  @override
  Future<EquationSolution> solveEquation({
    required String equation,
    bool showSteps = true,
  }) async {
    solveCallCount++;
    if (solveError != null) {
      throw solveError!;
    }
    return solution ?? const EquationSolution(result: 'x = 1', steps: []);
  }
}

void main() {
  group('EquationSolverCalculatorPage', () {
    testWidgets('renders header and expression display', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: EquationSolverCalculatorPage()),
      );

      expect(find.text('Calculadora'), findsOneWidget);
      expect(find.byKey(const Key('expression_display')), findsOneWidget);
      expect(find.byKey(const Key('cursor_indicator')), findsOneWidget);
    });

    testWidgets('inserts numeric symbol from keyboard', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: EquationSolverCalculatorPage()),
      );

      await tester.tap(find.byKey(const Key('symbol_button_7')));
      await tester.pump();

      expect(find.text('7'), findsWidgets);
    });

    testWidgets('renders root node from initial expression', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EquationSolverCalculatorPage(initialExpression: '√(9)'),
        ),
      );
      await tester.pump();

      expect(find.byKey(const Key('root_node')), findsOneWidget);
    });

    testWidgets('inserts power structure and renders power node', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: EquationSolverCalculatorPage()),
      );

      await tester.tap(find.byKey(const Key('structure_button_□²')));
      await tester.pump();

      expect(find.byKey(const Key('power_node')), findsOneWidget);
    });

    testWidgets('switches tabs and shows trig keyboard mode', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: EquationSolverCalculatorPage()),
      );

      await tester.tap(find.byKey(const Key('tab_trig')));
      await tester.pump();

      expect(find.byKey(const Key('keyboard_trig_mode')), findsOneWidget);
    });

    testWidgets('undo button keeps page stable', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: EquationSolverCalculatorPage()),
      );

      await tester.tap(find.byKey(const Key('undo_button')));
      await tester.pump();

      expect(find.byType(EquationSolverCalculatorPage), findsOneWidget);
    });

    testWidgets('close button pops to camera route', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          initialRoute: '/camera/calculator',
          routes: {
            '/camera': (_) => const Scaffold(body: Text('Camera Page')),
            '/camera/calculator': (_) => const EquationSolverCalculatorPage(),
          },
        ),
      );

      await tester.tap(find.text('Fechar'));
      await tester.pump();

      expect(find.text('Camera Page'), findsOneWidget);
    });

    testWidgets('does not call solve before 1 second of inactivity', (
      tester,
    ) async {
      final repository = FakeEquationRepository();

      await tester.pumpWidget(
        MaterialApp(home: EquationSolverCalculatorPage(repository: repository)),
      );

      await tester.tap(find.byKey(const Key('symbol_button_7')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 900));

      expect(repository.solveCallCount, 0);
    });

    testWidgets('calls solve after 1 second of inactivity', (tester) async {
      final repository = FakeEquationRepository();

      await tester.pumpWidget(
        MaterialApp(home: EquationSolverCalculatorPage(repository: repository)),
      );

      await tester.tap(find.byKey(const Key('symbol_button_7')));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(repository.solveCallCount, 1);
      expect(find.text('x = 1'), findsOneWidget);
    });

    testWidgets('shows specific message for bad request status 400', (
      tester,
    ) async {
      final repository = FakeEquationRepository(
        solveError: const HttpException(statusCode: 400, message: 'bad request'),
      );

      await tester.pumpWidget(
        MaterialApp(home: EquationSolverCalculatorPage(repository: repository)),
      );

      await tester.tap(find.byKey(const Key('symbol_button_7')));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(find.text('Equacao invalida ou nao pode ser resolvida.'), findsOneWidget);
    });

    testWidgets('opens modal with solve steps when response has steps', (
      tester,
    ) async {
      final repository = FakeEquationRepository(
        solution: const EquationSolution(
          result: 'x = 5',
          steps: [
            EquationSolveStep(
              rule: 'subtract 5',
              before: '2x + 5 = 15',
              after: '2x = 10',
            ),
          ],
        ),
      );

      await tester.pumpWidget(
        MaterialApp(home: EquationSolverCalculatorPage(repository: repository)),
      );

      await tester.tap(find.byKey(const Key('symbol_button_7')));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(find.text('x = 5'), findsOneWidget);
      expect(find.byKey(const Key('solve_steps_open_button')), findsOneWidget);
      expect(find.byKey(const Key('solve_steps_modal_list')), findsNothing);

      await tester.tap(find.byKey(const Key('solve_steps_open_button')));
      await tester.pumpAndSettle();

      expect(find.text('Passo 1 de 1'), findsOneWidget);
      expect(find.text('subtract 5'), findsOneWidget);
      expect(find.text('2x + 5 = 15'), findsOneWidget);
      expect(find.text('2x = 10'), findsOneWidget);

      await tester.tap(find.byKey(const Key('solve_steps_modal_close_button')));
      await tester.pumpAndSettle();

      expect(find.text('Passo 1 de 1'), findsNothing);
    });

    testWidgets('navigates between animated solve steps', (tester) async {
      final repository = FakeEquationRepository(
        solution: const EquationSolution(
          result: 'x = 3',
          steps: [
            EquationSolveStep(
              rule: 'subtract 4',
              before: '2x + 4 = 10',
              after: '2x = 6',
            ),
            EquationSolveStep(
              rule: 'divide by 2',
              before: '2x = 6',
              after: 'x = 3',
            ),
          ],
        ),
      );

      await tester.pumpWidget(
        MaterialApp(home: EquationSolverCalculatorPage(repository: repository)),
      );

      await tester.tap(find.byKey(const Key('symbol_button_7')));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('solve_steps_open_button')));
      await tester.pumpAndSettle();

      expect(find.text('Passo 1 de 2'), findsOneWidget);
      expect(find.text('subtract 4'), findsOneWidget);
      expect(find.text('2x + 4 = 10'), findsOneWidget);
      expect(find.text('2x = 6'), findsOneWidget);

      await tester.tap(find.byKey(const Key('solve_steps_next_button')));
      await tester.pumpAndSettle();

      expect(find.text('Passo 2 de 2'), findsOneWidget);
      expect(find.text('divide by 2'), findsOneWidget);
      expect(find.text('x = 3'), findsWidgets);
      expect(find.byKey(const Key('solve_steps_next_button')), findsOneWidget);

      await tester.tap(find.byKey(const Key('solve_steps_previous_button')));
      await tester.pumpAndSettle();

      expect(find.text('Passo 1 de 2'), findsOneWidget);
    });

    testWidgets('does not show step modal CTA when response has no steps', (
      tester,
    ) async {
      final repository = FakeEquationRepository(
        solution: const EquationSolution(result: 'x = 5', steps: []),
      );

      await tester.pumpWidget(
        MaterialApp(home: EquationSolverCalculatorPage(repository: repository)),
      );

      await tester.tap(find.byKey(const Key('symbol_button_7')));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(find.text('x = 5'), findsOneWidget);
      expect(find.byKey(const Key('solve_steps_open_button')), findsNothing);
    });
  });
}
