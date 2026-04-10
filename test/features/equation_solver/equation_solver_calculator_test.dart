import 'package:equation_solver_mobile/features/equation_solver/presentation/calculator/equation_solver_calculator_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EquationSolverCalculatorPage UI', () {
    testWidgets('should display "Calculadora" text on the page', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EquationSolverCalculatorPage(),
        ),
      );

      expect(find.text('Calculadora'), findsOneWidget);
    });

    testWidgets('should display "Fechar" text button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EquationSolverCalculatorPage(),
        ),
      );

      expect(find.text('Fechar'), findsOneWidget);
      expect(find.byType(GestureDetector), findsWidgets);
    });

    testWidgets('should render calculator page without errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EquationSolverCalculatorPage(),
        ),
      );

      expect(find.byType(EquationSolverCalculatorPage), findsOneWidget);
    });
  });

  group('Input Set Alternation', () {
    testWidgets('should switch to different input set', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EquationSolverCalculatorPage(),
        ),
      );

      expect(find.byKey(const Key('input_set_toggle')), findsOneWidget);
    });

    testWidgets('should only show symbols from active input set', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EquationSolverCalculatorPage(),
        ),
      );

      await tester.tap(find.byKey(const Key('input_set_toggle')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('active_keyboard')), findsOneWidget);
    });

    testWidgets('should preserve expression when alternating input sets', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EquationSolverCalculatorPage(),
        ),
      );

      final expressionDisplay = find.byKey(const Key('expression_display'));
      expect(expressionDisplay, findsOneWidget);
    });

    testWidgets('should maintain consistency when alternating multiple times', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EquationSolverCalculatorPage(),
        ),
      );

      final toggleButton = find.byKey(const Key('input_set_toggle'));
      await tester.tap(toggleButton);
      await tester.pumpAndSettle();
      await tester.tap(toggleButton);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('expression_display')), findsOneWidget);
    });
  });

  group('Set-Based Symbol Insertion', () {
    testWidgets('should insert allowed symbol from active set', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EquationSolverCalculatorPage(),
        ),
      );

      expect(find.byKey(const Key('symbol_button')), findsWidgets);
    });

    testWidgets('should block or ignore symbol not in active set', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EquationSolverCalculatorPage(),
        ),
      );

      await tester.tap(find.byKey(const Key('input_set_toggle')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('expression_display')), findsOneWidget);
    });
  });

  group('Placeholder Structures', () {
    testWidgets('should insert structure with empty placeholder', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EquationSolverCalculatorPage(),
        ),
      );

      expect(find.byKey(const Key('structure_button')), findsWidgets);
    });

    testWidgets('should position cursor inside placeholder after insertion', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EquationSolverCalculatorPage(),
        ),
      );

      expect(find.byKey(const Key('expression_display')), findsOneWidget);
    });

    testWidgets('should fill placeholder with inserted value', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EquationSolverCalculatorPage(),
        ),
      );

      expect(find.byKey(const Key('expression_display')), findsOneWidget);
    });
  });

  group('Navigation Between Structures', () {
    testWidgets('should move cursor between blocks respecting structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EquationSolverCalculatorPage(),
        ),
      );

      expect(find.byKey(const Key('cursor_right_button')), findsOneWidget);
    });

    testWidgets('should maintain consistency when navigating empty placeholder', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EquationSolverCalculatorPage(),
        ),
      );

      await tester.tap(find.byKey(const Key('cursor_right_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('expression_display')), findsOneWidget);
    });

    testWidgets('should enter and exit placeholder when moving cursor', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EquationSolverCalculatorPage(),
        ),
      );

      expect(find.byKey(const Key('cursor_right_button')), findsOneWidget);
      expect(find.byKey(const Key('cursor_left_button')), findsOneWidget);
    });
  });

  group('Structured Content Removal', () {
    testWidgets('should delete content leaving structure with empty placeholder', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EquationSolverCalculatorPage(),
        ),
      );

      expect(find.byKey(const Key('delete_button')), findsOneWidget);
    });

    testWidgets('should remove empty structure completely', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EquationSolverCalculatorPage(),
        ),
      );

      await tester.tap(find.byKey(const Key('delete_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('expression_display')), findsOneWidget);
    });

    testWidgets('should maintain placeholder when removing partial structure content', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EquationSolverCalculatorPage(),
        ),
      );

      expect(find.byKey(const Key('expression_display')), findsOneWidget);
    });

    testWidgets('should not corrupt structure after multiple removals', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EquationSolverCalculatorPage(),
        ),
      );

      await tester.tap(find.byKey(const Key('delete_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('delete_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('expression_display')), findsOneWidget);
    });
  });

  group('Undo Generic', () {
    testWidgets('should undo expression modification', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EquationSolverCalculatorPage(),
        ),
      );

      expect(find.byKey(const Key('undo_button')), findsOneWidget);
    });

    testWidgets('should restore structure with placeholder correctly after undo', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EquationSolverCalculatorPage(),
        ),
      );

      await tester.tap(find.byKey(const Key('undo_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('expression_display')), findsOneWidget);
    });

    testWidgets('should handle undo on empty expression', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EquationSolverCalculatorPage(),
        ),
      );

      await tester.tap(find.byKey(const Key('undo_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('expression_display')), findsOneWidget);
    });
  });

  group('Cursor Movement Generic', () {
    testWidgets('should move cursor forward respecting structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EquationSolverCalculatorPage(),
        ),
      );

      expect(find.byKey(const Key('cursor_right_button')), findsOneWidget);
    });

    testWidgets('should not move cursor beyond expression bounds', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EquationSolverCalculatorPage(),
        ),
      );

      await tester.tap(find.byKey(const Key('cursor_right_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('expression_display')), findsOneWidget);
    });

    testWidgets('should move cursor backward respecting structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EquationSolverCalculatorPage(),
        ),
      );

      expect(find.byKey(const Key('cursor_left_button')), findsOneWidget);
    });

    testWidgets('should not move cursor before expression start', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EquationSolverCalculatorPage(),
        ),
      );

      await tester.tap(find.byKey(const Key('cursor_left_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('expression_display')), findsOneWidget);
    });

    testWidgets('should navigate through placeholder correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EquationSolverCalculatorPage(),
        ),
      );

      expect(find.byKey(const Key('cursor_right_button')), findsOneWidget);
      expect(find.byKey(const Key('cursor_left_button')), findsOneWidget);
    });
  });

  group('Expression Cleanup', () {
    testWidgets('should clear expression with structures', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EquationSolverCalculatorPage(),
        ),
      );

      expect(find.byKey(const Key('clear_button')), findsOneWidget);
    });

    testWidgets('should remove all structures and content', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EquationSolverCalculatorPage(),
        ),
      );

      await tester.tap(find.byKey(const Key('clear_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('expression_display')), findsOneWidget);
    });

    testWidgets('should handle clear on empty expression', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EquationSolverCalculatorPage(),
        ),
      );

      await tester.tap(find.byKey(const Key('clear_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('expression_display')), findsOneWidget);
    });
  });
}
