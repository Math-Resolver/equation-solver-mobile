import '../models/math_ast.dart';

class ExpressionState {
  final MathEditorState editorState;
  final String activeKeyboardType;
  final List<MathEditorState> history;

  const ExpressionState({
    required this.editorState,
    this.activeKeyboardType = 'basic',
    this.history = const [],
  });

  factory ExpressionState.initial() {
    return ExpressionState(editorState: MathEditorState.initial());
  }

  ExpressionState copyWith({
    MathEditorState? editorState,
    String? activeKeyboardType,
    List<MathEditorState>? history,
  }) {
    return ExpressionState(
      editorState: editorState ?? this.editorState,
      activeKeyboardType: activeKeyboardType ?? this.activeKeyboardType,
      history: history ?? this.history,
    );
  }
}
