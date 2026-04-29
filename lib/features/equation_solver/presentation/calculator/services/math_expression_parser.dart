import '../models/editor_selection.dart';
import '../models/math_ast.dart';

class MathExpressionParser {
  MathExpressionParser(this._source)
    : _index = 0,
      _nextId = 0;

  final String _source;
  int _index;
  int _nextId;

  static MathEditorState parseToState(String expression) {
    if (expression.isEmpty) {
      return MathEditorState.initial();
    }

    final parser = MathExpressionParser(expression);
    final row = parser._parseRow(until: null);

    return MathEditorState(
      root: row,
      selection: EditorSelection(rowNodeId: row.id, offset: row.children.length),
      nextId: parser._nextId,
    );
  }

  RowNode _parseRow({String? until}) {
    final children = <MathNode>[];

    while (_index < _source.length) {
      if (until != null && _source[_index] == until) {
        break;
      }

      final fraction = _tryParseFraction();
      if (fraction != null) {
        children.add(fraction);
        continue;
      }

      final power = _tryParsePower();
      if (power != null) {
        children.add(power);
        continue;
      }

      final root = _tryParseRoot();
      if (root != null) {
        children.add(root);
        continue;
      }

      final parens = _tryParseParentheses();
      if (parens != null) {
        children.add(parens);
        continue;
      }

      final absolute = _tryParseAbsolute();
      if (absolute != null) {
        children.add(absolute);
        continue;
      }

      final char = _source[_index];
      if (char == '□') {
        _index++;
        children.add(PlaceholderNode(_alloc('placeholder')));
      } else {
        final start = _index;
        while (_index < _source.length) {
          final current = _source[_index];
          final hitsBoundary = current == '□' ||
              current == '√' ||
              current == '(' ||
              (until != null && current == until);
          if (hitsBoundary) {
            break;
          }
          _index++;
        }

        final chunk = _source.substring(start, _index);
        if (chunk.isNotEmpty) {
          children.add(TokenNode(id: _alloc('token'), value: chunk));
        }
      }
    }

    return RowNode(id: _alloc('row'), children: children);
  }

  FractionNode? _tryParseFraction() {
    final start = _index;
    final numerator = _tryParseGroupRow();
    if (numerator == null) {
      _index = start;
      return null;
    }

    if (!_consume('/')) {
      _index = start;
      return null;
    }

    final denominator = _tryParseGroupRow();
    if (denominator == null) {
      _index = start;
      return null;
    }

    return FractionNode(
      id: _alloc('fraction'),
      numerator: numerator,
      denominator: denominator,
    );
  }

  PowerNode? _tryParsePower() {
    final start = _index;
    final base = _tryParseGroupRow();
    if (base == null) {
      _index = start;
      return null;
    }

    if (!_consume('^')) {
      _index = start;
      return null;
    }

    final exponent = _tryParseGroupRow();
    if (exponent == null) {
      _index = start;
      return null;
    }

    return PowerNode(id: _alloc('power'), base: base, exponent: exponent);
  }

  RootNode? _tryParseRoot() {
    final start = _index;
    if (!_consume('√')) {
      return null;
    }

    final row = _tryParseGroupRow();
    if (row == null) {
      _index = start;
      return null;
    }

    return RootNode(id: _alloc('root'), radicand: row);
  }

  ParenthesesNode? _tryParseParentheses() {
    final start = _index;
    final row = _tryParseGroupRow();
    if (row == null) {
      _index = start;
      return null;
    }

    return ParenthesesNode(id: _alloc('parentheses'), content: row);
  }

  AbsoluteNode? _tryParseAbsolute() {
    final start = _index;
    if (!_consume('|')) {
      return null;
    }

    final row = _parseRow(until: '|');
    if (!_consume('|')) {
      _index = start;
      return null;
    }

    return AbsoluteNode(id: _alloc('absolute'), content: row);
  }

  RowNode? _tryParseGroupRow() {
    if (!_consume('(')) {
      return null;
    }

    final row = _parseRow(until: ')');
    if (!_consume(')')) {
      return null;
    }

    return row;
  }

  bool _consume(String expected) {
    if (_index >= _source.length || _source[_index] != expected) {
      return false;
    }

    _index++;
    return true;
  }

  String _alloc(String prefix) {
    final id = '${prefix}_$_nextId';
    _nextId++;
    return id;
  }
}
