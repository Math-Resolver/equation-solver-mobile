import '../core/core.dart';
import '../editor_selection.dart';

class MathEditorState {
  final RowNode root;
  final EditorSelection selection;
  final int nextId;

  const MathEditorState({
    required this.root,
    required this.selection,
    required this.nextId,
  });

  factory MathEditorState.initial() {
    const rootId = 'row_0';
    return const MathEditorState(
      root: RowNode(id: rootId, children: []),
      selection: EditorSelection(rowNodeId: rootId, offset: 0),
      nextId: 1,
    );
  }

  MathEditorState copyWith({
    RowNode? root,
    EditorSelection? selection,
    int? nextId,
  }) {
    return MathEditorState(
      root: root ?? this.root,
      selection: selection ?? this.selection,
      nextId: nextId ?? this.nextId,
    );
  }
}
