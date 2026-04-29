import 'package:equation_solver_mobile/features/equation_solver/presentation/calculator/models/math_ast.dart';
import 'package:equation_solver_mobile/features/equation_solver/presentation/calculator/services/math_editor_reducer.dart';
import 'package:equation_solver_mobile/features/equation_solver/presentation/calculator/services/math_expression_serializer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MathEditorReducer', () {
    test('inserts fraction and focuses numerator slot', () {
      var state = MathEditorState.initial();
      state = MathEditorReducer.insertStructure(state, MathStructureType.fraction);
      state = MathEditorReducer.insertToken(state, '1');
      state = MathEditorReducer.moveRight(state);
      state = MathEditorReducer.insertToken(state, '2');

      expect(MathExpressionSerializer.serializeRow(state.root), '(1)/(2)');
    });

    test('inserts root and replaces placeholder with token', () {
      var state = MathEditorState.initial();
      state = MathEditorReducer.insertStructure(state, MathStructureType.root);
      state = MathEditorReducer.insertToken(state, '9');

      expect(MathExpressionSerializer.serializeRow(state.root), '√(9)');
    });

    test('deletes empty block when deleting inside empty slot', () {
      var state = MathEditorState.initial();
      state = MathEditorReducer.insertStructure(state, MathStructureType.parentheses);
      state = MathEditorReducer.deleteBackward(state);

      expect(MathExpressionSerializer.serializeRow(state.root), '');
    });

    test('inserts absolute structure and serializes with pipes', () {
      var state = MathEditorState.initial();
      state = MathEditorReducer.insertStructure(state, MathStructureType.absolute);
      state = MathEditorReducer.insertToken(state, 'x');

      expect(MathExpressionSerializer.serializeRow(state.root), '|x|');
    });

    group('operator spacing', () {
      test('adds left and right placeholders for ÷', () {
        var state = MathEditorState.initial();
        state = MathEditorReducer.insertToken(state, '÷');

        expect(MathExpressionSerializer.serializeRow(state.root), '□÷□');
      });

      test('adds left and right placeholders for ×', () {
        var state = MathEditorState.initial();
        state = MathEditorReducer.insertToken(state, '×');

        expect(MathExpressionSerializer.serializeRow(state.root), '□×□');
      });

      test('adds left and right placeholders for =', () {
        var state = MathEditorState.initial();
        state = MathEditorReducer.insertToken(state, '=');

        expect(MathExpressionSerializer.serializeRow(state.root), '□=□');
      });

      test('adds left and right placeholders for %', () {
        var state = MathEditorState.initial();
        state = MathEditorReducer.insertToken(state, '%');

        expect(MathExpressionSerializer.serializeRow(state.root), '□%□');
      });

      test('adds right placeholder for +', () {
        var state = MathEditorState.initial();
        state = MathEditorReducer.insertToken(state, '+');

        expect(MathExpressionSerializer.serializeRow(state.root), '+□');
      });

      test('adds right placeholder for -', () {
        var state = MathEditorState.initial();
        state = MathEditorReducer.insertToken(state, '-');

        expect(MathExpressionSerializer.serializeRow(state.root), '-□');
      });

      test('does not format non-operator token', () {
        var state = MathEditorState.initial();
        state = MathEditorReducer.insertToken(state, '5');

        expect(MathExpressionSerializer.serializeRow(state.root), '5');
      });

      test('uses created placeholder in sequence 1 + 2', () {
        var state = MathEditorState.initial();
        state = MathEditorReducer.insertToken(state, '1');
        state = MathEditorReducer.insertToken(state, '+');
        state = MathEditorReducer.insertToken(state, '2');

        expect(MathExpressionSerializer.serializeRow(state.root), '1+2');
      });
    });
  });
}
