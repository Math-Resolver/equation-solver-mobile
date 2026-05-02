class EditorSelection {
  final String rowNodeId;
  final int offset;

  const EditorSelection({
    required this.rowNodeId,
    required this.offset,
  });

  EditorSelection copyWith({
    String? rowNodeId,
    int? offset,
  }) {
    return EditorSelection(
      rowNodeId: rowNodeId ?? this.rowNodeId,
      offset: offset ?? this.offset,
    );
  }
}
