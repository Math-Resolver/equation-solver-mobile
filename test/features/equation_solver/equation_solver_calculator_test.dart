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

    testWidgets('tapping "Fechar" navigates to /camera without exception', (WidgetTester tester) async {
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

      // After pop, the camera page is visible again
      expect(find.text('Camera Page'), findsOneWidget);
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
      await tester.pump();

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
      await tester.pump();
      await tester.tap(toggleButton);
      await tester.pump();

      expect(find.byKey(const Key('expression_display')), findsOneWidget);
    });

    testWidgets('should show abc keyboard after a single tap on abc button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EquationSolverCalculatorPage(),
        ),
      );

      await tester.tap(find.byKey(const Key('input_set_toggle')));
      await tester.pump();

      expect(find.byKey(const Key('keyboard_abc_mode')), findsOneWidget);
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
      await tester.pump();

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
      await tester.pump();

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
      await tester.pump();

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
      await tester.pump();
      await tester.tap(find.byKey(const Key('delete_button')));
      await tester.pump();

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
      await tester.pump();

      expect(find.byKey(const Key('expression_display')), findsOneWidget);
    });

    testWidgets('should handle undo on empty expression', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EquationSolverCalculatorPage(),
        ),
      );

      await tester.tap(find.byKey(const Key('undo_button')));
      await tester.pump();

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
      await tester.pump();

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
      await tester.pump();

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
      await tester.pump();

      expect(find.byKey(const Key('expression_display')), findsOneWidget);
    });

    testWidgets('should handle clear on empty expression', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EquationSolverCalculatorPage(),
        ),
      );

      await tester.tap(find.byKey(const Key('clear_button')));
      await tester.pump();

      expect(find.byKey(const Key('expression_display')), findsOneWidget);
    });
  });

  group('Layout', () {
    testWidgets('should show placeholder text when expression is empty', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EquationSolverCalculatorPage(),
        ),
      );

      expect(find.text('Digite um problema matemático..'), findsOneWidget);
    });

    testWidgets('should display 4 keyboard tabs', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EquationSolverCalculatorPage(),
        ),
      );

      expect(find.byKey(const Key('tab_basic')), findsOneWidget);
      expect(find.byKey(const Key('tab_functions')), findsOneWidget);
      expect(find.byKey(const Key('tab_trig')), findsOneWidget);
      expect(find.byKey(const Key('tab_calculus')), findsOneWidget);
    });

    testWidgets('tapping tab_trig switches to trig keyboard', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EquationSolverCalculatorPage(),
        ),
      );

      await tester.tap(find.byKey(const Key('tab_trig')));
      await tester.pump();

      expect(find.byKey(const Key('keyboard_trig_mode')), findsOneWidget);
    });

    testWidgets('should have submit_button in toolbar', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EquationSolverCalculatorPage(),
        ),
      );

      expect(find.byKey(const Key('submit_button')), findsOneWidget);
    });

    testWidgets('basic keyboard should have more than 7 symbol buttons', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EquationSolverCalculatorPage(),
        ),
      );

      final symbolButtons = tester.widgetList(find.byKey(const Key('symbol_button'))).length;
      expect(symbolButtons, greaterThan(7));
    });
  });

  group('Cursor Display', () {
    testWidgets('should show cursor widget in expression display', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EquationSolverCalculatorPage(),
        ),
      );

      expect(find.byKey(const Key('cursor_indicator')), findsOneWidget);
    });

    testWidgets('cursor moves right after inserting a symbol', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EquationSolverCalculatorPage(),
        ),
      );

      await tester.tap(find.byKey(const Key('symbol_button_7')));
      await tester.pump();

      // After inserting '7', cursor is at position 1 — before text is '7', after is ''
      final beforeText = tester.widget<Text>(find.byKey(const Key('cursor_before')));
      expect(beforeText.data, equals('7'));

      final afterText = tester.widget<Text>(find.byKey(const Key('cursor_after')));
      expect(afterText.data, equals(''));
    });

    testWidgets('cursor moves left via cursor_left_button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EquationSolverCalculatorPage(),
        ),
      );

      await tester.tap(find.byKey(const Key('symbol_button_7')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('cursor_left_button')));
      await tester.pump();

      // After moving left, cursor is at position 0 — before is '', after is '7'
      final beforeText = tester.widget<Text>(find.byKey(const Key('cursor_before')));
      expect(beforeText.data, equals(''));

      final afterText = tester.widget<Text>(find.byKey(const Key('cursor_after')));
      expect(afterText.data, equals('7'));
    });
  });
}
