import '../models/editor_selection.dart';
import '../models/math_ast.dart';

enum MathStructureType {
  fraction,
  root,
  power,
  parentheses,
  absolute,
}

class MathEditorReducer {
  static const Set<String> _surroundedOperators = {'÷', '×', '=', '%'};
  static const Set<String> _trailingOperators = {'+', '-'};

  static MathEditorState focusRow(
    MathEditorState state, {
    required String rowNodeId,
    required int offset,
  }) {
    final row = _findRow(state.root, rowNodeId);
    if (row == null) {
      return state;
    }

    return state.copyWith(
      selection: EditorSelection(
        rowNodeId: rowNodeId,
        offset: offset.clamp(0, row.children.length),
      ),
    );
  }

  static MathEditorState insertToken(MathEditorState state, String token) {
    final location = _findRowLocation(state.root, state.selection.rowNodeId);
    if (location == null) {
      return state;
    }

    final row = location.row;
    final offset = state.selection.offset.clamp(0, row.children.length);
    final node = TokenNode(id: _nodeId(state.nextId), value: token);
    var nextId = state.nextId + 1;
    var insertedIndex = offset;

    final newChildren = [...row.children];
    if (offset < newChildren.length && newChildren[offset] is PlaceholderNode) {
      newChildren[offset] = node;
    } else {
      newChildren.insert(offset, node);
    }

    if (_surroundedOperators.contains(token) && insertedIndex == 0) {
      newChildren.insert(0, PlaceholderNode(_nodeId(nextId)));
      nextId++;
      insertedIndex++;
    }

    if ((_surroundedOperators.contains(token) || _trailingOperators.contains(token)) &&
        (insertedIndex + 1 >= newChildren.length ||
            newChildren[insertedIndex + 1] is! PlaceholderNode)) {
      newChildren.insert(insertedIndex + 1, PlaceholderNode(_nodeId(nextId)));
      nextId++;
    }

    final updatedRow = _normalizeRow(
      row.copyWith(children: newChildren),
      isRoot: row.id == state.root.id,
      nextId: nextId,
    );
    nextId = updatedRow.nextId;

    final newRoot = _replaceRow(state.root, updatedRow.row);

    return state.copyWith(
      root: newRoot,
      selection: EditorSelection(rowNodeId: row.id, offset: insertedIndex + 1),
      nextId: nextId,
    );
  }

  static MathEditorState insertStructure(
    MathEditorState state,
    MathStructureType structure,
  ) {
    final location = _findRowLocation(state.root, state.selection.rowNodeId);
    if (location == null) {
      return state;
    }

    final row = location.row;
    final offset = state.selection.offset.clamp(0, row.children.length);
    final built = _buildStructure(structure, state.nextId);

    final newChildren = [...row.children];
    if (offset < newChildren.length && newChildren[offset] is PlaceholderNode) {
      newChildren[offset] = built.node;
    } else {
      newChildren.insert(offset, built.node);
    }

    final updatedRow = _normalizeRow(
      row.copyWith(children: newChildren),
      isRoot: row.id == state.root.id,
      nextId: built.nextId,
    );
    final newRoot = _replaceRow(state.root, updatedRow.row);

    return state.copyWith(
      root: newRoot,
      selection: EditorSelection(rowNodeId: built.entryRowId, offset: 0),
      nextId: updatedRow.nextId,
    );
  }

  static MathEditorState moveRight(MathEditorState state) {
    final location = _findRowLocation(state.root, state.selection.rowNodeId);
    if (location == null) {
      return state;
    }

    final row = location.row;
    final offset = state.selection.offset.clamp(0, row.children.length);

    if (offset < row.children.length) {
      final target = row.children[offset];
      final firstSlot = _firstSlot(target);
      if (firstSlot != null) {
        return state.copyWith(
          selection: EditorSelection(rowNodeId: firstSlot.id, offset: 0),
        );
      }

      return state.copyWith(
        selection: EditorSelection(rowNodeId: row.id, offset: offset + 1),
      );
    }

    if (location.parent == null) {
      return state;
    }

    final parent = location.parent!;
    final parentNode = parent.parentNode;
    if (parentNode != null) {
      final nextSlotName = parentNode.nextSlotName(parent.slotName);
      final nextSlot = nextSlotName == null ? null : parentNode.rowForSlot(nextSlotName);
      if (nextSlot != null) {
        return state.copyWith(
          selection: EditorSelection(rowNodeId: nextSlot.id, offset: 0),
        );
      }
    }

    return state.copyWith(
      selection: EditorSelection(
        rowNodeId: parent.parentRowId,
        offset: parent.parentIndex + 1,
      ),
    );
  }

  static MathEditorState moveLeft(MathEditorState state) {
    final location = _findRowLocation(state.root, state.selection.rowNodeId);
    if (location == null) {
      return state;
    }

    final row = location.row;
    final offset = state.selection.offset.clamp(0, row.children.length);

    if (offset > 0) {
      final target = row.children[offset - 1];
      final lastSlot = _lastSlot(target);
      if (lastSlot != null) {
        return state.copyWith(
          selection: EditorSelection(
            rowNodeId: lastSlot.id,
            offset: lastSlot.children.length,
          ),
        );
      }

      return state.copyWith(
        selection: EditorSelection(rowNodeId: row.id, offset: offset - 1),
      );
    }

    if (location.parent == null) {
      return state;
    }

    final parent = location.parent!;
    final parentNode = parent.parentNode;
    if (parentNode != null) {
      final previousSlotName = parentNode.previousSlotName(parent.slotName);
      final previousSlot = previousSlotName == null
          ? null
          : parentNode.rowForSlot(previousSlotName);
      if (previousSlot != null) {
        return state.copyWith(
          selection: EditorSelection(
            rowNodeId: previousSlot.id,
            offset: previousSlot.children.length,
          ),
        );
      }
    }

    return state.copyWith(
      selection: EditorSelection(
        rowNodeId: parent.parentRowId,
        offset: parent.parentIndex,
      ),
    );
  }

  static MathEditorState deleteBackward(MathEditorState state) {
    final location = _findRowLocation(state.root, state.selection.rowNodeId);
    if (location == null) {
      return state;
    }

    final row = location.row;
    final offset = state.selection.offset.clamp(0, row.children.length);

    if (offset > 0) {
      final newChildren = [...row.children]..removeAt(offset - 1);
      var nextId = state.nextId;
      final updated = _normalizeRow(
        row.copyWith(children: newChildren),
        isRoot: row.id == state.root.id,
        nextId: nextId,
      );
      nextId = updated.nextId;

      final newRoot = _replaceRow(state.root, updated.row);
      return state.copyWith(
        root: newRoot,
        selection: EditorSelection(rowNodeId: row.id, offset: offset - 1),
        nextId: nextId,
      );
    }

    if (location.parent == null) {
      return state;
    }

    if (!_isRowEffectivelyEmpty(row)) {
      final parent = location.parent!;
      return state.copyWith(
        selection: EditorSelection(
          rowNodeId: parent.parentRowId,
          offset: parent.parentIndex,
        ),
      );
    }

    final parent = location.parent!;
    final parentRow = _findRow(state.root, parent.parentRowId);
    if (parentRow == null) {
      return state;
    }

    final newParentChildren = [...parentRow.children]..removeAt(parent.parentIndex);
    var nextId = state.nextId;
    final normalizedParent = _normalizeRow(
      parentRow.copyWith(children: newParentChildren),
      isRoot: parentRow.id == state.root.id,
      nextId: nextId,
    );
    nextId = normalizedParent.nextId;

    final newRoot = _replaceRow(state.root, normalizedParent.row);
    return state.copyWith(
      root: newRoot,
      selection: EditorSelection(
        rowNodeId: parent.parentRowId,
        offset: parent.parentIndex.clamp(0, normalizedParent.row.children.length),
      ),
      nextId: nextId,
    );
  }

  static MathEditorState clear(MathEditorState state) {
    return state.copyWith(
      root: RowNode(id: state.root.id, children: const []),
      selection: EditorSelection(rowNodeId: state.root.id, offset: 0),
      nextId: state.nextId,
    );
  }

  static MathEditorState load(MathEditorState current, MathEditorState loaded) {
    return loaded;
  }

  static _BuiltStructure _buildStructure(MathStructureType type, int nextId) {
    var id = nextId;

    String alloc(String prefix) {
      final value = '${prefix}_$id';
      id++;
      return value;
    }

    RowNode makeSlot() {
      return RowNode(
        id: alloc('row'),
        children: [PlaceholderNode(alloc('placeholder'))],
      );
    }

    switch (type) {
      case MathStructureType.fraction:
        final numerator = makeSlot();
        final denominator = makeSlot();
        final node = FractionNode(
          id: alloc('fraction'),
          numerator: numerator,
          denominator: denominator,
        );
        return _BuiltStructure(node: node, entryRowId: numerator.id, nextId: id);
      case MathStructureType.root:
        final radicand = makeSlot();
        final node = RootNode(id: alloc('root'), radicand: radicand);
        return _BuiltStructure(node: node, entryRowId: radicand.id, nextId: id);
      case MathStructureType.power:
        final base = makeSlot();
        final exponent = makeSlot();
        final node = PowerNode(id: alloc('power'), base: base, exponent: exponent);
        return _BuiltStructure(node: node, entryRowId: base.id, nextId: id);
      case MathStructureType.parentheses:
        final content = makeSlot();
        final node = ParenthesesNode(id: alloc('parentheses'), content: content);
        return _BuiltStructure(node: node, entryRowId: content.id, nextId: id);
      case MathStructureType.absolute:
        final content = makeSlot();
        final node = AbsoluteNode(id: alloc('absolute'), content: content);
        return _BuiltStructure(node: node, entryRowId: content.id, nextId: id);
    }
  }

  static _NormalizedRow _normalizeRow(
    RowNode row, {
    required bool isRoot,
    required int nextId,
  }) {
    if (isRoot || row.children.isNotEmpty) {
      return _NormalizedRow(row: row, nextId: nextId);
    }

    final placeholder = PlaceholderNode(_nodeId(nextId));
    return _NormalizedRow(
      row: row.copyWith(children: [placeholder]),
      nextId: nextId + 1,
    );
  }

  static bool _isRowEffectivelyEmpty(RowNode row) {
    return row.children.isEmpty ||
        (row.children.length == 1 && row.children.first is PlaceholderNode);
  }

  static RowNode? _firstSlot(MathNode node) {
    if (node is StructuredMathNode && node.slots.isNotEmpty) {
      return node.slots.first.row;
    }
    return null;
  }

  static RowNode? _lastSlot(MathNode node) {
    if (node is StructuredMathNode && node.slots.isNotEmpty) {
      return node.slots.last.row;
    }
    return null;
  }

  static RowNode? _findRow(RowNode root, String id) {
    if (root.id == id) {
      return root;
    }

    for (final child in root.children) {
      final found = _findRowInNode(child, id);
      if (found != null) {
        return found;
      }
    }

    return null;
  }

  static RowNode? _findRowInNode(MathNode node, String id) {
    if (node is StructuredMathNode) {
      for (final slot in node.slots) {
        final found = _findRow(slot.row, id);
        if (found != null) {
          return found;
        }
      }
    }
    return null;
  }

  static _RowLocation? _findRowLocation(RowNode root, String targetId) {
    if (root.id == targetId) {
      return _RowLocation(row: root, parent: null);
    }

    for (var i = 0; i < root.children.length; i++) {
      final child = root.children[i];
      final result = _findRowLocationInNode(
        child,
        targetId,
        _ParentLink(
          parentRowId: root.id,
          parentIndex: i,
          parentNode: null,
          slotName: 'child',
        ),
      );
      if (result != null) {
        return result;
      }
    }

    return null;
  }

  static _RowLocation? _findRowLocationInNode(
    MathNode node,
    String targetId,
    _ParentLink parent,
  ) {
    if (node is StructuredMathNode) {
      for (final slot in node.slots) {
        if (slot.row.id == targetId) {
          return _RowLocation(
            row: slot.row,
            parent: parent.copyWith(parentNode: node, slotName: slot.name),
          );
        }

        final found = _findRowLocation(slot.row, targetId);
        if (found != null) {
          return _RowLocation(
            row: found.row,
            parent: found.parent ??
                parent.copyWith(parentNode: node, slotName: slot.name),
          );
        }
      }
    }

    return null;
  }

  static RowNode _replaceRow(RowNode root, RowNode updated) {
    if (root.id == updated.id) {
      return updated;
    }

    final newChildren = root.children
        .map((child) => _replaceRowInNode(child, updated))
        .toList(growable: false);

    return root.copyWith(children: newChildren);
  }

  static MathNode _replaceRowInNode(MathNode node, RowNode updated) {
    if (node is StructuredMathNode) {
      var next = node;
      for (final slot in node.slots) {
        next = next.copyWithSlot(slot.name, _replaceRow(slot.row, updated));
      }
      return next;
    }
    return node;
  }

  static String _nodeId(int value) => 'node_$value';
}

class _BuiltStructure {
  final MathNode node;
  final String entryRowId;
  final int nextId;

  const _BuiltStructure({
    required this.node,
    required this.entryRowId,
    required this.nextId,
  });
}

class _NormalizedRow {
  final RowNode row;
  final int nextId;

  const _NormalizedRow({required this.row, required this.nextId});
}

class _ParentLink {
  final String parentRowId;
  final int parentIndex;
  final StructuredMathNode? parentNode;
  final String slotName;

  const _ParentLink({
    required this.parentRowId,
    required this.parentIndex,
    required this.parentNode,
    required this.slotName,
  });

  _ParentLink copyWith({StructuredMathNode? parentNode, String? slotName}) {
    return _ParentLink(
      parentRowId: parentRowId,
      parentIndex: parentIndex,
      parentNode: parentNode ?? this.parentNode,
      slotName: slotName ?? this.slotName,
    );
  }
}

class _RowLocation {
  final RowNode row;
  final _ParentLink? parent;

  const _RowLocation({required this.row, required this.parent});
}
