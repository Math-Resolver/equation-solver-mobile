import 'models/math_ast.dart';
import 'controller/expression_state.dart';
import 'controller/keyboard_catalog.dart';
import 'controller/keyboard_models.dart';
import 'controller/serialized_cursor_position_calculator.dart';
import 'services/math_editor_reducer.dart';
import 'services/math_expression_parser.dart';
import 'services/math_expression_serializer.dart';

export 'controller/keyboard_models.dart';

class EquationSolverCalculatorController {
  ExpressionState _state = ExpressionState.initial();
  ExpressionState get state => _state;
  MathEditorState get editorState => _state.editorState;
  String get expression => MathExpressionSerializer.serializeRow(_state.editorState.root);
  int get cursorPosition => SerializedCursorPositionCalculator.find(_state.editorState);
  String get activeKeyboardType => _state.activeKeyboardType;
  KeyboardType get activeKeyboard => KeyboardCatalog.keyboards[_state.activeKeyboardType]!;
  List<String> get availableKeyboards => KeyboardCatalog.keyboardOrder;

  void toggleKeyboard() {
    final currentIndex =
        KeyboardCatalog.keyboardOrder.indexOf(_state.activeKeyboardType);
    final nextIndex = (currentIndex + 1) % KeyboardCatalog.keyboardOrder.length;
    final nextKeyboardId = KeyboardCatalog.keyboardOrder[nextIndex];
    _state = _state.copyWith(activeKeyboardType: nextKeyboardId);
  }

  void switchKeyboard(String keyboardId) {
    if (KeyboardCatalog.keyboards.containsKey(keyboardId)) {
      _state = _state.copyWith(activeKeyboardType: keyboardId);
    }
  }

  bool isSymbolAllowed(String symbol) {
    return activeKeyboard.symbols.contains(symbol) ||
        activeKeyboard.symbols.contains(symbol.toLowerCase());
  }

  KeyboardType getKeyboard(String id) => KeyboardCatalog.keyboards[id]!;

  bool isStructureAllowed(String structure) {
    return activeKeyboard.structures.any((item) => item.label == structure);
  }

  void insertSymbol(String symbol) {
    if (!isSymbolAllowed(symbol)) {
      return;
    }
    _addToHistory();
    _state = _state.copyWith(
      editorState: MathEditorReducer.insertToken(_state.editorState, symbol),
    );
  }

  void insertStructure(String structure) {
    if (!isStructureAllowed(structure)) {
      return;
    }
    MathStructureType? structureAction;
    for (final item in activeKeyboard.structures) {
      if (item.label == structure) {
        structureAction = item.action;
        break;
      }
    }
    if (structureAction == null) {
      return;
    }
    _addToHistory();
    _state = _state.copyWith(
      editorState: MathEditorReducer.insertStructure(
        _state.editorState,
        structureAction,
      ),
    );
  }

  void moveCursorRight() {
    _state = _state.copyWith(
      editorState: MathEditorReducer.moveRight(_state.editorState),
    );
  }

  void moveCursorLeft() {
    _state = _state.copyWith(
      editorState: MathEditorReducer.moveLeft(_state.editorState),
    );
  }

  void deleteCharacter() {
    final currentExpression = expression;
    if (currentExpression.isEmpty) {
      return;
    }

    _addToHistory();
    _state = _state.copyWith(
      editorState: MathEditorReducer.deleteBackward(_state.editorState),
    );
  }

  void clear() {
    if (expression.isEmpty) {
      return;
    }

    _addToHistory();
    _state = _state.copyWith(
      editorState: MathEditorReducer.clear(_state.editorState),
    );
  }

  void undo() {
    if (_state.history.isEmpty) {
      return;
    }

    final previousEditorState = _state.history.last;
    final historyWithoutLast = _state.history.sublist(0, _state.history.length - 1);

    _state = _state.copyWith(
      editorState: previousEditorState,
      history: historyWithoutLast,
    );
  }

  void _addToHistory() {
    final newHistory = [..._state.history, _state.editorState];
    _state = _state.copyWith(history: newHistory);
  }

  void reset() {
    _state = ExpressionState.initial();
  }

  void loadExpression(String expression) {
    if (expression.isNotEmpty) {
      _state = _state.copyWith(
        editorState: MathExpressionParser.parseToState(expression),
      );
    }
  }

  void focusRow(String rowNodeId, int offset) {
    _state = _state.copyWith(
      editorState: MathEditorReducer.focusRow(
        _state.editorState,
        rowNodeId: rowNodeId,
        offset: offset,
      ),
    );
  }
}
