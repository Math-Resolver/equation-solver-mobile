class ExpressionState {
  final String expression;
  final int cursorPosition;
  final String activeKeyboardType;
  final List<String> history;

  const ExpressionState({
    this.expression = '',
    this.cursorPosition = 0,
    this.activeKeyboardType = 'basic',
    this.history = const [],
  });

  ExpressionState copyWith({
    String? expression,
    int? cursorPosition,
    String? activeKeyboardType,
    List<String>? history,
  }) {
    return ExpressionState(
      expression: expression ?? this.expression,
      cursorPosition: cursorPosition ?? this.cursorPosition,
      activeKeyboardType: activeKeyboardType ?? this.activeKeyboardType,
      history: history ?? this.history,
    );
  }
}

class KeyboardType {
  final String id;
  final String label;
  final Set<String> symbols;
  final List<String> structures;
  final List<String>? orderedLayout;

  const KeyboardType({
    required this.id,
    required this.label,
    required this.symbols,
    this.structures = const [],
    this.orderedLayout,
  });
}

class EquationSolverCalculatorController {
  static const Map<String, KeyboardType> _keyboards = {
    'basic': KeyboardType(
      id: 'basic',
      label: '+ - x ÷',
      symbols: {
        '+', '-', '×', '÷', '=', '1/', '>', 'x',
        'π', '%', ',',
        '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
      },
      structures: ['( )', '√', '□²'],
      orderedLayout: [
        '( )', '+',  '÷', '7', '8', '9',
        '1/',  '√',  'x', '4', '5', '6',
        '□²',  '>',  '-', '1', '2', '3',
        'π',   '%', '×', '0', ',', '=',
      ],
    ),
    'functions': KeyboardType(
      id: 'functions',
      label: 'f(x) e log in',
      symbols: {'f(x)', 'e', 'log', 'ln'},
    ),
    'trig': KeyboardType(
      id: 'trig',
      label: 'sin cos tan cot',
      symbols: {'sin', 'cos', 'tan', 'cot'},
    ),
    'calculus': KeyboardType(
      id: 'calculus',
      label: 'lim dx Σ ∫ ∞',
      symbols: {'lim', 'dx', 'Σ', '∫', '∞'},
    ),
    'abc': KeyboardType(
      id: 'abc',
      label: 'ABC',
      symbols: {
        'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm',
        'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
      },
    ),
  };

  static const List<String> _keyboardOrder = [
    'basic',
    'functions',
    'trig',
    'calculus',
    'abc',
  ];

  ExpressionState _state = const ExpressionState();

  ExpressionState get state => _state;
  String get expression => _state.expression;
  int get cursorPosition => _state.cursorPosition;
  String get activeKeyboardType => _state.activeKeyboardType;

  KeyboardType get activeKeyboard => _keyboards[_state.activeKeyboardType]!;
  List<String> get availableKeyboards => _keyboardOrder;

  void toggleKeyboard() {
    final currentIndex = _keyboardOrder.indexOf(_state.activeKeyboardType);
    final nextIndex = (currentIndex + 1) % _keyboardOrder.length;
    final nextKeyboardId = _keyboardOrder[nextIndex];
    _state = _state.copyWith(activeKeyboardType: nextKeyboardId);
  }

  void switchKeyboard(String keyboardId) {
    if (_keyboards.containsKey(keyboardId)) {
      _state = _state.copyWith(activeKeyboardType: keyboardId);
    }
  }

  bool isSymbolAllowed(String symbol) {
    return activeKeyboard.symbols.contains(symbol) ||
        activeKeyboard.symbols.contains(symbol.toLowerCase());
  }

  KeyboardType getKeyboard(String id) => _keyboards[id]!;

  bool isStructureAllowed(String structure) {
    return activeKeyboard.structures.contains(structure);
  }

  void insertSymbol(String symbol) {
    if (!isSymbolAllowed(symbol)) {
      return;
    }

    _addToHistory();
    final pos = _state.cursorPosition;
    final expr = _state.expression;
    final isAtPlaceholder = expr.isNotEmpty &&
        pos < expr.length &&
        expr[pos] == '□';

    final newExpression = expr.isEmpty
        ? symbol
        : expr.replaceRange(
            pos,
            isAtPlaceholder ? pos + 1 : pos,
            symbol,
          );

    _state = _state.copyWith(
      expression: newExpression,
      cursorPosition: pos + symbol.length,
    );
  }

  // Maps each structure to (text to insert, cursor offset from insertion point).
  // Cursor offset puts the cursor right before the □ placeholder.
  static const Map<String, (String, int)> _structureInsertions = {
    '( )': ('(□)', 1),
    '√':   ('√□', 1),
    '□²':  ('□²', 0),
  };

  void insertStructure(String structure) {
    if (!isStructureAllowed(structure)) {
      return;
    }

    _addToHistory();
    final (text, cursorOffset) =
        _structureInsertions[structure] ?? ('$structure□', structure.length);
    final pos = _state.cursorPosition;

    final newExpression = _state.expression.isEmpty
        ? text
        : _state.expression.replaceRange(pos, pos, text);

    _state = _state.copyWith(
      expression: newExpression,
      cursorPosition: pos + cursorOffset,
    );
  }

  void moveCursorRight() {
    if (_state.cursorPosition < _state.expression.length) {
      _state = _state.copyWith(cursorPosition: _state.cursorPosition + 1);
    }
  }

  void moveCursorLeft() {
    if (_state.cursorPosition > 0) {
      _state = _state.copyWith(cursorPosition: _state.cursorPosition - 1);
    }
  }

  void deleteCharacter() {
    if (_state.cursorPosition == 0) {
      return;
    }

    _addToHistory();
    final newExpression = _state.expression.isEmpty
        ? ''
        : _state.expression.replaceRange(
            _state.cursorPosition - 1,
            _state.cursorPosition,
            '',
          );

    _state = _state.copyWith(
      expression: newExpression,
      cursorPosition: (_state.cursorPosition - 1).clamp(0, newExpression.length),
    );
  }

  void clear() {
    if (_state.expression.isEmpty) {
      return;
    }

    _addToHistory();
    _state = _state.copyWith(
      expression: '',
      cursorPosition: 0,
    );
  }

  void undo() {
    if (_state.history.isEmpty) {
      return;
    }

    final previousExpression = _state.history.last;
    final historyWithoutLast = _state.history.sublist(0, _state.history.length - 1);

    _state = _state.copyWith(
      expression: previousExpression,
      history: historyWithoutLast,
      cursorPosition: previousExpression.length.clamp(0, previousExpression.length),
    );
  }

  void _addToHistory() {
    final newHistory = [..._state.history, _state.expression];
    _state = _state.copyWith(history: newHistory);
  }

  void reset() {
    _state = const ExpressionState();
  }

  void loadExpression(String expression) {
    if (expression.isNotEmpty) {
      _state = _state.copyWith(
        expression: expression,
        cursorPosition: expression.length,
      );
    }
  }
}
