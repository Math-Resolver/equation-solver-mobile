import '../core/core.dart';
import '../state/structured_math_node.dart';

class AbsoluteNode extends StructuredMathNode {
  final RowNode content;

  const AbsoluteNode({required String id, required this.content}) : super(id);

  @override
  List<SlotRef> get slots => [SlotRef(name: 'content', row: content)];

  @override
  AbsoluteNode copyWithSlot(String slotName, RowNode row) {
    if (slotName == 'content') {
      return AbsoluteNode(id: id, content: row);
    }
    return this;
  }
}
