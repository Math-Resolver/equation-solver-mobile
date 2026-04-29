import 'package:equation_solver_mobile/features/equation_solver/presentation/calculator/equation_solver_calculator_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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

    testWidgets('inserts root structure and renders root node', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: EquationSolverCalculatorPage()),
      );

      await tester.tap(find.byKey(const Key('structure_button_√')));
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
  });
}
